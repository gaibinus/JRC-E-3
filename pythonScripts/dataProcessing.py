from commonFunctions import *
from pathlib import Path
import matlab.engine
import time  # execution time measurement
import sys
import os

# MAIN------------------------------------------------------------------------------------------------------------------

# save starting time for execution time computing
startTime = time.time()

# check number of parameters and marking
if len(sys.argv) != 7: outputHandler("6 parameters expected, got " + str(len(sys.argv) - 1), han.err)
if sys.argv[1] != "-o": outputHandler("first marker should be -o", han.err)
if sys.argv[3] != "-m": outputHandler("second marker should be -m", han.err)
if sys.argv[5] != "-f": outputHandler("third marker should be -f", han.err)

# possible downsample modes
modes = ['default', 'sum', 'mean', 'prod', 'min', 'max', 'count', 'firstvalue', 'lastvalue']

# check if mode is correct
metod = sys.argv[4]
if metod not in modes:
    outputHandler("selected mode is not valid", han.err)

# check if frequency is correct
freq = None
try:
    freq = int(sys.argv[6])
except ValueError:
    outputHandler("selected frequency is not integer", han.err)
if freq <= 0:
    outputHandler("selected frequency is <= zero", han.err)

# calculate input and output file path
inFile = Path(sys.argv[2] + '/parsed_data/IMU_proc.csv')
outFile = Path(sys.argv[2] + '/resampled_data/IMU_' + metod + '_' + str(freq) + '.csv')

# check if the IMU input file exists and is readable
if not os.path.isfile(inFile): outputHandler("input IMU file does not exist", han.err)
if not os.access(inFile, os.R_OK): outputHandler("input IMU file is not readable", han.err)

# check if the IMU output file exists and is readable
if os.path.isfile(outFile): outputHandler("output IMU file already exist", han.err)

# inform about current stage
outputHandler("checks completed, starting matlab engine", han.info)

# start matlab engine
eng = matlab.engine.start_matlab()

# compute matlab directory path and load it to engine
matlabDir = os.getcwd()
matlabDir = matlabDir.replace('pythonScripts', 'matlabScripts')
eng.cd(matlabDir)

# matlab resample function
ret = eng.resampleIMU(str(inFile), str(outFile), float(freq), metod)
if ret is True:
    outputHandler("file successfully downsampled", han.info)
else:
    outputHandler("false returned from matlab script", han.err)

# abort matlab engine
eng.exit()

# print execution time
outputHandler("scripot executed in: " + str(round(time.time() - startTime, 4)) + " seconds", han.info)
