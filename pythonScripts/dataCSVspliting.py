from commonFunctions import *
from pathlib import Path
import os
import csv

# modified script from mr. Jordi Rivero, found at: https://gist.github.com/jrivero/1085501

# COMPUTE FILE DIRECTORIES AND CHECK FOR VALIDITY ----------------------------------------------------------------------

pathData = Path("C:/Users/geibfil/Desktop/JRC-E-3/experiments/1308-01/parsed_data/IMU_parsed.csv")
pathLaps = Path("C:/Users/geibfil/Desktop/JRC-E-3/experiments/1308-01/processed_data/IMU_laps.csv")
dirFinal = "C:/Users/geibfil/Desktop/JRC-E-3/experiments/1308-01/final_data"
sampleRate = 2000
periode = 1 / sampleRate

# check if data CSV file exists and is readable
if not os.path.isfile(pathData): outputHandler("data CSV file does not exist", han.err)
if not os.access(pathData, os.R_OK): outputHandler("data CSV file is not readable", han.err)

# check if laps CSV file exists and is readable
if not os.path.isfile(pathLaps): outputHandler("laps CSV file does not exist", han.err)
if not os.access(pathLaps, os.R_OK): outputHandler("laps CSV file is not readable", han.err)

# check if directory for separated laps exists and is writable
if not os.path.exists(Path(dirFinal)): outputHandler("final data directory is not writable", han.err)
if not os.access(Path(dirFinal), os.W_OK): outputHandler("final data directory is not writable", han.err)

# LOAD START AND END TIMES OF EACH LAP ---------------------------------------------------------------------------------

# open laps csv file
lapsFile = open(pathLaps, 'r')
if not lapsFile.readable(): outputHandler("unable to read laps CSV file", han.err)

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
    lapStart[i] = lapStart[i] * sampleRate
    lapEnd[i] = lapEnd[i] * sampleRate

# SPLIT INPUT CSV FILE TO CHUNKS (LAPS) ACCORDING TO LOADED LAPS TIMES -------------------------------------------------

# open data CSV file
dataFile = open(pathData, 'r')
if not dataFile.readable(): outputHandler("unable to read data CSV file", han.err)

# create csv reader, lap counter and lap time
reader = csv.reader(dataFile, delimiter=',')
currentLap = 1
timeLap = 0

# load original header
header = next(reader)

# create starting path to very first csv output
currentPath = Path(dirFinal + "/IMU_lap_" + str(currentLap).zfill(2) + ".csv")

# create csv file for currently processed lap
currentFile = open(currentPath, 'w')
if not currentFile.writable(): outputHandler("unable to create CSV lap file", han.err)

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
        timeLap += periode

        if i == lapEnd[currentLap - 1]:
            # close actual csv file
            currentFile.close()

            # new lap ahead
            currentLap += 1

            # reset internal lap time
            timeLap = 0

            if currentLap <= len(lapStart):
                # create starting path to next  csv output
                currentPath = Path(dirFinal + "/IMU_lap_" + str(currentLap).zfill(2) + ".csv")

                # create csv file for currently processed lap
                currentFile = open(currentPath, 'w')
                if not currentFile.writable(): outputHandler("unable to create CSV lap file", han.err)

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
