from functions import *
from pathlib import Path

import argparse
import csv


# FUNCTIONS ------------------------------------------------------------------------------------------------------------

def bumpers2laps(pathBump, pathLaps, pathBumpTimes, pathBumpSizes):
    # check if files exists and is readable
    checkAccess(pathBump, 'r')
    checkAccess(pathLaps, 'r')

    # load and check bumpers file
    bumpFile = open(pathBump, 'r')
    checkOpen(bumpFile, 'r')

    # load and check laps file
    lapsFile = open(pathLaps, 'r')
    checkOpen(lapsFile, 'r')

    # create bumpers CSV reader and skip header
    readerBump = csv.reader(bumpFile, delimiter=',', lineterminator='\n')
    next(readerBump)

    # create laps CSV reader and skip header
    readerLaps = csv.reader(lapsFile, delimiter=',', lineterminator='\n')
    next(readerLaps)

    # create and check parts times file
    partsTimesFile = open(pathBumpTimes, 'w')
    checkOpen(partsTimesFile, 'w')

    # create and check parts sizes file
    partsSizesFile = open(pathBumpSizes, 'w')
    checkOpen(partsSizesFile, 'w')

    # create parts times CSV writer and write header
    writerTimes = csv.writer(partsTimesFile, delimiter=',', lineterminator='\n')
    writerTimes.writerow(['LapNo', 'Start', 'StartTurn', 'FastFirstBump', 'PreRound', 'RoundOne', 'SecondBump', 'Curve',
                          'WindowOne', 'CrossOne', 'VisitBump', 'CrossTwo', 'WindowTwo', 'RoundTwo', 'WindowThree'])

    # create parts sizes CSV writer and write header
    writerSizes = csv.writer(partsSizesFile, delimiter=',', lineterminator='\n')
    writerSizes.writerow(['LapNo', 'Start', 'StartTurn', 'FastFirstBump', 'PreRound', 'RoundOne', 'SecondBump', 'Curve',
                          'WindowOne', 'CrossOne', 'VisitBump', 'CrossTwo', 'WindowTwo', 'RoundTwo', 'WindowThree'])

    # PROCESS BOUNDARIES FILE AND CREATE LAPS FILE ---------------------------------------------------------------------

    # create data file and support variables
    data = 15 * [float(0)]
    lastBump = True
    cursor = 0
    skipFlag = False

    # read first lap data
    lap = list(map(float, next(readerLaps)))

    # loop thru whole bumper file
    for bump in readerBump:
        # retype row from string to float
        bump = list(map(float, bump))

        # check if we are inside current lap and change occurred
        if lap[1] <= bump[0] <= lap[2] and bump[5] != lastBump:
            # update last bump
            lastBump = bump[5]

            # move cursor to right
            cursor += 1

            # check if we just found first change and 'LapNo' field need to be assigned
            if cursor == 1: data[0] = int(lap[0])

            # check if we are skipping 7 change
            if cursor == 7 and skipFlag is False:
                cursor -= 1
                skipFlag = True
                continue

            # check for cursor overflow
            if cursor > 14: outputHandler("Cursor overflew at time: " + str(bump[0]), han.err)

            # write current time to current cursor
            data[cursor] = float(bump[0])

        # check if we just ended current lap
        if bump[0] == lap[2]:
            # check if data contains 'None'
            if 0 in data: outputHandler("Corrupted data detected at time: " + str(bump[0]), han.err)

            # write data to CSV time file
            writerTimes.writerow(data)

            # compute parts sizes
            for i in range(1, 14):
                data[i] = data[i + 1] - data[i]
            data[0] = int(lap[0])
            data[14] = lap[2] - data[14]

            # check if is not zero or negative
            for item in data:
                if item <= 0: outputHandler("Corrupted length in lap: " + str(data[0]), han.err)

            # check if total length matches with laps file
            if round(sum(data[1:]), 2) != lap[3]:
                outputHandler("Length does not match in lap: " + str(data[0]), han.err)

            # write data to CSV time file
            writerSizes.writerow(data)

            # restore data and support variables for new lap
            data = 15 * [float(0)]
            lastBump = True
            cursor = 0
            skipFlag = False

            # try to read next lap if exists
            try:
                lap = list(map(float, next(readerLaps)))
            except StopIteration:
                break

    # close open CSV files
    bumpFile.close()
    lapsFile.close()
    partsTimesFile.close()
    partsSizesFile.close()

    # return success
    return True


# MAIN------------------------------------------------------------------------------------------------------------------
if __name__ == "__main__":
    # create input arguments parser
    parser = argparse.ArgumentParser(description='Parse individual parts from binary bumpers file.')

    # add required arguments
    parser.add_argument('-b', '--bump', help='path to existing CSV bumpers file', type=str, required=True)
    parser.add_argument('-l', '--laps', help='path to existing CSV laps file', type=str, required=True)
    parser.add_argument('-p', '--part', help='path to future CSV parts file', type=str, required=True)

    # load input arguments
    arguments = parser.parse_args()

    # compute directories
    pathBumpPy = Path(arguments.bump)
    pathLapsPy = Path(arguments.laps)
    pathBumpTimesPy = Path(arguments.part.replace('.csv', '_times.csv'))
    pathBumpSizesPy = Path(arguments.part.replace('.csv', '_sizes.csv'))

    # call function
    bumpers2laps(pathBumpPy, pathLapsPy, pathBumpTimesPy, pathBumpSizesPy)

# CODE END -------------------------------------------------------------------------------------------------------------
