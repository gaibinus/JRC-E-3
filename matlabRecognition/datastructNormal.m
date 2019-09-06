function ret = datastructNormal(pathExp, configName, resampleRate)

%% PYTHON IN MATLAB WORKAROUND

% load folder with python scripts
pathPython = strrep(pwd, 'matlabRecognition', 'pythonScripts');
py_addpath(pathPython);

% import python module and reload it
pyModule = py.importlib.import_module('functions');
py.importlib.reload(pyModule);

%% MAIN DATA STRUCTURE CREATION

% load experiment configuration file
config = readtable(fullfile(pathExp, 'dataStructures', configName));
configName = erase(configName, '.csv');


% load number of cars
CARS = size(config,1);

% create data cell array CARS x LAPS
data = cell(CARS, 20);

% go thru every car and its every lap
for car = 1 : CARS
    for lap = 1 : 20
        % compute lap number according to experiment config file
        lapNum = config{car, sprintf('Lap%d', lap)};
        lapNum = sprintf('%02d', lapNum);
        
        % compute file path for current lap of current car
        pathFile = char(strcat(pathExp, '\', config{car, 'ExpName'},...
                                  '\final_data\IMU_lap_', lapNum, '.csv'));
               
        % resample if it was requested
        table = resampleData(pathFile, 'return', resampleRate, 'mean');
 
               
        % add table to data cell array
        data(car, lap) = {table};
        
        % inform user about progress
        fprintf('LOADED: car: %d/%d lap: %d/%d\n', car, CARS, lap, 20); 
    end
end

%% BNW MEAN STRUCTURE CREATION

% create BNW mean table header
header = data{1, 1}.Properties.VariableNames;
header(strcmp(header,'Time')) = [];
header = [{'CarNo'} , header];
 
% create BNW mean table CARS x VALUES
bnw = array2table(zeros(CARS, size(header, 2)), 'VariableNames', header);

% fill BNW mean table from car config files
for car = 1 : CARS
    % compute file path for config.txt of current car
    pathConf = char(fullfile(pathExp, config{car,'ExpName'},'config.txt'));
    
    % fill BNW table with current car info
    bnw{car, 'CarNo'} = car;
    
    % load needed data from config file to BNW table
    bnw{car, 'AccX'} = py.functions.readConfig(pathConf, 'acc_mean_x');
    bnw{car, 'AccY'} = py.functions.readConfig(pathConf, 'acc_mean_y');
    bnw{car, 'AccZ'} = py.functions.readConfig(pathConf, 'acc_mean_z');
    
    bnw{car, 'GyrX'} = py.functions.readConfig(pathConf, 'gyr_mean_x');
    bnw{car, 'GyrY'} = py.functions.readConfig(pathConf, 'gyr_mean_y');
    bnw{car, 'GyrZ'} = py.functions.readConfig(pathConf, 'gyr_mean_z');
    
    bnw{car, 'MagX'} = py.functions.readConfig(pathConf, 'mag_mean_x');
    bnw{car, 'MagY'} = py.functions.readConfig(pathConf, 'mag_mean_y');
    bnw{car, 'MagZ'} = py.functions.readConfig(pathConf, 'mag_mean_z');
end

%% SAVE CREATED STRUCTURE

% compute save patch
pathSave = strcat(pathExp, '\dataStructures\', configName, '_', ...
                                     int2str(resampleRate), '_normal.mat');
% inform user about progress
fprintf('INFO: saving data to:\n%s\n', pathSave);

% save data to disc
save(pathSave, 'data', 'bnw');

% if okay, return true
ret = true;

end
