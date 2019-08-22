from commonFunctions import *
from pathlib import Path

import math  # isnan()
import os  # file exploring
import time  # execution time measurement
import csv

# DEFINITIONS ----------------------------------------------------------------------------------------------------------
CONFIG_LINES = 8
GRAVITY = 9.80581295200000
DECIMAL = 6
DELTAGPSUTC = 315964782  # current update for data after Jan 1 2017


# CLASSES --------------------------------------------------------------------------------------------------------------
class path:
    def __index__(self, folder):
        self.IMU = self.IMU()
        self.GPS = self.GPS()
        self.experiment = None
        self.config = None

    class IMU:
        IMU = None
        input = None
        output = None
        tmp = None
        raw = None

    class GPS:
        GPS = None
        input = None
        output = None
        Llh = None
        Sol = None
        VNed = None


class conf:
    sampleRate = None


class proc:
    timeStepIMU = 0
    period = 0
    magMax = 3 * [float('nan')]
    magMin = 3 * [float('nan')]
    magMean = 3 * [float('nan')]
    lastPacketIMU = None
    lastSampleIMU = None
    lastSampleUBX = None
    lastTimeUBX = 0


class timeStamps:
    start = None
    IMUpre = None
    IMUfinal = None
    GPS = None


# FUNCTIONS ------------------------------------------------------------------------------------------------------------
def fixNaN(string) -> str:
    # string = string.replace("NaN", "nan")
    string = string.replace(",\n", ",nan\n")
    string = string.replace(",,", ",nan,")
    string = string.replace(",,", ",nan,")
    return string


def isStrNum(value) -> bool:
    try:
        float(value)
        return True
    except ValueError:
        return False


def strToFloat(value) -> float:
    try:
        value = float(value)
    except ValueError:
        value = float('nan')
    return value


def isNanArray(array) -> bool:
    for x in array:
        if math.isnan(x):
            return True
    return False


def countNoneArray(array) -> int:
    counter = 0
    for x in array:
        if x is None:
            counter += 1
    return counter


def decToDMS(degrees):
    positive = degrees >= 0
    degrees = abs(degrees)
    minutes, seconds = divmod(degrees * 3600, 60)
    degrees, minutes = divmod(minutes, 60)
    degrees = degrees if positive else -degrees
    return degrees, minutes, seconds


# MAIN------------------------------------------------------------------------------------------------------------------
timeStamps.start = time.time()

# INPUT FILES HANDLING -------------------------------------------------------------------------------------------------
# input format: main -o <experiment folder> -m <IMU name> -u <GPS name>

# check number of parameters and marking
if len(sys.argv) != 7: outputHandler("6 parameters expected, got " + str(len(sys.argv) - 1), han.err)
if sys.argv[1] != "-o": outputHandler("first marker should be -o", han.err)
if sys.argv[3] != "-m": outputHandler("second marker should be -m", han.err)
if sys.argv[5] != "-u": outputHandler("third marker should be -u", han.err)

# compute directories
path.experiment = sys.argv[2]
path.config = Path(path.experiment + "/config.txt")

path.IMU.mtb = Path(path.experiment + "/raw_data/" + sys.argv[4] + ".mtb")
path.IMU.input = Path(path.experiment + "/raw_data/" + sys.argv[4] + ".txt")
path.IMU.tmp = Path(path.experiment + "/parsed_data/IMU_tmp.txt")
path.IMU.output = Path(path.experiment + "/parsed_data/IMU_parsed.csv")
path.IMU.raw = Path(path.experiment + "/raw_data/IMU_raw.txt")

path.GPS.GPS = Path(path.experiment + "/raw_data/" + sys.argv[6] + ".ubx")
path.GPS.input = Path(path.experiment + "/raw_data/" + sys.argv[6])
path.GPS.output = Path(path.experiment + "/parsed_data/GPS_parsed.csv")
path.GPS.Llh = Path(path.experiment + "/raw_data/GPS_Llh.txt")
path.GPS.Sol = Path(path.experiment + "/raw_data/GPS_Sol.txt")
path.GPS.VNed = Path(path.experiment + "/raw_data/GPS_VNed.txt")

# check if the IMU mtb exists and is readable
if not os.path.isfile(path.IMU.mtb): outputHandler("mtb IMU file does not exist", han.err)
if not os.access(path.IMU.mtb, os.R_OK): outputHandler("mtb IMU file is not readable", han.err)

# check if the IMU file exists and is readable
if not os.path.isfile(path.IMU.input): outputHandler("input IMU file does not exist", han.err)
if not os.access(path.IMU.input, os.R_OK): outputHandler("input IMU file is not readable", han.err)

# check if the GPS Llh exists and is readable
if not os.path.isfile(path.GPS.input.with_suffix(".Llh")): outputHandler("input GPS Llh does not exist", han.err)
if not os.access(path.GPS.input.with_suffix(".Llh"), os.R_OK): outputHandler("input GPS Llh is not readable",
                                                                             han.err)

# check if the GPS Llh exists and is readable
if not os.path.isfile(path.GPS.input.with_suffix(".Sol")): outputHandler("input GPS Sol does not exist", han.err)
if not os.access(path.GPS.input.with_suffix(".Sol"), os.R_OK): outputHandler("input GPS Sol is not readable",
                                                                             han.err)

# check if the GPS Llh exists and is readable
if not os.path.isfile(path.GPS.input.with_suffix(".VNed")): outputHandler("input GPS VNed does not exist", han.err)
if not os.access(path.GPS.input.with_suffix(".VNed"), os.R_OK): outputHandler("input GPS VNed is not readable",
                                                                              han.err)

# check if config file exists and is readable
if not os.path.isfile(path.config): outputHandler("config file does not exist", han.err)
if not os.access(path.config, os.R_OK): outputHandler("config file is not readable", han.err)

# check if experiment directory is writable
if not os.access(path.experiment, os.W_OK): outputHandler("output experiment directory is not writable", han.err)

# LOAD DATA FROM CONFIG FILE AND RENAME FILES --------------------------------------------------------------------------

# load sample rate from config file
conf.sampleRate = readConfig(path.config, 'sample_rate')

# check if is valid
if math.isnan(conf.sampleRate):
    outputHandler("loaded sample rate is NaN value", han.err)

# compute time per step from frequency
proc.timeStepIMU = 1 / conf.sampleRate * 10000

# check if it is a whole number
if proc.timeStepIMU.is_integer():
    proc.timeStepIMU = int(proc.timeStepIMU)
else:
    outputHandler("computed time step is: " + str(proc.timeStepIMU) + " - not an integer", han.err)

# compute period in ms from frequency
proc.period = 1 / conf.sampleRate * 1000

# rename IMU and GPS input files
try:
    os.rename(path.IMU.mtb, Path(path.experiment + "/raw_data/IMU.mtb"))
except (OSError, IOError):
    outputHandler("unable to rename IMU mtb file", han.err)
try:
    os.rename(path.IMU.input, path.IMU.raw)
except (OSError, IOError):
    outputHandler("unable to rename IMU raw file", han.err)

try:
    os.rename(path.GPS.GPS, Path(path.experiment + "/raw_data/GPS.ubx"))
except (OSError, IOError):
    outputHandler("unable to rename GPS ubx file", han.err)
try:
    os.rename(path.GPS.input.with_suffix(".Llh"), path.GPS.Llh)
except (OSError, IOError):
    outputHandler("unable to rename GPS Llh file", han.err)
try:
    os.rename(path.GPS.input.with_suffix(".Sol"), path.GPS.Sol)
except (OSError, IOError):
    outputHandler("unable to rename GPS Sol file", han.err)
try:
    os.rename(path.GPS.input.with_suffix(".VNed"), path.GPS.VNed)
except (OSError, IOError):
    outputHandler("unable to rename GPS VNed file", han.err)

outputHandler("all files loaded successfully", han.info)

# IMU DATA PREPROCESSING -----------------------------------------------------------------------------------------------
outputHandler("starting IMU pre-processing", han.info)
timeStamps.IMUpre = time.time()
# data format: PacketCounter SampleTimeFine Acc_X Acc_Y Acc_Z Gyr_X Gyr_Y Gyr_Z Mag_X Mag_Y Mag_Z Pressure

# create tmp IMU txt file
IMUtmpFile = open(path.IMU.tmp, 'w')
if not IMUtmpFile.writable(): outputHandler("unable to create IMU tmp file", han.err)

# open input IMU txt file
IMUinFile = open(path.IMU.raw, 'r')
if not IMUinFile.readable(): outputHandler("unable to read IMU input file", han.err)

wantedData = ["PacketCounter", "SampleTimeFine", "Acc_X", "Acc_Y", "Acc_Z", "Gyr_X", "Gyr_Y", "Gyr_Z", "Mag_X", "Mag_Y",
              "Mag_Z", "Pressure"]
wantedDataID = len(wantedData) * [0]
rawDataHeader = ""

# track if header was already loaded
headerFlag = False

for lineCnt, line in enumerate(IMUinFile, start=1):
    # fix missing nan markers
    line = fixNaN(line)

    # ignore data info
    if headerFlag is False and line.find("// ") != -1:
        continue

    # find out data sequence and process it
    elif headerFlag is False and line.find("PacketCounter") != -1:
        # rewrite flag
        headerFlag = True
        # strip header to names array
        rawDataHeader = [x.strip() for x in line.split(',')]
        # fill the wantedDataID with indexes of the particular data from txt file
        for i in range(len(wantedData)):
            try:
                index = int(rawDataHeader.index(wantedData[i]))
            except ValueError:
                index = None
            wantedDataID[i] = index

        # check if all needed data were supplied, pressure is optional
        cnt = countNoneArray(wantedDataID)
        if cnt == 0:
            pass
        elif cnt == 1 and wantedDataID[-1] is None:
            outputHandler("pressure not presented in IMU raw file", han.warn, lineCnt)
        else:
            # artificial error print due to printing its information
            print("ERROR: IMU raw file does not contain following data, line no: " + str(lineCnt))
            for i in range(len(wantedDataID)):
                if wantedDataID[i] is None: print("- " + wantedData[i])
            sys.exit(-1)

    # check format of every line, check if PacketCounter and SampleTimeFine are continuous
    else:
        # separate values in line
        line = [x.strip() for x in line.split(',')]

        # check if enough data is presented
        if len(line) != len(rawDataHeader):
            outputHandler("line length do not match header length", han.err, lineCnt)

        # check if PacketCounter and SampleTimeFine are valid
        if not isStrNum(line[wantedDataID[0]]):
            outputHandler("corrupted line on PacketCounter", han.err, lineCnt)
        if not isStrNum(line[wantedDataID[1]]):
            outputHandler("corrupted line on SampleTimeFine", han.err, lineCnt)

        # check if every data in line is numerical, replace with 'nan'
        flagNum = 0
        for i in range(len(line)):
            if not isStrNum(line[i]):
                line[i] = "nan"
                flagNum = flagNum + 1
        if flagNum: outputHandler(str(flagNum) + " of data is 'nan'", han.warn, lineCnt)

        # export PacketCounter and SampleTimeFine to float
        currPacketCounter = strToFloat(line[wantedDataID[0]])
        currSampleTimeFine = strToFloat(line[wantedDataID[1]])

        # check if PacketCounter is continuous, it will overflow after 65535
        if proc.lastPacketIMU is None:
            proc.lastPacketIMU = currPacketCounter
        else:
            # new value must be greater than old value by exactly one
            if proc.lastPacketIMU + 1 != currPacketCounter:
                # it might be jus overflow
                if proc.lastPacketIMU != 65535 and currPacketCounter != 0:
                    outputHandler("discontinuity detected in PacketCounter", han.err, lineCnt)
            # update old value
            proc.lastPacketIMU = currPacketCounter

        # check if SampleTimeFine is continuous
        if proc.lastSampleIMU is None:
            proc.lastSampleIMU = currSampleTimeFine
        else:
            # old != new-timeStep
            if proc.lastSampleIMU + proc.timeStepIMU != currSampleTimeFine:
                outputHandler("discontinuity detected in SampleTimeFine", han.err, lineCnt)
            # update old value
            proc.lastSampleIMU = currSampleTimeFine

        # everything was fine so far, update mag extremes for future processing
        if isNanArray(proc.magMax) or isNanArray(proc.magMin):
            for i in range(3):
                proc.magMax[i] = strToFloat(line[wantedDataID[8 + i]])
                proc.magMin[i] = strToFloat(line[wantedDataID[8 + i]])
        else:
            for i in range(3):
                if proc.magMax[i] < strToFloat(line[wantedDataID[8 + i]]):
                    proc.magMax[i] = strToFloat(line[wantedDataID[8 + i]])
                if proc.magMin[i] > strToFloat(line[wantedDataID[8 + i]]):
                    proc.magMin[i] = strToFloat(line[wantedDataID[8 + i]])

        # recreate line in standard sequence for future processing
        outLine = len(wantedData) * ["nan"]
        for i in range(len(wantedData)):
            if wantedDataID[i] is None:
                outLine[i] = "nan"
            else:
                outLine[i] = str(line[wantedDataID[i]])

        # write processed line into output file
        outLine = ' '.join(outLine) + '\n'
        IMUtmpFile.write(outLine)

IMUinFile.close()
IMUtmpFile.close()

# compute means for magnetometer
for i in range(3):
    proc.magMean[i] = 0.5 * (proc.magMax[i] + proc.magMin[i])

# print execution time of actual segment
outputHandler("IMU pre-processing executed in: " + str(round(time.time() - timeStamps.IMUpre, 4)) + " seconds",
              han.info)

# IMU DATA FINAL PROCESS -----------------------------------------------------------------------------------------------
outputHandler("starting IMU final-processing", han.info)
timeStamps.IMUfinal = time.time()

# reopen IMU tmp file
IMUtmpFile = open(path.IMU.tmp, 'r')
if not IMUtmpFile.readable(): outputHandler("unable to read IMU tmp file", han.err)

# create IMU out file
IMUoutFile = open(path.IMU.output, 'w')
if not IMUoutFile.writable(): outputHandler("unable to create IMU output file", han.err)

# create IMU out CSV writer
header = ["Time", "AccX", "AccY", "AccZ", "GyrX", "GyrY", "GyrZ", "MagX", "MagY", "MagZ", "Pres"]
IMUoutFileWriter = csv.writer(IMUoutFile, delimiter=',', lineterminator='\n')
IMUoutFileWriter.writerow(header)

# line format: PacketCounter SampleTimeFine Acc_X Acc_Y Acc_Z Gyr_X Gyr_Y Gyr_Z Mag_X Mag_Y Mag_Z Pressure
# data format: time acc_X acc_Y acc_Z gyr_X gyr_Y gyr_Z mag_X mag_Y mag_Z pressure
for lineCnt, line in enumerate(IMUtmpFile, start=1):
    # separate values in line
    line = [x.strip() for x in line.split(' ')]

    # change line data to float
    for i in range(len(line)):
        line[i] = strToFloat(line[i])

    # prepare output array
    dataOut = 11 * [float('nan')]
    lineOut: [str] = 11 * [""]

    # time in s
    dataOut[0] = ((lineCnt - 1) * proc.period) / 1000

    # accelerometer - divide with gravity constant
    for i in range(3):
        dataOut[1 + i] = line[2 + i] / GRAVITY

    # gyroscope - nothing to do
    for i in range(3):
        dataOut[4 + i] = line[5 + i]

    # magnetometer - calibrate with previously calculated means
    for i in range(3):
        dataOut[7 + i] = line[8 + i] - proc.magMean[i]

    # pressure - nothing to do
    dataOut[10] = line[11]

    # convert to string and round
    for i in range(len(dataOut)):
        data = round(dataOut[i], DECIMAL)
        lineOut[i] = str(data)

    # write processed line into output file
    IMUoutFileWriter.writerow(lineOut)

IMUtmpFile.close()
IMUoutFile.close()

# remove no longer needed IMU temporary file
try:
    os.remove(path.IMU.tmp)
except (OSError, IOError):
    outputHandler("unable to remove IMU tmp file", han.warn)

# print execution time of actual segment
outputHandler("IMU final-processing executed in: " + str(round(time.time() - timeStamps.IMUfinal, 4)) + " seconds",
              han.info)

# GPS DATA PROCESS ---------------------------------------------------------------------------------------------------
outputHandler("starting GPS processing", han.info)
timeStamps.GPS = time.time()

# open GPS Llh file
GPSllhFile = open(path.GPS.Llh, 'r')
if not GPSllhFile.readable(): outputHandler("unable to read GPS Llh file", han.err)

# open GPS Sol file
GPSsolFile = open(path.GPS.Sol, 'r')
if not GPSsolFile.readable(): outputHandler("unable to read GPS Sol file", han.err)

# open GPS VNed file
GPSvnedFile = open(path.GPS.VNed, 'r')
if not GPSvnedFile.readable(): outputHandler("unable to read GPS VNed file", han.err)

# create GPS out file
GPSoutFile = open(path.GPS.output, 'w')
if not GPSoutFile.writable(): outputHandler("unable to create GPS output file", han.err)

# create IMU out CSV writer
header = ["Time", "UTC", "LatNum", "LonNum", "Height", "GPSfix", "SatNum", "PosDOP", "HorAcc", "VerAcc", "Head",
          "Speed", "Lat", "Lon"]
GPSoutFileWriter = csv.writer(GPSoutFile, delimiter=',', lineterminator='\n')
GPSoutFileWriter.writerow(header)

# data: tow lat lon height (meanSeaLevel) horAcc verAcc Sol  data: iTow (fTow) weekNum gpsFix satNum (ecefX) (ecefY)
# (ecefZ) (ecefVX) (ecefVY) (ecefVZ) (posAccuracy) (speedAccuracy) posDop VNed data: towNum (vN) (vE) (vD) speed
# groundSpeed heading (speedAcc) (headingAcc) bracket means we do not use those data

# no need to check format, sequence and continuity of data - GPS binary parser already did it

# load lines from the files simultaneously
for lineLLh, lineSol, lineVNed in zip(GPSllhFile, GPSsolFile, GPSvnedFile):

    # separate values in lines
    lineLLh = [x.strip() for x in lineLLh.split(' ')]
    lineSol = [x.strip() for x in lineSol.split(' ')]
    lineVNed = [x.strip() for x in lineVNed.split(' ')]

    # change line data to float
    for i in range(len(lineLLh)):
        lineLLh[i] = strToFloat(lineLLh[i])
    for i in range(len(lineSol)):
        lineSol[i] = strToFloat(lineSol[i])
    for i in range(len(lineVNed)):
        lineVNed[i] = strToFloat(lineVNed[i])

    # prepare output array
    dataOut = len(header) * [float('nan')]
    lineOut: [str] = len(header) * [""]

    # compute GPS time
    tmpGPS = lineSol[2] * 7 * 24 * 60 * 60 + lineLLh[0] / 1000
    # compute UTC time
    dataOut[1] = tmpGPS + DELTAGPSUTC

    # compute time in s
    if proc.lastSampleUBX is None:
        dataOut[0] = 0
    else:
        dataOut[0] = proc.lastTimeUBX + (dataOut[1] - proc.lastSampleUBX)
    proc.lastTimeUBX = dataOut[0]
    proc.lastSampleUBX = dataOut[1]

    # compute latitude degrees
    tmpDMS = decToDMS(lineLLh[1])
    dataOut[2] = tmpDMS[0] * 100 + tmpDMS[1] + round(tmpDMS[2] / 100, DECIMAL)

    # compute longitude degrees
    tmpDMS = decToDMS(lineLLh[2])
    dataOut[3] = tmpDMS[0] * 100 + tmpDMS[1] + round(tmpDMS[2] / 100, DECIMAL)

    # copy height
    dataOut[4] = lineLLh[3]

    # copy GPS fix
    dataOut[5] = lineSol[3]

    # copy number of used satellites
    dataOut[6] = lineSol[4]

    # position DOP divide by 100
    dataOut[7] = lineSol[13] / 100

    # copy horizontal and vertical accuracy
    dataOut[8] = lineLLh[5]
    dataOut[9] = lineLLh[6]

    # copy heading
    dataOut[10] = lineVNed[6]

    # speed from k/hod to m/s
    dataOut[11] = lineVNed[4] * 3.6

    # copy decimal latitude and longitude
    dataOut[12] = lineLLh[1]
    dataOut[13] = lineLLh[2]

    # convert to string and round
    for i in range(len(dataOut)):
        data = round(dataOut[i], DECIMAL)
        lineOut[i] = str(data)

    # write processed line into output file
    GPSoutFileWriter.writerow(lineOut)

GPSllhFile.close()
GPSsolFile.close()
GPSvnedFile.close()
GPSoutFile.close()

# print execution time of actual segment
outputHandler("GPS processing executed in: " + str(round(time.time() - timeStamps.GPS, 4)) + " seconds", han.info)

# CODE END -------------------------------------------------------------------------------------------------------------
outputHandler("overall script execution time: " + str(round(time.time() - timeStamps.start, 4)) + " seconds", han.info)
