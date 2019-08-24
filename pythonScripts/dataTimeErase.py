from functions import *
from pathlib import Path

import csv

# check number of parameters and marking
if len(sys.argv) != 5: outputHandler("4 parameters expected, got " + str(len(sys.argv) - 1), han.err)
if sys.argv[1] != "-o": outputHandler("first marker should be -o", han.err)
if sys.argv[3] != "-s": outputHandler("second marker should be -s", han.err)
if sys.argv[3] != "-e": outputHandler("third marker should be -e", han.err)

# parse information from call arguments
pathIn = Path(sys.argv[2])
pathOut = Path(sys.argv[2].replace(".csv", "_edited.csv"))
startTime = float(sys.argv[4])
endTime = float(sys.argv[6])

# check if data CSV file exists and is readable
if not os.path.isfile(pathIn): outputHandler("input CSV file does not exist", han.err)
if not os.access(pathIn, os.R_OK): outputHandler("input CSV file is not readable", han.err)

# open input CSV file
inFile = open(pathIn, 'r')
if not inFile.readable(): outputHandler("unable to read input CSV file", han.err)

# create csv reader and read header
reader = csv.reader(inFile, delimiter=',')
header = next(reader)

# create output csv file
outFile = open(pathOut, 'w')
if not outFile.writable(): outputHandler("unable to create output CSV file", han.err)

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
