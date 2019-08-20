function ret = detectLapsIMU(pathIn, pathOut, pathConfig)

% load folder with python scripts
pathPython = strrep(pwd, 'matlabScripts', 'pythonScripts');
py_addpath(pathPython);

% import python module and reload it
pyModule = py.importlib.import_module('commonFunctions');
py.importlib.reload(pyModule);

% load all necessary data from config file
frequency = py.commonFunctions.readConfig(pathConfig, 'resample_rate');
bnwSize = py.commonFunctions.readConfig(pathConfig, 'bnw_size');
veloStd = py.commonFunctions.readConfig(pathConfig, 'velo_std');
veloMean = py.commonFunctions.readConfig(pathConfig, 'velo_mean');

% check if loaded values contains any 'nan'
if sum(sum(isnan([frequency bnwSize veloStd veloMean]))) > 0
   error("Uncomplete config file"); 
end

% load data as table
data = readtable(pathIn);

% calculate upper and lower treshold
veloMean = veloMean * (frequency * bnwSize);
upperTreshold = veloMean + veloStd * (frequency * bnwSize);
lowerTreshold = 0;

% create binary vector of possible loop boundaries
bound = data{:,'ConvNorm'} < upperTreshold  & ...
        data{:,'ConvNorm'} > lowerTreshold;

% check if bound(1) == true, (must be, we are starting with engine off)
if bound(1) == 0
    errot("Movement at start of the file detected")
end

% prealocate new vector
boundCalc = nan(size(bound,1),1);

% calculate new vector as follows: 1 = start of lap, 0 = end of lap
for i = 2:size(bound)
    % end of lap in I
    if bound(i-1)==0 && bound(i)==1
        boundCalc(i) = 0;
    % start of lap in I-1
    elseif bound(i-1)==1 && bound(i)==0
        boundCalc(i-1) = 1;
    end
end
     
% rewrite table with new data        
data = table(data{:,'Time'}, boundCalc, 'VariableNames',{'Time' 'Bound'});
  
% write table to CSV
writetable(data, pathOut);

% if okay, return true
ret = true;

end

