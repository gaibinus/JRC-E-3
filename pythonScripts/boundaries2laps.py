from functions import *
from pathlib import Path

import csv
import sys

# MAIN------------------------------------------------------------------------------------------------------------------

# FILES HANDLING -------------------------------------------------------------------------------------------------------
# input format: main -b <boundaries file> -l <laps file>

# check number of parameters and marking
if len(sys.argv) != 5: outputHandler("4 parameters expected, got " + str(len(sys.argv) - 1), han.err)
if sys.argv[1] != "-b": outputHandler("first marker should be -b", han.err)
if sys.argv[3] != "-l": outputHandler("first marker should be -l", han.err)

# compute directories
pathBound = Path(sys.argv[2])
pathLaps = Path(sys.argv[4])

# check if boundaries file exists and is readable
checkAccess(pathBound, "r")

# load and check boundaries file
boundFile = open(pathBound, 'r')
if not boundFile.readable(): outputHandler("unable to read boundaries file", han.err)

# create boundaries CSV reader
reader = csv.reader(boundFile, delimiter=',', lineterminator='\n')

# create and check laps file
lapsFile = open(pathLaps, 'w')
if not lapsFile.writable(): outputHandler("unable to create laps file", han.err)

# create laps CSV writer and write header
writer = csv.writer(lapsFile, delimiter=',', lineterminator='\n')
writer.writerow(["LapNo", "Start", "End", "Duration"])

# PROCESS BOUNDARIES FILE AND CREATE LAPS FILE -------------------------------------------------------------------------

# skip header row
next(reader)

# current lap counter, last boundary, and variables for time checking
currLap = 1
prevEnd = None
currStart = None

# check if first boundary data is static, pre-read row for next loop
row = next(reader)
lastBound = str2float(row[1])
if not lastBound == 1: outputHandler("corrupted boundaries file - starts with 0", han.err)

# loop thru whole boundaries file
for row in reader:

    # retype row from string to float
    row[0] = str2float(row[0])
    row[1] = str2float(row[1])

    # detect falling edge => lap start
    if lastBound == 1 and row[1] == 0:
        currStart = row[0]

    # detect rising edge => lap end and proceed current lap
    elif lastBound == 0 and row[1] == 1:
        currEnd = row[0]

        # check if lap times make sense
        if not currStart < currEnd:
            outputHandler("start time !< than end time in lap " + str(currLap), han.err)

        # check if lap time is after previous lap
        if prevEnd is not None and currStart < prevEnd:
            outputHandler("end of previous lap !< than start of current lap " + str(currLap), han.err)

        # compute current lap duration
        currDuration = round(abs(currStart - currEnd), 2)

        # everything is OK, write to CSV
        writer.writerow([currLap, currStart, currEnd, currDuration])

        # update variables
        currLap += 1
        prevEnd = currEnd

    # update lastBound
    lastBound = row[1]

# check if last boundary data is static
if not lastBound == 1: outputHandler("corrupted boundaries file - ends with 0", han.err)

# close open CSV files
boundFile.close()
lapsFile.close()

# CODE END -------------------------------------------------------------------------------------------------------------
