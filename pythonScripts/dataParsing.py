from commonFunctions import *
from pathlib import Path
import os  # file exploring
import math  # isnan()
import time  # execution time measurement
import csv

# DEFINITIONS ----------------------------------------------------------------------------------------------------------
CONFIG_LINES = 8
GRAVITY = 9.80581295200000
DECIMAL = 6
DELTAGPSUTC = 315964782  # current update for data after Jan 1 2017


# CLASSES --------------------------------------------------------------------------------------------------------------
class direc:
    def __index__(self, folder):
        self.MT = self.MT()
        self.UBLOX = self.UBLOX()
        self.folder = None
        self.config = None

    class MT:
        mtb = None
        input = None
        output = None
        tmp = None
        raw = None

    class UBLOX:
        ubx = None
        input = None
        output = None
        Llh = None
        Sol = None
        VNed = None


class conf:
    sampleRate = None
    movementStart = None
    accStart = None
    accStop = None
    gyroStart = None
    gyroStop = None
    magStart = None
    magStop = None


class proc:
    timeStepMT = 0
    period = 0
    magMax = 3 * [float('nan')]
    magMin = 3 * [float('nan')]
    magMean = 3 * [float('nan')]
    lastPacketMT = None
    lastSampleMT = None
    lastSampleUBX = None
    lastTimeUBX = 0


class timeStamps:
    start = None
    MTpre = None
    MTfinal = None
    UBOX = None


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

# save starting time for execution time computing
timeStamps.start = time.time()

# INPUT FILES HANDLING -------------------------------------------------------------------------------------------------
# input format: main -m <MT file> -u <UBLOX file> -o <output folder>

# check number of parameters and marking
if len(sys.argv) != 7: outputHandler("6 parameters expected, got " + str(len(sys.argv)), han.err)
if sys.argv[1] != "-o": outputHandler("first marker should be -o", han.err)
if sys.argv[3] != "-m": outputHandler("second marker should be -m", han.err)
if sys.argv[5] != "-u": outputHandler("third marker should be -u", han.err)

# compute directories
direc.folder = sys.argv[2]
direc.config = Path(direc.folder + "/config.txt")

direc.MT.mtb = Path(direc.folder + "/raw_data/" + sys.argv[4] + ".mtb")
direc.MT.input = Path(direc.folder + "/raw_data/" + sys.argv[4] + ".txt")
direc.MT.tmp = Path(direc.folder + "/parsed_data/MT_tmp.txt")
direc.MT.output = Path(direc.folder + "/parsed_data/MT_proc.csv")
direc.MT.raw = Path(direc.folder + "/raw_data/MT_raw.txt")

direc.UBLOX.ubx = Path(direc.folder + "/raw_data/" + sys.argv[6] + ".ubx")
direc.UBLOX.input = Path(direc.folder + "/raw_data/" + sys.argv[6])
direc.UBLOX.output = Path(direc.folder + "/parsed_data/UBOX_proc.csv")
direc.UBLOX.Llh = Path(direc.folder + "/raw_data/UBOX_Llh.txt")
direc.UBLOX.Sol = Path(direc.folder + "/raw_data/UBOX_Sol.txt")
direc.UBLOX.VNed = Path(direc.folder + "/raw_data/UBOX_VNed.txt")

# check if the MT mtb exists and is readable
if not os.path.isfile(direc.MT.mtb): outputHandler("mtb MT file does not exist", han.err)
if not os.access(direc.MT.mtb, os.R_OK): outputHandler("mtb MT file is not readable", han.err)

# check if the MT file exists and is readable
if not os.path.isfile(direc.MT.input): outputHandler("input MT file does not exist", han.err)
if not os.access(direc.MT.input, os.R_OK): outputHandler("input MT file is not readable", han.err)

# check if the UBLOX Llh exists and is readable
if not os.path.isfile(direc.UBLOX.input.with_suffix(".Llh")): outputHandler("input UBLOX Llh does not exist", han.err)
if not os.access(direc.UBLOX.input.with_suffix(".Llh"), os.R_OK): outputHandler("input UBLOX Llh is not readable",
                                                                                han.err)

# check if the UBLOX Llh exists and is readable
if not os.path.isfile(direc.UBLOX.input.with_suffix(".Sol")): outputHandler("input UBLOX Sol does not exist", han.err)
if not os.access(direc.UBLOX.input.with_suffix(".Sol"), os.R_OK): outputHandler("input UBLOX Sol is not readable",
                                                                                han.err)

# check if the UBLOX Llh exists and is readable
if not os.path.isfile(direc.UBLOX.input.with_suffix(".VNed")): outputHandler("input UBLOX VNed does not exist", han.err)
if not os.access(direc.UBLOX.input.with_suffix(".VNed"), os.R_OK): outputHandler("input UBLOX VNed is not readable",
                                                                                 han.err)

# check if config file exists and is readable
if not os.path.isfile(direc.config): outputHandler("config file does not exist", han.err)
if not os.access(direc.config, os.R_OK): outputHandler("config file is not readable", han.err)

# check if experiment directory is writable
if not os.access(direc.folder, os.W_OK): outputHandler("output experiment directory is not writable", han.err)

# rename MT and UBLOX input files
try:
    os.rename(direc.MT.mtb, Path(direc.folder + "/raw_data/MT.mtb"))
except (OSError, IOError):
    outputHandler("unable to rename MT mtb file", han.err)
try:
    os.rename(direc.MT.input, direc.MT.raw)
except (OSError, IOError):
    outputHandler("unable to rename MT raw file", han.err)

try:
    os.rename(direc.UBLOX.ubx, Path(direc.folder + "/raw_data/UBOX.ubx"))
except (OSError, IOError):
    outputHandler("unable to rename UBLOX ubx file", han.err)
try:
    os.rename(direc.UBLOX.input.with_suffix(".Llh"), direc.UBLOX.Llh)
except (OSError, IOError):
    outputHandler("unable to rename UBLOX Llh file", han.err)
try:
    os.rename(direc.UBLOX.input.with_suffix(".Sol"), direc.UBLOX.Sol)
except (OSError, IOError):
    outputHandler("unable to rename UBLOX Sol file", han.err)
try:
    os.rename(direc.UBLOX.input.with_suffix(".VNed"), direc.UBLOX.VNed)
except (OSError, IOError):
    outputHandler("unable to rename UBLOX VNed file", han.err)

outputHandler("all files loaded successfully", han.info)

# LOAD DATA FROM CONFIG FILE -------------------------------------------------------------------------------------------
# open config file
configFile = open(direc.config, 'r')
if not configFile.readable(): outputHandler("unable to read config file", han.err)

# process every line from file, count them for check
lineCnt = 0
for line in configFile:
    lineCnt = lineCnt + 1
    line = line.replace(' ', '')

    confName = None
    confVal = None
    # extract data name
    try:
        confName = line[:line.index("=")]
    except ValueError:
        outputHandler("corrupted config file ('=' check)", han.err)
    # extract data value
    try:
        confVal = line[line.index("=") + 1:]
    except ValueError:
        outputHandler("corrupted config file ('=' check)", han.err)
    # format to integer
    try:
        confVal = int(confVal)
    except ValueError:
        outputHandler("corrupted config file (int check)", han.err)

    # based on extracted data name, match value with data class
    if confName == "sampleRate":
        conf.sampleRate = confVal
    elif confName == "movementStart":
        conf.movementStart = confVal
    elif confName == "accStart":
        conf.accStart = confVal
    elif confName == "accStop":
        conf.accStop = confVal
    elif confName == "gyroStart":
        conf.gyroStart = confVal
    elif confName == "gyroStop":
        conf.gyroStop = confVal
    elif confName == "magStart":
        conf.magStart = confVal
    elif confName == "magStop":
        conf.magStop = confVal

# check if any value in data class remained as None
if conf.sampleRate is None:
    outputHandler("corrupted config file (None check 1)", han.err)
elif conf.movementStart is None:
    outputHandler("corrupted config file (None check 2)", han.err)
elif conf.accStart is None:
    outputHandler("corrupted config file (None check 3)", han.err)
elif conf.accStop is None:
    outputHandler("corrupted config file (None check 4)", han.err)
elif conf.gyroStart is None:
    outputHandler("corrupted config file (None check 5)", han.err)
elif conf.gyroStop is None:
    outputHandler("corrupted config file (None check 6)", han.err)
elif conf.magStart is None:
    outputHandler("corrupted config file (None check 7)", han.err)
elif conf.magStop is None:
    outputHandler("corrupted config file (None check 8)", han.err)

# check if config file has correct number of lines
if lineCnt != CONFIG_LINES: outputHandler("corrupted config file (# lines check)", han.err)

# compute time per step from frequency
proc.timeStepMT = 1 / conf.sampleRate * 10000
# check if it is a whole number
if proc.timeStepMT.is_integer():
    proc.timeStepMT = int(proc.timeStepMT)
else:
    outputHandler("computed time step is: " + str(proc.timeStepMT) + " - not an integer", han.err)

# compute period in ms from frequency
proc.period = 1 / conf.sampleRate * 1000

# print execution time of actual segment
outputHandler("initial phase executed in: " + str(round(time.time() - timeStamps.start, 4)) + " seconds", han.info)

# MT DATA PREPROCESSING ------------------------------------------------------------------------------------------------
outputHandler("starting MT pre-processing", han.info)
timeStamps.MTpre = time.time()
# data format: PacketCounter SampleTimeFine Acc_X Acc_Y Acc_Z Gyr_X Gyr_Y Gyr_Z Mag_X Mag_Y Mag_Z Pressure

# create tmp MT txt file
MTtmpFile = open(direc.MT.tmp, 'w')
if not MTtmpFile.writable(): outputHandler("unable to create MT tmp file", han.err)

# open input MT txt file
MTinFile = open(direc.MT.raw, 'r')
if not MTinFile.readable(): outputHandler("unable to read MT input file", han.err)

wantedData = ["PacketCounter", "SampleTimeFine", "Acc_X", "Acc_Y", "Acc_Z", "Gyr_X", "Gyr_Y", "Gyr_Z", "Mag_X", "Mag_Y",
              "Mag_Z", "Pressure"]
wantedDataID = len(wantedData) * [0]
rawDataHeader = ""

# track if header was already loaded
headerFlag = False

for lineCnt, line in enumerate(MTinFile, start=1):
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
            outputHandler("pressure not presented in MT raw file", han.warn, lineCnt)
        else:
            # artificial error print due to printing its information
            print("ERROR: MT raw file does not contain following data, line no: " + str(lineCnt))
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
        if proc.lastPacketMT is None:
            proc.lastPacketMT = currPacketCounter
        else:
            # new value must be greater than old value by exactly one
            if proc.lastPacketMT + 1 != currPacketCounter:
                # it might be jus overflow
                if proc.lastPacketMT != 65535 and currPacketCounter != 0:
                    outputHandler("discontinuity detected in PacketCounter", han.err, lineCnt)
            # update old value
            proc.lastPacketMT = currPacketCounter

        # check if SampleTimeFine is continuous
        if proc.lastSampleMT is None:
            proc.lastSampleMT = currSampleTimeFine
        else:
            # old != new-timeStep
            if proc.lastSampleMT + proc.timeStepMT != currSampleTimeFine:
                outputHandler("discontinuity detected in SampleTimeFine", han.err, lineCnt)
            # update old value
            proc.lastSampleMT = currSampleTimeFine

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
        MTtmpFile.write(outLine)

MTinFile.close()
MTtmpFile.close()

# compute means for magnetometer
for i in range(3):
    proc.magMean[i] = 0.5 * (proc.magMax[i] + proc.magMin[i])

# print execution time of actual segment
outputHandler("MT pre-processing executed in: " + str(round(time.time() - timeStamps.MTpre, 4)) + " seconds", han.info)

# MT DATA FINAL PROCESS ------------------------------------------------------------------------------------------------
outputHandler("starting MT final-processing", han.info)
timeStamps.MTfinal = time.time()

# reopen MT tmp file
MTtmpFile = open(direc.MT.tmp, 'r')
if not MTtmpFile.readable(): outputHandler("unable to read MT tmp file", han.err)

# create MT out file
MToutFile = open(direc.MT.output, 'w')
if not MToutFile.writable(): outputHandler("unable to create MT output file", han.err)

# create MT out CSV writer
header = ["time", "acc_X", "acc_Y", "acc_Z", "gyr_X", "gyr_Y", "gyr_Z", "mag_X", "mag_Y", "mag_Z", "pressure"]
MToutFileWriter = csv.writer(MToutFile, delimiter=',')
MToutFileWriter.writerow(header)

# line format: PacketCounter SampleTimeFine Acc_X Acc_Y Acc_Z Gyr_X Gyr_Y Gyr_Z Mag_X Mag_Y Mag_Z Pressure
# data format: time acc_X acc_Y acc_Z gyr_X gyr_Y gyr_Z mag_X mag_Y mag_Z pressure
for lineCnt, line in enumerate(MTtmpFile, start=1):
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
    MToutFileWriter.writerow(lineOut)

MTtmpFile.close()
MToutFile.close()

# remove no longer needed MT temporary file
try:
    os.remove(direc.MT.tmp)
except (OSError, IOError):
    outputHandler("unable to remove MT tmp file", han.warn)

# print execution time of actual segment
outputHandler("MT final-processing executed in: " + str(round(time.time() - timeStamps.MTfinal, 4)) + " seconds",
              han.info)

# UBLOX DATA PROCESS ---------------------------------------------------------------------------------------------------
outputHandler("starting UBLOX processing", han.info)
timeStamps.UBOX = time.time()

# open UBLOX Llh file
UBLOXllhFile = open(direc.UBLOX.Llh, 'r')
if not UBLOXllhFile.readable(): outputHandler("unable to read UBLOX Llh file", han.err)

# open UBLOX Sol file
UBLOXsolFile = open(direc.UBLOX.Sol, 'r')
if not UBLOXsolFile.readable(): outputHandler("unable to read UBLOX Sol file", han.err)

# open UBLOX VNed file
UBLOXvnedFile = open(direc.UBLOX.VNed, 'r')
if not UBLOXvnedFile.readable(): outputHandler("unable to read UBLOX VNed file", han.err)

# create UBLOX out file
UBLOXoutFile = open(direc.UBLOX.output, 'w')
if not UBLOXoutFile.writable(): outputHandler("unable to create UBLOX output file", han.err)

# create MT out CSV writer
header = ["time", "utc", "latNum", "lonNum", "height", "tow", "gpsFix", "satNum", "posDOP", "horAcc", "verAcc", "head",
          "speed", "lat", "lon"]
UBLOXoutFileWriter = csv.writer(UBLOXoutFile, delimiter=',')
UBLOXoutFileWriter.writerow(header)

# data: tow lat lon height (meanSeaLevel) horAcc verAcc Sol  data: iTow (fTow) weekNum gpsFix satNum (ecefX) (ecefY)
# (ecefZ) (ecefVX) (ecefVY) (ecefVZ) (posAccuracy) (speedAccuracy) posDop VNed data: towNum (vN) (vE) (vD) speed
# groundSpeed heading (speedAcc) (headingAcc) bracket means we do not use those data

# no need to check format, sequence and continuity of data - UBLOX binary parser already did it

# load lines from the files simultaneously
for lineLLh, lineSol, lineVNed in zip(UBLOXllhFile, UBLOXsolFile, UBLOXvnedFile):

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
    dataOut = 15 * [float('nan')]
    lineOut: [str] = 15 * [""]

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

    # copy time of the week
    dataOut[5] = lineLLh[0]

    # copy GPS fix
    dataOut[6] = lineSol[3]

    # copy number of used satellites
    dataOut[7] = lineSol[4]

    # position DOP divide by 100
    dataOut[8] = lineSol[13] / 100

    # copy horizontal and vertical accuracy
    dataOut[9] = lineLLh[5]
    dataOut[10] = lineLLh[6]

    # copy heading
    dataOut[11] = lineVNed[6]

    # speed from k/hod to m/s
    dataOut[12] = lineVNed[4] * 3.6

    # copy decimal latitude and longitude
    dataOut[13] = lineLLh[1]
    dataOut[14] = lineLLh[2]

    # convert to string and round
    for i in range(len(dataOut)):
        data = round(dataOut[i], DECIMAL)
        lineOut[i] = str(data)

    # write processed line into output file
    UBLOXoutFileWriter.writerow(lineOut)

UBLOXllhFile.close()
UBLOXsolFile.close()
UBLOXvnedFile.close()
UBLOXoutFile.close()

# print execution time of actual segment
outputHandler("UBOX processing executed in: " + str(round(time.time() - timeStamps.UBOX, 4)) + " seconds", han.info)

# CODE END -------------------------------------------------------------------------------------------------------------
outputHandler("Overall script execution time: " + str(round(time.time() - timeStamps.start, 4)) + " seconds", han.info)
