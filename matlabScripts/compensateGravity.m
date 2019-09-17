function ret = compensateGravity(pathIn, pathOut, pathConfig)

%% PYTHON IN MATLAB WORKAROUND

% load folder with python scripts
pathPython = strrep(pwd, 'matlabScripts', 'pythonScripts');
py_addpath(pathPython);

% import python module and reload it
pyModule = py.importlib.import_module('functions');
py.importlib.reload(pyModule);

%% LOAD AND PROCESS DATA

% load all necessary data from config file
gravity = py.functions.readConfig(pathConfig, 'gravity');
quat = py.functions.readConfig(pathConfig, 'quat_mean');
quatI = py.functions.readConfig(pathConfig, 'quat_mean_i');
quatJ = py.functions.readConfig(pathConfig, 'quat_mean_j');
quatK = py.functions.readConfig(pathConfig, 'quat_mean_k');
freq = py.functions.readConfig(pathConfig, 'sample_rate');
bnwStart = py.functions.readConfig(pathConfig, 'bnw_start');
bnwEnd = py.functions.readConfig(pathConfig, 'bnw_stop');

% check if read values contains any 'nan'
if sum(isnan([gravity quat quatI quatJ quatK freq bnwStart bnwEnd])) > 0
   error("Uncomplete config file"); 
end

% load data as table
data = readtable(pathIn);

%% COMPENSATE DATA WITH QUATERNION ROTATION

% create quaternion rotation array
quat = [quat quatI quatJ quatK];

% rotate every vector from ACC by quaternion
dataComputed = ...
    quatrotate(quat, [data{:,'AccX'} data{:,'AccY'} data{:,'AccZ'}]);

% remove gravitational acceleration
% dataComputed(:,3) = dataComputed(:,3) - gravity / 10;

% rewrite data in table
data{:,'AccX'} = dataComputed(:,1);
data{:,'AccY'} = dataComputed(:,2);
data{:,'AccZ'} = dataComputed(:,3);

% rotate every vector from GYR by quaternion
dataComputed = ...
    quatrotate(quat, [data{:,'GyrX'} data{:,'GyrY'} data{:,'GyrZ'}]);

% rewrite data in table
data{:,'GyrX'} = dataComputed(:,1);
data{:,'GyrY'} = dataComputed(:,2);
data{:,'GyrZ'} = dataComputed(:,3);

% rotate every vector from MAG by quaternion
dataComputed = ...
    quatrotate(quat, [data{:,'MagX'} data{:,'MagY'} data{:,'MagZ'}]);

% rewrite data in table
data{:,'MagX'} = dataComputed(:,1);
data{:,'MagY'} = dataComputed(:,2);
data{:,'MagZ'} = dataComputed(:,3);

% write table to CSV
writetable(data, pathOut);

%% COMPUTE MEANS IN BNW AND WRITE THEM TO CONFIG FILE

% change bnw time to line number
bnwStart = bnwStart * freq;
bnwEnd = bnwEnd * freq;

% compute means of every variable in data table
accMean(1) = mean(data{bnwStart : bnwEnd, 'AccX'});
accMean(2) = mean(data{bnwStart : bnwEnd, 'AccY'});
accMean(3) = mean(data{bnwStart : bnwEnd, 'AccZ'});

gyrMean(1) = mean(data{bnwStart : bnwEnd, 'GyrX'});
gyrMean(2) = mean(data{bnwStart : bnwEnd, 'GyrY'});
gyrMean(3) = mean(data{bnwStart : bnwEnd, 'GyrZ'});

magMean(1) = mean(data{bnwStart : bnwEnd, 'MagX'});
magMean(2) = mean(data{bnwStart : bnwEnd, 'MagY'});
magMean(3) = mean(data{bnwStart : bnwEnd, 'MagZ'});

pressMean = nanmean(data{bnwStart : bnwEnd, 'Pres'});

% write computed means into config file
py.functions.writeConfig(pathConfig, 'acc_mean_x', accMean(1));
py.functions.writeConfig(pathConfig, 'acc_mean_y', accMean(2));
py.functions.writeConfig(pathConfig, 'acc_mean_z', accMean(3));

py.functions.writeConfig(pathConfig, 'gyr_mean_x', gyrMean(1));
py.functions.writeConfig(pathConfig, 'gyr_mean_y', gyrMean(2));
py.functions.writeConfig(pathConfig, 'gyr_mean_z', gyrMean(3));

py.functions.writeConfig(pathConfig, 'mag_mean_x', magMean(1));
py.functions.writeConfig(pathConfig, 'mag_mean_y', magMean(2));
py.functions.writeConfig(pathConfig, 'mag_mean_z', magMean(3));

py.functions.writeConfig(pathConfig, 'pres_mean', pressMean);

%% END OF SCRIPT
ret = true;

end