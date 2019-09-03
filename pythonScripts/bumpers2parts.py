from functions import *
from pathlib import Path

import argparse
import csv


# FUNCTIONS ------------------------------------------------------------------------------------------------------------

def boundaries2laps(pathBump, pathParts):
    # check if boundaries file exists and is readable
    checkAccess(pathBump, 'r')

    # load and check boundaries file
    boundFile = open(pathBump, 'r')
    checkOpen(boundFile, 'r')

    # create boundaries CSV reader
    reader = csv.reader(boundFile, delimiter=',', lineterminator='\n')

    # create and check laps file
    lapsFile = open(pathParts, 'w')
    checkOpen(lapsFile, 'w')

    # create laps CSV writer and write header
    writer = csv.writer(lapsFile, delimiter=',', lineterminator='\n')
    writer.writerow(['LapNo', 'Start', 'StartAcc', 'FastBump', 'FirstBump', 'RoundOne', 'SecondBump', 'WindowOne',
                     'Damage', 'WindowTwo', 'Stop', 'WindowThree', 'VisitBump', 'WindowFour', 'RoundTwo', 'End'])

    # PROCESS BOUNDARIES FILE AND CREATE LAPS FILE ---------------------------------------------------------------------

    # skip header row
    next(reader)

    # current lap counter, last boundary, and variables for time checking
    currLap = 1
    prevEnd = None
    currStart = None

    # check if first boundary data is static, pre-read row for next loop
    row = next(reader)
    lastBound = str2float(row[1])
    if not lastBound == 1: outputHandler('corrupted boundaries file - starts with 0', han.err)

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
                outputHandler('start time !< than end time in lap ' + str(currLap), han.err)

            # check if lap time is after previous lap
            if prevEnd is not None and currStart < prevEnd:
                outputHandler('end of previous lap !< than start of current lap ' + str(currLap), han.err)

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
    if not lastBound == 1: outputHandler('corrupted boundaries file - ends with 0', han.err)

    # close open CSV files
    boundFile.close()
    lapsFile.close()

    # return success
    return True


# MAIN------------------------------------------------------------------------------------------------------------------
if __name__ == "__main__":

    # create input arguments parser
    parser = argparse.ArgumentParser(description='Parse individual parts from binary bumpers file.')

    # add required arguments
    parser.add_argument('-b', '--bump', help='path to existing CSV bumpers file', type=str, required=True)
    parser.add_argument('-p', '--part', help='path to future CSV parts file', type=str, required=True)

    # load input arguments
    arguments = parser.parse_args()

    # compute directories
    pathBumpPy = Path(arguments.bound)
    pathPartPy = Path(arguments.laps)

    # call function
    boundaries2laps(pathBumpPy, pathPartPy)

# CODE END -------------------------------------------------------------------------------------------------------------