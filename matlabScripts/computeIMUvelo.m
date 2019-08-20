function ret = computeIMUvelo(pathIn, pathOut, pathConfig)

% load folder with python scripts
pathPython = strrep(pwd, 'matlabScripts', 'pythonScripts');
py_addpath(pathPython);

% import python module and reload it
pyModule = py.importlib.import_module('commonFunctions');
py.importlib.reload(pyModule);

% load freqency, window time and variation from config file
sampleRate = py.commonFunctions.readConfig(pathConfig, 'resample_rate');
startTime = py.commonFunctions.readConfig(pathConfig, 'bnw_start');
stopTime = py.commonFunctions.readConfig(pathConfig, 'bnw_stop');
accVari(1) = py.commonFunctions.readConfig(pathConfig, 'vari_acc_x');
accVari(2) = py.commonFunctions.readConfig(pathConfig, 'vari_acc_y');
accVari(3) = py.commonFunctions.readConfig(pathConfig, 'vari_acc_z');
gyrVari(1) = py.commonFunctions.readConfig(pathConfig, 'vari_gyr_x');
gyrVari(2) = py.commonFunctions.readConfig(pathConfig, 'vari_gyr_y');
gyrVari(3) = py.commonFunctions.readConfig(pathConfig, 'vari_gyr_z');
magVari(1) = py.commonFunctions.readConfig(pathConfig, 'vari_mag_x');
magVari(2) = py.commonFunctions.readConfig(pathConfig, 'vari_mag_y');
magVari(3) = py.commonFunctions.readConfig(pathConfig, 'vari_mag_z');

% check if loaded values contains any 'nan'
if sum(sum(isnan([sampleRate startTime stopTime ...
                 accVari gyrVari magVari]))) > 0
   error("Uncomplete config file"); 
end

% load data as table
data = readtable(pathIn);

% create filter
FUSE = ahrsfilter();
FUSE.SampleRate = sampleRate;
FUSE.AccelerometerNoise = max(accVari);
FUSE.GyroscopeNoise = max(gyrVari);
FUSE.MagnetometerNoise = max(magVari);

% compute velocity and orientation
[~, velo] = FUSE([data{:,'AccX'}, data{:,'AccY'}, data{:,'AccZ'}], ...
                 [data{:,'GyrX'}, data{:,'GyrY'}, data{:,'GyrZ'}], ...
                 [data{:,'MagX'}, data{:,'MagY'}, data{:,'MagZ'}]);

% compute velocity norm vector
veloNorm = sqrt(sum(velo.^2,2));

% rewrite table with new data
data = table(data{:,'Time'}, velo(:,1), velo(:,2),velo(:,3), veloNorm, ...
               'VariableNames',{'Time' 'VeloX' 'VeloY' 'VeloZ' 'VeloNorm'});

% write table to CSV
writetable(data, pathOut);

% compute first and last line of data in BNW
firstLine = round(startTime / (1/sampleRate)) + 1;
lastLine = round(stopTime / (1/sampleRate)) + 1;

% compute standard deviations in BNW
stdAxial = std(velo(firstLine:lastLine,:));
stdNorm = std(veloNorm(firstLine:lastLine));

% write standard deviation to config file
py.commonFunctions.writeConfig(pathConfig, 'velo_std_x', stdAxial(1));
py.commonFunctions.writeConfig(pathConfig, 'velo_std_y', stdAxial(2));
py.commonFunctions.writeConfig(pathConfig, 'velo_std_z', stdAxial(3));
py.commonFunctions.writeConfig(pathConfig, 'velo_std', stdNorm);

% compute mean in BNW
meanAxial = mean(velo(firstLine:lastLine,:));
meanNorm = mean(veloNorm(firstLine:lastLine));

% write mean to config file
py.commonFunctions.writeConfig(pathConfig, 'velo_mean_x', meanAxial(1));
py.commonFunctions.writeConfig(pathConfig, 'velo_mean_y', meanAxial(2));
py.commonFunctions.writeConfig(pathConfig, 'velo_mean_z', meanAxial(3));
py.commonFunctions.writeConfig(pathConfig, 'velo_mean', meanNorm);

% if okay, return true
ret = true;

end
