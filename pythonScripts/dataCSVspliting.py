from functions import *
from pathlib import Path

import argparse
import csv
import time


# MAIN------------------------------------------------------------------------------------------------------------------

# FILES HANDLING -------------------------------------------------------------------------------------------------------

# create input arguments parser
parser = argparse.ArgumentParser(description='Parse and check raw IMU and GPS files to CSV format.')

# add required arguments
parser.add_argument('-d', '--data', help='path to data file', type=str, required=True)
parser.add_argument('-l', '--laps', help='path to laps file', type=str, required=True)
parser.add_argument('-f', '--final', help='path to final data folder', type=str, required=True)
parser.add_argument('-s', '--sampleRate', help='sample rate of data file', type=int, required=True)

# load input arguments
arguments = parser.parse_args()

# load sample rate and compute period
sampleRate = arguments.sampleRate
period = sampleRate / 1

# compute directories
pathData = Path(arguments.data)
pathLaps = Path(arguments.laps)
dirFinal = arguments.final

# check if files exists and are readable
checkAccess(pathData, 'r')
checkAccess(pathLaps, 'r')

# check if directory for separated laps exists and is writable
checkAccess(Path(dirFinal), 'w')

# LOAD START AND END TIMES OF EACH LAP ---------------------------------------------------------------------------------

# open laps csv file
lapsFile = open(pathLaps, 'r')
checkOpen(lapsFile, 'r')

# create csv reader
reader = csv.reader(lapsFile, delimiter=',')

# preallocate arrays for starting and ending times of laps
lapsSum = sum(1 for row in lapsFile) - 1
lapStart = lapsSum * [float('nan')]
lapEnd = lapsSum * [float('nan')]

# reset reader and skip header for new loop
lapsFile.seek(0)
header = next(reader)

# read laps csv file line by line and store values to arrays declared above
for row in reader:
    # process lap number
    lapNo = 1
    try:
        lapNo = int(row[0])
    except ValueError:
        outputHandler("corrupted laps CSV file, col: 1", han.err, lapNo)

    # process lap start time
    try:
        lapStart[lapNo - 1] = float(row[1])
    except ValueError:
        outputHandler("corrupted laps CSV file, col: 2", han.err, lapNo)

    # process lap end time
    try:
        lapEnd[lapNo - 1] = float(row[2])
    except ValueError:
        outputHandler("corrupted laps CSV file, col: 3", han.err, lapNo)

    # just for case of future error
    lapNo += 1

# close laps csv file
lapsFile.close()

# change starting and ending times of laps to starting and ending lines
for i in range(len(lapStart)):
    lapStart[i] = round(lapStart[i] * sampleRate)
    lapEnd[i] = round(lapEnd[i] * sampleRate)

# inform about current state
outputHandler("all files loaded successfully, starting to split CSV", han.info)

# SPLIT INPUT CSV FILE TO CHUNKS (LAPS) ACCORDING TO LOADED LAPS TIMES -------------------------------------------------

# open data CSV file
dataFile = open(pathData, 'r')
checkOpen(dataFile, 'r')

# create csv reader, lap counter, lap time and execution time
reader = csv.reader(dataFile, delimiter=',')
currentLap = 1
timeLap = 0
lastExecTime = time.time()

# load original header
header = next(reader)

# create starting path to very first csv output
currentPath = Path(dirFinal + "/IMU_lap_" + str(currentLap).zfill(2) + ".csv")

# create csv file for currently processed lap
currentFile = open(currentPath, 'w')
checkOpen(currentFile, 'w')

# create writer for currently processed lap
currentWriter = csv.writer(currentFile, delimiter=',', lineterminator='\n')

# write header to current CSV file
currentWriter.writerow(header)

for i, row in enumerate(reader):
    if lapStart[currentLap - 1] <= i <= lapEnd[currentLap - 1]:
        # change absolute time to lap time
        row[0] = str(timeLap)

        # write row to lap file
        currentWriter.writerow(row)

        # compute next lap time
        timeLap += period

        if i == lapEnd[currentLap - 1]:
            # close actual csv file
            currentFile.close()

            # inform user
            outputHandler('lap no. ' + str(currentLap) + ' splitted in: ' +
                          timeDeltaStr(time.time(), lastExecTime), han.info)

            # update lap and time
            currentLap += 1
            lastExecTime = time.time()

            # reset internal lap time
            timeLap = 0

            if currentLap <= len(lapStart):
                # create starting path to next  csv output
                currentPath = Path(dirFinal + "/IMU_lap_" + str(currentLap).zfill(2) + ".csv")

                # create csv file for currently processed lap
                currentFile = open(currentPath, 'w')
                checkOpen(currentFile, 'w')

                # create writer for currently processed lap
                currentWriter = csv.writer(open(currentPath, 'w'), delimiter=',', lineterminator='\n')

                # write header to current CSV file
                currentWriter.writerow(header)

            # no more laps expected
            else:
                break

# close files
dataFile.close()
currentFile.close()

# CODE END -------------------------------------------------------------------------------------------------------------
