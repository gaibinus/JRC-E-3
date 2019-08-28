<<<<<<< HEAD
function ret = detectBoundaries(pathIn, pathBound, pathConfig)﻿
=======
function ret = detectBoundaries(pathVelo, pathBound, pathConfig)
>>>>>>> master

%% PYTHON IN MATLAB WORKAROUND
% load folder with python scripts
pathPython = strrep(pwd, 'matlabScripts', 'pythonScripts');
py_addpath(pathPython);

% import python module and reload it
pyModule = py.importlib.import_module('functions');
py.importlib.reload(pyModule);

%% LOAD CONFIG FILE AND DATA
frequency = py.functions.readConfig(pathConfig, 'resample_rate');
bnwSize = py.functions.readConfig(pathConfig, 'bnw_size');
veloStd = py.functions.readConfig(pathConfig, 'velo_std');	
veloMean = py.functions.readConfig(pathConfig, 'velo_mean');

% check if loaded values contains any 'nan'
if sum(sum(isnan([frequency bnwSize veloStd veloMean]))) > 0
   error("Uncomplete config file"); 
end

% load data as table
dataBound = readtable(pathVelo);

%% DETECT WINDOWS WHEN CAR IS STATIC

% calculate upper and lower threshold
<<<<<<< HEAD
upperTreshold = veloMean + veloStd;
=======
upperTreshold = veloMean + veloStd * 1;
>>>>>>> master
lowerTreshold = 0;

% create binary vector of possible loop boundaries
bound = dataBound{:,'MeanConv'} < upperTreshold  & ...
        dataBound{:,'MeanConv'} > lowerTreshold;
    
<<<<<<< HEAD
% find too small movement windows, less or equal to 1.5 s
=======
% find too small movement windows, less or equal to 1 s
>>>>>>> master
bound = bwlabel(bound);
for i = 1:max(bound)
    if sum(bound == i) <= ceil(frequency * 1)
       bound(bound == i) = 0; 
    end
end

bound(bound ~= 0) = 1;

% start with static
for i = 1:size(bound)
    if bound(i) == 0
        bound(i) = 1;
    else
        break;
    end
end

% end with static
for i = size(bound):-1:1
    if bound(i) == 0
        bound(i) = 1;
    else
        break;
    end
end

% rewrite table with new data - boundaries   
dataBound = table(dataBound{:,'Time'}, bound, ...
                 'VariableNames',{'Time' 'Bound'});

% write boundaries table to CSV
writetable(dataBound, pathBound);


%% END OF SCRIPT
ret = true;

end

