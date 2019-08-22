function ret = detectLapsIMU(pathIn, pathBound, pathLaps, pathConfig)

%% PYTHON IN MATLAB WORKAROUND
% load folder with python scripts
pathPython = strrep(pwd, 'matlabScripts', 'pythonScripts');
py_addpath(pathPython);

% import python module and reload it
pyModule = py.importlib.import_module('commonFunctions');
py.importlib.reload(pyModule);

%% LOAD DATA FROM CONFIG FILE
frequency = py.commonFunctions.readConfig(pathConfig, 'resample_rate');
bnwSize = py.commonFunctions.readConfig(pathConfig, 'bnw_size');
veloStd = py.commonFunctions.readConfig(pathConfig, 'velo_std');
veloMean = py.commonFunctions.readConfig(pathConfig, 'velo_mean');

% check if loaded values contains any 'nan'
if sum(sum(isnan([frequency bnwSize veloStd veloMean]))) > 0
   error("Uncomplete config file"); 
end

%% LOAD CONVOLUTED DATA AND DETECT WINDOWS WHEN CAR IS STATIONAR
% load data as table
dataBound = readtable(pathIn);

% calculate upper and lower treshold
veloMean = veloMean * (frequency * bnwSize);
upperTreshold = veloMean + veloStd * (frequency * bnwSize);
lowerTreshold = 0;

% create binary vector of possible loop boundaries
bound = dataBound{:,'ConvNorm'} < upperTreshold  & ...
        dataBound{:,'ConvNorm'} > lowerTreshold;

%% CHANGE BINARY VECTOR OF WINDOWS TO ACTUAL START AND END OF LOOP
% check if bound(1) == true, (must be, we are starting with engine off)
if bound(1) == 0
    errot("Movement at start of the file detected")
end

% prealocate new vector
laps = nan(size(bound,1),1);

% calculate new vector as follows: 1 = start of lap, 0 = end of lap
for i = 2:size(bound)
    % end of lap in I
    if bound(i-1)==0 && bound(i)==1
        laps(i) = 0;
    % start of lap in I-1
    elseif bound(i-1)==1 && bound(i)==0
        laps(i-1) = 1; 
    end
end

% bound no longer needed
clear bound;
  
% rewrite table with new data - boundaries   
dataBound = table(dataBound{:,'Time'}, laps, ...
                 'VariableNames',{'Time' 'Bound'});
  
% write boundarties table to CSV
writetable(dataBound, pathBound);

%% CREATE CSV FILE WITH SUMMARIZATION OF LAP START AND END TIME
%create matrix for laps
dataLaps = zeros(nansum(laps),4);

lapCnt = 1; timeTmp = 0;
% loop thru all boundCalc vector
for i = 1:size(laps)
    if laps(i) == 1
        timeTmp = dataBound{i,'Time'};
    elseif laps(i) == 0
        dataLaps(lapCnt,:) = [lapCnt, timeTmp, dataBound{i,'Time'}, ...
                              dataBound{i,'Time'} - timeTmp];
        lapCnt = lapCnt +1;
    end
end

% check if times makes sense
for i = 1:size(dataLaps)
   if dataLaps(i,2) >= dataLaps(i,3)
      warning("In lap " + int2str(i) + " is start >= end time!") 
   end
end

% reformat matrix to table
dataLaps = array2table(dataLaps, 'VariableNames', ...
                      {'LapNo','StartTime','EndTime','LapDur'});

% write laps table to CSV
writetable(dataLaps, pathLaps);

%% END OF SCRIPT
% if okay, return true
ret = true;

end

