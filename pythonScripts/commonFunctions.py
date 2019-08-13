import sys
from enum import Enum


# CLASSES AND OBJECTS---------------------------------------------------------------------------------------------------
class han(Enum):
    err = 0
    warn = 1
    info = 2


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

    else:
        if typeOut == han.err:
            print("ERROR: " + message + ", line no: " + str(lineNO))
            sys.exit(-1),
        elif typeOut == han.warn:
            print("WARNING: " + message + ", line no: " + str(lineNO))
        elif typeOut == han.info:
            print("INFO: " + message + ", line no: " + str(lineNO))
