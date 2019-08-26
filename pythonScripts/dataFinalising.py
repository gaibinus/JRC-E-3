from functions import *
from pathlib import Path

from boundaries2laps import boundaries2laps
from dataCSVsplitting import dataCSVsplitting

import argparse


# CLASSES --------------------------------------------------------------------------------------------------------------

class path:
    config = None
    bound = None
    laps = None
    data = None
    final = None


# MAIN------------------------------------------------------------------------------------------------------------------

# FILES HANDLING -------------------------------------------------------------------------------------------------------

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
path.final = arguments.experiment + '/final_data'

# check if files exist and are readable / writable
checkAccess(Path(arguments.experiment), 'w')
checkAccess(path.config, 'r')
checkAccess(path.bound, 'r')
checkAccess(path.data, 'r')
checkAccess(path.final, 'w')

# inform about current state
outputHandler("all files loaded successfully", han.info)

# COMPUTE LAPS FROM BOUNDARIES -----------------------------------------------------------------------------------------

# inform about current state
outputHandler("starting 'boundaries2laps.py", han.info)

# call function
ret = boundaries2laps(path.bound, path.laps)
if ret is not True: outputHandler('false returned from boundaries2laps script', han.err)

# SPLIT DATA TO LAPS ---------------------------------------------------------------------------------------------------

# inform about current state
outputHandler("starting 'dataCSVsplitting.py", han.info)

# read sample rate from config file
sampleRate = readConfig(path.config, 'sample_rate')

# call function
ret = dataCSVsplitting(path.data, path.laps, path.final, sampleRate)
if ret is not True: outputHandler('false returned from dataCSVsplitting script', han.err)

# CODE END -------------------------------------------------------------------------------------------------------------
