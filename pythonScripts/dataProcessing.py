from functions import *
from pathlib import Path
import matlab.engine

import argparse
import time
import os


# CLASSES --------------------------------------------------------------------------------------------------------------

class path:
    def __index__(self, folder):
        self.parsed = self.parsed()
        self.processed = self.processed()
        self.final = None
        self.experiment = None
        self.config = None

    class parsed:
        IMU = None
        GPS = None

    class processed:
        boun = None
        laps = None
        resa = None
        velo = None


class config:
    sampleRate = None
    resampleRate = None
    resampleMode = None
    searchSize = None
    bnwStart = None
    bnwStop = None


class timeStamps:
    start = None
    tmp = None


# FUNCTIONS ------------------------------------------------------------------------------------------------------------

def processInput(normalName, unit, typeExpect):
    # repeat while not valid input
    while True:
        dataInput = input('Insert ' + normalName + ' [' + unit + '] (' + typeExpect + '): ')
        # check for a type
        try:
            if typeExpect == 'integer':
                dataInput = int(dataInput)
            elif typeExpect == 'float':
                dataInput = float(dataInput)
            elif typeExpect == 'string':
                pass
            else:
                outputHandler('unchecked input type', han.warn)
        except ValueError:
            outputHandler('entered value is not ' + typeExpect + ', try again', han.warn)
            continue
        break
    # return rav, not a string
    return dataInput


# MAIN------------------------------------------------------------------------------------------------------------------
timeStamps.start = time.time()

# FILES HANDLING -------------------------------------------------------------------------------------------------------

# create input arguments parser
parser = argparse.ArgumentParser(description='Divide parsed IMU data to individual laps.')

# add required argument
parser.add_argument('-e', '--experiment', help='path to existing experiment directory', required=True)

# load input argument
arguments = parser.parse_args()

# compute directories
path.experiment = arguments.experiment
path.config = Path(path.experiment + '/config.txt')
path.final = Path(path.experiment + '/final_data/')

path.parsed.IMU = Path(path.experiment + '/parsed_data/IMU_parsed.csv')
path.parsed.GPS = Path(path.experiment + '/parsed_data/GPS_parsed.csv')

path.processed.boun = Path(path.experiment + '/processed_data/IMU_boundaries.csv')
path.processed.conv = Path(path.experiment + '/processed_data/IMU_convoluted.csv')
path.processed.laps = Path(path.experiment + '/processed_data/IMU_laps.csv')
path.processed.resa = Path(path.experiment + '/processed_data/IMU_resampled.csv')
path.processed.velo = Path(path.experiment + '/processed_data/IMU_velocity.csv')

# check if files exists and are accessible
checkAccess(path.config, 'r')
checkAccess(path.parsed.IMU, 'r')
checkAccess(path.parsed.GPS, 'r')

# check if folders exist and are writable
checkAccess(Path(path.experiment), 'w')
checkAccess(path.final, 'w')

# LOAD AND CHECK DATA FROM CONFIG FILE ---------------------------------------------------------------------------------

# load data from config file
config.sampleRate = readConfig(path.config, 'sample_rate')
config.resampleRate = readConfig(path.config, 'resample_rate')
config.resampleMode = readConfig(path.config, 'resample_mode')
config.searchSize = readConfig(path.config, 'bnw_search')

# possible downsample modes
modes = ['default', 'sum', 'mean', 'prod', 'min', 'max', 'count', 'firstvalue', 'lastvalue']

# check if loaded data are valid
if not isinstance(config.sampleRate, float):
    outputHandler('broken config file on sample_rate', han.err)
if not isinstance(config.sampleRate, float):
    outputHandler('broken config file on resample_rate', han.err)
if not isinstance(config.searchSize, float):
    outputHandler('broken config file on bnw_search', han.err)
if config.resampleMode not in modes:
    outputHandler('broken config file on resample_mode', han.err)

# check if frequency is correct
if config.sampleRate <= 0 or config.resampleRate <= 0 or config.sampleRate <= config.resampleRate:
    outputHandler('broken config file on sample_rate and resample_rate', han.err)
if config.searchSize <= 0:
    outputHandler('broken config file on bnw_search', han.err)

# inform about current state
outputHandler('all files loaded successfully, starting MATLAB engine', han.info)

# MAIN BODY OF DATA PROCESSING -----------------------------------------------------------------------------------------

# start matlab engine
eng = matlab.engine.start_matlab()

# compute matlab directory path and load it to engine
matlabDir = os.getcwd()
matlabDir = matlabDir.replace('pythonScripts', 'matlabScripts')
eng.cd(matlabDir)

# MATLAB plot graph for human search of BNW
eng.plotIMU(str(path.parsed.IMU), config.searchSize, nargout=0)

# process human interaction
while True:
    config.bnwStart = processInput('START of time window', 's', 'float')
    config.bnwStop = processInput('END of time window', 's', 'float')

    # check validity of data
    if config.bnwStop <= config.bnwStart:
        outputHandler('end is smaller or equal to start, repeat the process', han.warn)
        continue

    # write valid data to config
    writeConfig(path.config, 'bnw_size', abs(config.bnwStart - config.bnwStop))
    writeConfig(path.config, 'bnw_start', config.bnwStart)
    writeConfig(path.config, 'bnw_stop', config.bnwStop)
    break

# close plot
eng.close('all')

# MATLAB compute variant
timeStamps.tmp = time.time()
outputHandler('starting MATLAB variant computation', han.info)
ret = eng.computeVariant(str(path.parsed.IMU), str(path.config))
if ret is not True: outputHandler('false returned from MATLAB script', han.err)
outputHandler('variant computed in: ' + timeDeltaStr(time.time(), timeStamps.tmp), han.info)

# MATLAB resample function
timeStamps.tmp = time.time()
outputHandler('starting MATLAB data resampling', han.info)
ret = eng.resampleData(str(path.parsed.IMU), str(path.processed.resa), float(config.resampleRate), config.resampleMode)
if ret is not True: outputHandler('false returned from MATLAB script', han.err)
outputHandler('data resampled in: ' + timeDeltaStr(time.time(), timeStamps.tmp), han.info)

# check if created file exists and it is readable
checkAccess(path.processed.resa, 'r')

# MATLAB compute velocity
timeStamps.tmp = time.time()
outputHandler('starting MATLAB velocity computation', han.info)
ret = eng.computeVelocity(str(path.processed.resa), str(path.processed.velo), str(path.config))
if ret is not True: outputHandler('false returned from MATLAB script', han.err)
outputHandler('velocity computed in: ' + timeDeltaStr(time.time(), timeStamps.tmp), han.info)

# check if created file exists and it is readable
checkAccess(path.processed.velo, 'r')

# MATLAB detect laps
timeStamps.tmp = time.time()
outputHandler('starting MATLAB laps detection', han.info)
ret = eng.detectBoundaries(str(path.processed.velo), str(path.processed.boun), str(path.config))
if ret is not True: outputHandler('false returned from MATLAB script', han.err)
outputHandler('laps detected in: ' + timeDeltaStr(time.time(), timeStamps.tmp), han.info)

# check if created file exists and it is readable
checkAccess(path.processed.boun, 'r')

# MATLAB plot boundaries for human check
outputHandler('plotting results in MATLAB', han.info)
eng.plotBoundaries(str(path.processed.velo), str(path.processed.boun), nargout=0)

# wait for human interaction
while True:
    tmpIn = processInput('press \'y\' to end script', '-', 'string')

    # check validity of data
    if tmpIn is not 'y' and tmpIn is not 'Y':
        outputHandler('invalid input, repeat the process', han.warn)
        continue
    else:
        break

# close plot
eng.close('all')

# abort matlab engine
eng.exit()

# CODE END -------------------------------------------------------------------------------------------------------------

# print execution time
outputHandler('overall script executed in: ' + timeDeltaStr(time.time(), timeStamps.start), han.info)
