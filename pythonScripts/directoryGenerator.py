from functions import *
from pathlib import Path
from shutil import copyfile
import os


# CLASSES --------------------------------------------------------------------------------------------------------------
class direc:
    main = None
    rawData = None
    parsedData = None
    photos = None
    processedData = None
    finalData = None


class files:
    configSource = None
    configTarget = None
    reportSource = None
    reportTarget = None


# MAIN -----------------------------------------------------------------------------------------------------------------
# FOLDER AND FILES HANDLING --------------------------------------------------------------------------------------------

# check number of parameters and marking
if len(sys.argv) != 3: outputHandler("2 parameters expected, got " + str(len(sys.argv) - 1), han.err)
if sys.argv[1] != "-o": outputHandler("third marker should be -o", han.err)

# compute folder name
folderName = sys.argv[2][sys.argv[2].rfind('\\') + 1:]

# compute directories
direc.main = sys.argv[2]
direc.rawData = Path(direc.main + "/raw_data")
direc.parsedData = Path(direc.main + "/parsed_data")
direc.photos = Path(direc.main + "/photos")
direc.processedData = Path(direc.main + "/processed_data")
direc.finalData = Path(direc.main + "/final_data")

# compute file names
files.configSource = Path(os.getcwd() + "/txtTemplates/configTemplate.txt")
files.configTarget = Path(direc.main + "/config.txt")
files.reportSource = Path(os.getcwd() + "/txtTemplates/reportTemplate.txt")
files.reportTarget = Path(direc.main + "/report.txt")

# check if txt template file exists
if not os.path.isfile(files.configSource): outputHandler("config template txt file does not exist", han.err)
if not os.path.isfile(files.reportSource): outputHandler("report template txt file does not exist", han.err)

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

# create final data directory
try:
    os.makedirs(direc.finalData)
except OSError:
    outputHandler("unable to create final data directory", han.err)

# create config file
try:
    copyfile(files.configSource, files.configTarget)
except IOError:
    outputHandler("unable to copy config template txt", han.err)

# create report file
try:
    copyfile(files.reportSource, files.reportTarget)
except IOError as e:
    outputHandler("unable to copy report template txt", han.err)
