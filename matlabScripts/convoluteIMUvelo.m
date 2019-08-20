function ret = convoluteIMUvelo(pathIn, pathOut, pathConfig)

% load folder with python scripts
pathPython = strrep(pwd, 'matlabScripts', 'pythonScripts');
py_addpath(pathPython);

% import python module and reload it
pyModule = py.importlib.import_module('commonFunctions');
py.importlib.reload(pyModule);

% load freqency and variation from config file
frequency = py.commonFunctions.readConfig(pathConfig, 'resample_rate');
bnwSize = py.commonFunctions.readConfig(pathConfig, 'bnw_size');

% check if loaded values contains any 'nan'
if sum(sum(isnan([frequency bnwSize]))) > 0
   error("Uncomplete config file"); 
end

% load data as table
data = readtable(pathIn);

% create convolution matrix
convMatrix = ones(1, frequency * bnwSize);

% proceed convolution
veloX = conv(convMatrix, data{:,'VeloX'}, 'full');
veloY = conv(convMatrix, data{:,'VeloY'}, 'full');
veloZ = conv(convMatrix, data{:,'VeloZ'}, 'full');
veloNorm = conv(convMatrix, data{:,'VeloNorm'}, 'full');

% compute convolutin offsets
staOff = ceil(size(convMatrix,2)/2);
endOff = floor(size(convMatrix,2)/2);

% rewrite table with new data
data = table(data{:,'Time'}, ...
             veloX(staOff:end-endOff), veloY(staOff:end-endOff), ...
             veloZ(staOff:end-endOff), veloNorm(staOff:end-endOff), ...
             'VariableNames', {'Time' 'ConvX' 'ConvY' 'ConvZ' 'ConvNorm'});

% write table to CSV
writetable(data, pathOut);

% if okay, return true
ret = true;

end

