function ret = computeVariant(pathFile, pathConfig)

%% PYTHON IN MATLAB WORKAROUND

% load folder with python scripts
pathPython = strrep(pwd, 'matlabScripts', 'pythonScripts');
py_addpath(pathPython);

% import python module and reload it
pyModule = py.importlib.import_module('functions');
py.importlib.reload(pyModule);

%% LOAD AND PROCESS DATA

% load all necessary data from config file
sampleRate = py.functions.readConfig(pathConfig, 'sample_rate');
startTime = py.functions.readConfig(pathConfig, 'bnw_start');
stopTime = py.functions.readConfig(pathConfig, 'bnw_stop');

% check if read values contains any 'nan'
if sum(isnan([sampleRate startTime stopTime])) > 0
   error("Uncomplete config file"); 
end

% compute first and last line of data
firstLine = round(startTime / (1/sampleRate)) + 1;
lastLine = round(stopTime / (1/sampleRate)) + 1;

% load data as matrix but only in specified range
opts = detectImportOptions(pathFile);
opts.DataLines = [firstLine+1 lastLine+1];
data = readtable(pathFile, opts);

% compute variation vector for every IMU unit
accVari = var([data{:,'AccX'} data{:,'AccY'} data{:,'AccZ'}]);
gyrVari = var([data{:,'GyrX'} data{:,'GyrY'} data{:,'GyrZ'}]);
magVari = var([data{:,'MagX'} data{:,'MagY'} data{:,'MagZ'}]);

% write variation to config file
py.functions.writeConfig(pathConfig, 'vari_acc_x', accVari(1));
py.functions.writeConfig(pathConfig, 'vari_acc_y', accVari(2));
py.functions.writeConfig(pathConfig, 'vari_acc_z', accVari(3));
py.functions.writeConfig(pathConfig, 'vari_gyr_x', gyrVari(1));
py.functions.writeConfig(pathConfig, 'vari_gyr_y', gyrVari(2));
py.functions.writeConfig(pathConfig, 'vari_gyr_z', gyrVari(3));
py.functions.writeConfig(pathConfig, 'vari_mag_x', magVari(1));
py.functions.writeConfig(pathConfig, 'vari_mag_y', magVari(2));
py.functions.writeConfig(pathConfig, 'vari_mag_z', magVari(3));

%% END OF SCRIPT
ret = true;

end
