from commonFunctions import *
from pathlib import Path
import sys
import os


# CLASSES --------------------------------------------------------------------------------------------------------------
class direc:
    main = None
    rawData = None
    parsedData = None
    photos = None
    processedData = None


class files:
    config = None
    report = None


# FUNCTIONS ------------------------------------------------------------------------------------------------------------
# process input of specified value with unit and check format
def processInput(normalName, unit, typeExpect):
    # repeat while not valid input
    while True:
        dataInput = input("Insert " + normalName + " [" + unit + "] (" + typeExpect + "): ")
        # check for a type
        try:
            if typeExpect == "integer":
                dataInput = int(dataInput)
            elif typeExpect == "float":
                dataInput = float(dataInput)
            else:
                outputHandler("unchecked input type", han.warn)
        except ValueError:
            outputHandler("entered value is not " + typeExpect + ", try again", han.warn)
            continue
        break
    # return rav, not a string
    return dataInput


# MAIN -----------------------------------------------------------------------------------------------------------------
# FOLDER AND FILES HANDLING --------------------------------------------------------------------------------------------

# check number of parameters and marking
if len(sys.argv) != 3: outputHandler("2 parameters expected, got " + str(len(sys.argv)-1), han.err)
if sys.argv[1] != "-o": outputHandler("third marker should be -o", han.err)

# compute folder name
folderName = sys.argv[2][sys.argv[2].rfind('\\') + 1:]

# compute directories
direc.main = sys.argv[2]
direc.rawData = Path(direc.main + "/raw_data")
direc.parsedData = Path(direc.main + "/parsed_data")
direc.photos = Path(direc.main + "/photo")
direc.processedData = Path(direc.main + "/processed_data")

# compute file names
files.config = Path(direc.main + "/config.txt")
files.report = Path(direc.main + "/report.txt")

# check if experiment folder exists then create it
if not os.path.exists(direc.main):
    try:
        os.makedirs(direc.main)
    except OSError:
        outputHandler("unable to create experiment directory", han.err)
    outputHandler("experiment directory created successfully", han.info)
else:
    outputHandler("experiment directory already exists", han.err)

# CREATE DIRECTORIES AMD FILES -----------------------------------------------------------------------------------------
# create raw data directory
try:
    os.makedirs(direc.rawData)
except OSError:
    outputHandler("unable to create raw data directory", han.err)

# create parsed data directory
try:
    os.makedirs(direc.parsedData)
except OSError:
    outputHandler("unable to create parsed data directory", han.err)

# create photos directory
try:
    os.makedirs(direc.photos)
except OSError:
    outputHandler("unable to create photos directory", han.err)

# create processed data directory
try:
    os.makedirs(direc.processedData)
except OSError:
    outputHandler("unable to create processed data directory", han.err)

# create config file
configFile = open(files.config, 'w')
if not configFile.writable(): outputHandler("unable to create config file", han.err)

# write config file headers
configFile.write("sampleRate = \n"
                 "movementStart = \n"
                 "accStart = \n"
                 "accStop = \n"
                 "gyroStart = \n"
                 "gyroStop = \n"
                 "magStart = \n"
                 "magStop = \n")
configFile.close()

# create report file
reportFile = open(files.report, 'w')
if not reportFile.writable(): outputHandler("unable to create report file", han.err)

# write config file headers
reportFile.write("experiment name = " + folderName + "\n"
                 "experiment date = \n"
                 "car number = \n"
                 "car brand = \n"
                 "car type = \n"
                 "car license plate = \n"
                 "dist. GPS to front = \n"
                 "dist. IMU to front = \n"
                 "number of loops = \n"
                 "notes = \n"
                 )
reportFile.close()

# MAYBE LATER
# file format: sampleRate = data \n movementStart = data \n data \n accStart = data \n accStop = data \n ...
# ... gyroStart = data \n gyroStop = data \n magStart = data /n magStop = data
#
#
# # sampleRate
# data = processInput("sample rate", "Hz", "integer")
# configFile.write("sampleRate = " + str(data) + '\n')
#
# # movementStart
# data = processInput("start of movement", "line no.", "integer")
# configFile.write("movementStart = " + str(data) + '\n')
#
# # accStart/Stop
# while True:
#     dataA = processInput("START of accelerometer", "line no.", "integer")
#     dataB = processInput("STOP  of accelerometer", "line no.", "integer")
#     # check validity of data
#     if dataB < dataA:
#         outputHandler("START line no. is bigger than STOP line no. , repeat the process", han.warn)
#         continue
#     # write data to config
#     configFile.write("accStart = " + str(dataA) + '\n')
#     configFile.write("accStop = " + str(dataB) + '\n')
#     break
#
# # gyroStart/Stop
# while True:
#     dataA = processInput("START of gyroscope", "line no.", "integer")
#     dataB = processInput("STOP  of gyroscope", "line no.", "integer")
#     # check validity of data
#     if dataB < dataA:
#         outputHandler("START line no. is bigger than STOP line no. , repeat the process", han.warn)
#         continue
#     # write data to config
#     configFile.write("gyroStart = " + str(dataA) + '\n')
#     configFile.write("gyroStop = " + str(dataB) + '\n')
#     break
#
# # magStart/Stop
# while True:
#     dataA = processInput("START of magnetometer", "line no.", "integer")
#     dataB = processInput("STOP  of magnetometer", "line no.", "integer")
#     # check validity of data
#     if dataB < dataA:
#         outputHandler("START line no. is bigger than STOP line no. , repeat the process", han.warn)
#         continue
#     # write data to config
#     configFile.write("magStart = " + str(dataA) + '\n')
#     configFile.write("magStop = " + str(dataB) + '\n')
#     break
