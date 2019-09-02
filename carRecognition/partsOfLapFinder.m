close all; clear; clc;

pathExp = 'C:\Users\geibfil\Desktop\JRC-E-3\experiments';

%% PYTHON IN MATLAB WORKAROUND

% load folder with python scripts
pathPython = strrep(pwd, 'carRecognition', 'pythonScripts');
py_addpath(pathPython);

% import python module and reload it
pyModule = py.importlib.import_module('functions');
py.importlib.reload(pyModule);

%% LOAD DATA AND PREPARE COMPUTATION

% load experiment configuration file
config = readtable(strcat(pathExp, '\config_test.csv'));

% load number of cars
CARS = size(config,1);

car = '\1308-01';
freq = 20;

% load car data
data = readtable(strcat(pathExp, car, '\processed_data\IMU_velocity.csv'));
bound = readtable(strcat(pathExp, car, '\processed_data\IMU_boundaries.csv'));
laps = readtable(strcat(pathExp, car, '\processed_data\IMU_laps.csv'));

% edit table
data = table(data.Time, data.VeloZ, bound.Bound, 'VariableNames', {'Time' 'Velo' 'Bound'});


%%

% absolute value of velocity
data.Velo = abs(data.Velo);

% 

% remove parts when car is stationary
data.Velo(data.Bound == 1) = 0;
            
% cerate data envelope and add it to table
[data.Enve, ~] = envelope(data.Velo, freq * 2, 'peak');
data.Enve(data.Enve < 0) = 0;

% create copy
data.Proc = data.Enve;

% process lap by lap
for lap = 1 : size(laps, 1)
    lapStart = laps{lap, 'Start'} * freq;
    lapEnd = laps{lap, 'End'} * freq;
    
    lapMed = median(data{lapStart : lapEnd, 'Enve'});
    lapStd = std(data{lapStart : lapEnd, 'Enve'});
    
    data{lapStart : lapEnd, 'Proc'}( ...
            data{lapStart : lapEnd, 'Enve'} < lapMed + lapStd / 2) = 0;
        
    % remove noise created by braking ~ last 10 s
    lapBrake = (laps{lap, 'End'} - 10) * freq;
    data{lapBrake : lapEnd, 'Proc'} = 0;
end

stackedplot(data);
