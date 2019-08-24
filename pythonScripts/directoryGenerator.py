from functions import *
from pathlib import Path

import argparse
import os


# CLASSES --------------------------------------------------------------------------------------------------------------

class path:
    def __index__(self, main, photos):
        self.data = self.data()
        self.main = None
        self.photos = None

    class data:
        raw = None
        parsed = None
        processed = None
        final = None


class files:
    def __index__(self):
        self.conf = self.conf()
        self.repo = self.repo()

    class conf:
        source = None
        target = None

    class repo:
        source = None
        target = None


# MAIN -----------------------------------------------------------------------------------------------------------------

# FILES HANDLING -------------------------------------------------------------------------------------------------------

# create input arguments parser
parser = argparse.ArgumentParser(description='Create standardised experiment directory.')

# add required argument
parser.add_argument('-e', '--experiment', help='path to future experiment directory', required=True)

# load input argument
arguments = parser.parse_args()

# compute folder name
folderName = arguments.experiment[arguments.experiment.rfind('\\') + 1:]

# compute directories
path.main = arguments.experiment
path.data.raw = Path(path.main + '/raw_data')
path.data.parsed = Path(path.main + '/parsed_data')
path.photos = Path(path.main + '/photos')
path.data.processed = Path(path.main + '/processed_data')
path.data.final = Path(path.main + '/final_data')

# compute file names
files.conf.source = Path(os.getcwd() + '/txtTemplates/configTemplate.txt')
files.conf.target = Path(path.main + '/config.txt')
files.repo.source = Path(os.getcwd() + '/txtTemplates/reportTemplate.txt')
files.repo.target = Path(path.main + '/report.txt')

# check if txt template file exists and is readable
checkAccess(files.conf.source, 'r')
checkAccess(files.repo.source, 'r')

# check if experiment folder exists then create it
if not os.path.exists(path.main):
    createDirectory(path.main)
    outputHandler('experiment directory created successfully', han.info)
else:
    outputHandler('experiment directory already exists', han.err)

# CREATE DIRECTORIES AMD FILES -----------------------------------------------------------------------------------------

# create all required directories
createDirectory(path.data.raw)
createDirectory(path.data.parsed)
createDirectory(path.data.processed)
createDirectory(path.data.final)
createDirectory(path.photos)

# copy configuration and report templates
copyFile(files.conf.source, files.conf.target)
copyFile(files.repo.source, files.repo.target)

# CODE END -------------------------------------------------------------------------------------------------------------
