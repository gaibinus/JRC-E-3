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

% check if read values contains any 'nan'
if sum(isnan([gravity quat quatI quatJ quatK])) > 0
   error("Uncomplete config file"); 
end

% load data as table
data = readtable(pathIn);

%% COMPENSATE DATA WITH QUATERNION ROTATION

% create quaternion rotation array and decrease gravity
quat = [quat quatI quatJ quatK];
gravity = gravity / 10;

% rotate every vector from data by quaternion
dataComputed = ...
    quatrotate(quat, [data{:,'AccX'} data{:,'AccY'} data{:,'AccZ'}]);

% remove gravitational acceleration
dataComputed(:,3) = dataComputed(:,3) - gravity;

% rewrite data in table
data{:,'AccX'} = dataComputed(:,1);
data{:,'AccY'} = dataComputed(:,2);
data{:,'AccZ'} = dataComputed(:,3);

% write table to CSV
writetable(data, pathOut);

%% END OF SCRIPT
ret = true;

end