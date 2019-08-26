from functions import *
from pathlib import Path

import argparse
import csv


# CLASSES --------------------------------------------------------------------------------------------------------------

class window:
    start = None
    end = None
    type = None


# MAIN------------------------------------------------------------------------------------------------------------------

# FILES HANDLING -------------------------------------------------------------------------------------------------------

# create input arguments parser
parser = argparse.ArgumentParser(description='Keeps only specific time window of data.')

# add required arguments
parser.add_argument('-f', '--file', help='path to CSV boundaries file', type=str, required=True)
parser.add_argument('-s', '--start', help='start time of window [s]', type=float, required=True)
parser.add_argument('-e', '--end', help='end time of window [s]', type=float, required=True)
parser.add_argument('-t', '--type', help='type of adding window [static/mobile]', type=str, required=True)

# load input arguments
arguments = parser.parse_args()

# parse information from call arguments
pathIn = Path(arguments.file)
pathTmp = Path(arguments.file.replace('.csv', '_tmp.csv'))
window.start = float(arguments.start)
window.end = float(arguments.end)

# check argument 'type'
if arguments.type not in ['static', 'mobile']:
    outputHandler("window type not recognised", han.err)

# change it to binary
if arguments.type == 'static':
    window.type = 1
else:
    window.type = 0

# PROCESS DATA ---------------------------------------------------------------------------------------------------------

# check if data CSV file exists and is readable
checkAccess(pathIn, 'r')

# open input CSV file
inFile = open(pathIn, 'r')
checkOpen(inFile, 'r')

# create csv reader and read header
reader = csv.reader(pathIn, delimiter=',')
header = next(reader)

# create output csv file
outFile = open(pathTmp, 'w')
checkOpen(pathTmp, 'w')

# create writer and write header
writer = csv.writer(outFile, delimiter=',', lineterminator='\n')
writer.writerow(header)

# copy every line and check for time
for row in reader:
    if window.start <= float(row[0]) <= window.end:
        row[1] = window.type
    writer.writerow(row)

# close files
inFile.close()
outFile.close()

# remove input file
removeFile(pathIn)

# rename tmp to input file
renameFile(pathTmp, pathIn)

# CODE END -------------------------------------------------------------------------------------------------------------
