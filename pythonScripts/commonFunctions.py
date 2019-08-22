from enum import Enum
import os
import sys


# CLASSES AND OBJECTS---------------------------------------------------------------------------------------------------
class han(Enum):
    err = 0
    warn = 1
    info = 2
    confErr = 3


DEFAULT = object()


# FUNCTIONS ------------------------------------------------------------------------------------------------------------
def outputHandler(message, typeOut, lineNO=DEFAULT):
    if lineNO is DEFAULT:
        if typeOut == han.err:
            print("ERROR: " + message)
            sys.exit(-1),
        elif typeOut == han.warn:
            print("WARNING: " + message)
        elif typeOut == han.info:
            print("INFO: " + message)
        elif typeOut == han.confErr:
            print("ERROR: config handler : " + message)
            sys.exit(-1),

    else:
        if typeOut == han.err:
            print("ERROR: " + message + ", line no: " + str(lineNO))
            sys.exit(-1),
        elif typeOut == han.warn:
            print("WARNING: " + message + ", line no: " + str(lineNO))
        elif typeOut == han.info:
            print("INFO: " + message + ", line no: " + str(lineNO))
        elif typeOut == han.confErr:
            print("ERROR: config handler : " + message + ", line no: " + str(lineNO))
            sys.exit(-1),


# ----------------------------------------------------------------------------------------------------------------------

def checkAccess(filePath, accessType):
    # check if file exists
    if not os.path.exists(filePath):
        outputHandler("file/folder does not exists:\n" + str(filePath), han.err)

    # check specified access type

    if accessType == "r" or accessType == "R":
        if not os.access(filePath, os.R_OK):
            outputHandler("file/folder is not readable:\n" + str(filePath), han.err)

    elif accessType == "w" or accessType == "W":
        if not os.access(filePath, os.W_OK):
            outputHandler("file/folder is not writable:\n" + str(filePath), han.err)

    else:
        outputHandler("file/folder access type unrecognised", han.err)

# ----------------------------------------------------------------------------------------------------------------------

def readConfig(filePath, dataName):
    # check if config file exists and is readable
    if not os.path.isfile(filePath): outputHandler("config file does not exist", han.confErr)
    if not os.access(filePath, os.R_OK): outputHandler("config file is not readable", han.confErr)

    # open config file
    file = open(filePath, 'r')
    if not file.readable(): outputHandler("unable to read config file", han.confErr)

    confVal = None

    # read line by line
    for lineCnt, line in enumerate(file, start=1):

        # ignore human comment lines and empty lines
        if line[0] == '#' or line in ['\n', '\r\n']:
            pass
        else:
            line = line.replace(' ', '')

            # extract data name
            confName = ""
            try:
                confName = line[:line.index("=")]
            except ValueError:
                outputHandler("corrupted config file ('=' check)", han.confErr, lineCnt)

            # check if data name is wanted
            if confName == dataName:

                # extract data value and remove newline
                confVal = line[line.index("=") + 1: -1]

                # convert it to float, or leave as string
                try:
                    confVal = float(confVal)
                except ValueError:
                    pass

                # found and checked, exit function
                break

    # close file
    file.close()

    # return if it was found
    if confVal is not None:
        return confVal
    else:
        outputHandler("value '" + dataName + "' not found", han.confErr)


# ----------------------------------------------------------------------------------------------------------------------

def writeConfig(filePath, dataName, dataVal):
    # check if config file exists and is readable
    if not os.path.isfile(filePath): outputHandler("config file does not exist", han.confErr)
    if not os.access(filePath, os.R_OK): outputHandler("config file is not readable", han.confErr)

    # open config file
    file = open(filePath, 'r')
    if not file.readable(): outputHandler("unable to read config file", han.confErr)

    # create copy of config file and close it
    data = file.readlines()
    file.close()

    # use flag for success tracking
    flagWriten = False

    # loop thru data, find and edit specified value
    for i in range(len(data)):
        line = data[i]

        # ignore human comment lines and empty lines
        if line[0] == '#' or line in ['\n', '\r\n']:
            pass
        else:
            line = line.replace(' ', '')

            # extract data name
            confName = ""
            try:
                confName = line[:line.index("=")]
            except ValueError:
                outputHandler("corrupted config file ('=' check)", han.confErr, i)

            # check if data name is wanted
            if confName == dataName:
                # if not string, convert to string
                if not isinstance(dataVal, str):
                    dataVal = str(dataVal)

                # rewrite line in data
                data[i] = dataName + " = " + dataVal + "\n"

                # found and rewrote, exit function
                flagWriten = True
                break

    # check if data was modified
    if flagWriten is False: outputHandler("config file was not changed", han.confErr)

    # open config file
    file = open(filePath, 'w')
    if not file.writable(): outputHandler("unable to write to config file", han.confErr)

    # write changed data back to file
    file.writelines(data)

    # close file
    file.close()

    # return true as success
    return True

# ----------------------------------------------------------------------------------------------------------------------
