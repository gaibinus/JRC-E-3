from functions import *
from pathlib import Path

from boundaries2laps import boundaries2laps
from dataCSVsplitting import dataCSVsplitting

import argparse
import time
import matlab.engine


# CLASSES --------------------------------------------------------------------------------------------------------------

class path:
    config = None
    bound = None
    laps = None
    data = None
    compen = None
    final = None


# MAIN------------------------------------------------------------------------------------------------------------------

# FILES AND MATLAB HANDLING --------------------------------------------------------------------------------------------

# create input arguments parser
parser = argparse.ArgumentParser(description='Divide parsed IMU data to individual laps.')

# add required argument
parser.add_argument('-e', '--experiment', help='path to existing experiment directory', type=str, required=True)

# load input argument
arguments = parser.parse_args()

# compute directories
path.config = Path(arguments.experiment + '/config.txt')
path.bound = Path(arguments.experiment + '/processed_data/IMU_boundaries.csv')
path.laps = Path(arguments.experiment + '/processed_data/IMU_laps.csv')
path.data = Path(arguments.experiment + '/parsed_data/IMU_parsed.csv')
path.compen = Path(arguments.experiment + '/parsed_data/IMU_compensated.csv')
path.final = arguments.experiment + '/final_data'

# check if files exist and are readable / writable
checkAccess(Path(arguments.experiment), 'w')
checkAccess(path.config, 'r')
checkAccess(path.bound, 'r')
checkAccess(path.data, 'r')
checkAccess(path.final, 'w')

# inform about current state
outputHandler('all files loaded successfully, starting MATLAB engine', han.info)

# start matlab engine
eng = matlab.engine.start_matlab()

# compute matlab directory path and load it to engine
matlabDir = os.getcwd()
matlabDir = matlabDir.replace('pythonScripts', 'matlabScripts')
eng.cd(matlabDir)

# COMPENSATE GRAVITY ---------------------------------------------------------------------------------------------------

timeTmp = time.time()
outputHandler('starting MATLAB gravity compensation', han.info)
ret = eng.compensateGravity(str(path.data), str(path.compen), str(path.config))
if ret is not True: outputHandler('false returned from MATLAB script', han.err)
outputHandler('gravity compensated in: ' + timeDeltaStr(time.time(), timeTmp), han.info)

# REMOVE PRESSURE ------------------------------------------------------------------------------------------------------

timeTmp = time.time()
outputHandler('starting MATLAB pressure removing', han.info)
ret = eng.removePressure(str(path.compen))
if ret is not True: outputHandler('false returned from MATLAB script', han.err)
outputHandler('pressure removed in: ' + timeDeltaStr(time.time(), timeTmp), han.info)

# COMPUTE LAPS FROM BOUNDARIES -----------------------------------------------------------------------------------------

# inform about current state
outputHandler("starting 'boundaries2laps.py", han.info)
timeTmp = time.time()

# call function and its workaround
ret = boundaries2laps(path.bound, path.laps)
if ret is not True: outputHandler('false returned from boundaries2laps script', han.err)
outputHandler('laps computed in: ' + timeDeltaStr(time.time(), timeTmp), han.info)

# SPLIT DATA TO LAPS ---------------------------------------------------------------------------------------------------

# inform about current state
outputHandler("starting 'dataCSVsplitting.py", han.info)

# read sample rate from config file
sampleRate = readConfig(path.config, 'sample_rate')

# call function
ret = dataCSVsplitting(path.compen, path.laps, path.final, sampleRate)
if ret is False: outputHandler('false returned from dataCSVsplitting script', han.err)

# write laps count to config txt
writeConfig(path.config, 'laps_count', ret)

# CODE END -------------------------------------------------------------------------------------------------------------

# abort matlab engine
eng.exit()
