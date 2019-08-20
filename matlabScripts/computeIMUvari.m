function ret = computeIMUvari(pathFile, pathConfig)

% load folder with python scripts
pathPython = strrep(pwd, 'matlabScripts', 'pythonScripts');
py_addpath(pathPython);

% import python module and reload it
pyModule = py.importlib.import_module('commonFunctions');
py.importlib.reload(pyModule);

% load all necessary data from config file
sampleRate = py.commonFunctions.readConfig(pathConfig, 'sample_rate');
startTime = py.commonFunctions.readConfig(pathConfig, 'bnw_start');
stopTime = py.commonFunctions.readConfig(pathConfig, 'bnw_stop');

% check if reat values contains any 'nan'
if sum(isnan([sampleRate startTime stopTime])) > 0
   error("Uncomplete config file"); 
end

% compute first and last line of data
firstLine = round(startTime / (1/sampleRate)) + 1;
lastLine = round(stopTime / (1/sampleRate)) + 1;

% load data as matrix but only in speciefied range
opts = detectImportOptions(pathFile);
opts.DataLines = [firstLine+1 lastLine+1];
data = readtable(pathFile, opts);

% compute variation vector for every IMU unit
accVari = var([data{:,'AccX'} data{:,'AccY'} data{:,'AccZ'}]);
gyrVari = var([data{:,'GyrX'} data{:,'GyrY'} data{:,'GyrZ'}]);
magVari = var([data{:,'MagX'} data{:,'MagY'} data{:,'MagZ'}]);

% write variation to config file
py.commonFunctions.writeConfig(pathConfig, 'vari_acc_x', accVari(1));
py.commonFunctions.writeConfig(pathConfig, 'vari_acc_y', accVari(2));
py.commonFunctions.writeConfig(pathConfig, 'vari_acc_z', accVari(3));
py.commonFunctions.writeConfig(pathConfig, 'vari_gyr_x', gyrVari(1));
py.commonFunctions.writeConfig(pathConfig, 'vari_gyr_y', gyrVari(2));
py.commonFunctions.writeConfig(pathConfig, 'vari_gyr_z', gyrVari(3));
py.commonFunctions.writeConfig(pathConfig, 'vari_mag_x', magVari(1));
py.commonFunctions.writeConfig(pathConfig, 'vari_mag_y', magVari(2));
py.commonFunctions.writeConfig(pathConfig, 'vari_mag_z', magVari(3));

% if okay, return true
ret = true;

end
