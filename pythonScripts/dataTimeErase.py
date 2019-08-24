from functions import *
from pathlib import Path

import argparse
import csv


# CLASSES --------------------------------------------------------------------------------------------------------------

class path:
    input = None
    orig = None
    tmp = None


# MAIN------------------------------------------------------------------------------------------------------------------

# FILES HANDLING -------------------------------------------------------------------------------------------------------

# create input arguments parser
parser = argparse.ArgumentParser(description='Keeps only specific time window of data.')

# add required arguments
parser.add_argument('-f', '--file', help='path to CSV data file', required=True)
parser.add_argument('-s', '--start', help='start time of window [s]', required=True)
parser.add_argument('-e', '--end', help='end time of window [s]', required=True)

# load input arguments
arguments = parser.parse_args()

# parse information from call arguments and compute directories
startTime = float(arguments.start)
endTime = float(arguments.end)

path.input = Path(arguments.file)
path.orig = Path(arguments.file.replace('.csv', '_original.csv'))
path.tmp = Path(arguments.file.replace('.csv', '_tmp.csv'))

# PROCESS DATA ---------------------------------------------------------------------------------------------------------

# check if data CSV file exists and is readable
checkAccess(path.input, 'r')

# open input CSV file
inFile = open(path.input, 'r')
if not inFile.readable(): outputHandler('unable to read input CSV file', han.err)

# create csv reader and read header
reader = csv.reader(inFile, delimiter=',')
header = next(reader)

# create output csv file
outFile = open(path.tmp, 'w')
if not outFile.writable(): outputHandler('unable to create output CSV file', han.err)

# create writer and write header
writer = csv.writer(outFile, delimiter=',', lineterminator='\n')
writer.writerow(header)

# copy only desired lines
for row in reader:
    if startTime <= float(row[0]) <= endTime:
        row[0] = str(float(row[0]) - startTime)
        writer.writerow(row)

# close files
inFile.close()
outFile.close()

# rename input file to *_original and tmp file to input
renameFile(path.input, path.orig)
renameFile(path.tmp, path.input)

# CODE END -------------------------------------------------------------------------------------------------------------
