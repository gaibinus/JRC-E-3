function ret = adjustBoundaries(pathFile, windows, type)

%% PYTHON IN MATLAB WORKAROUND

% load folder with python scripts
pathPython = strrep(pwd, 'matlabScripts', 'pythonScripts');
py_addpath(pathPython);

% import python module and reload it
pyModule = py.importlib.import_module('commonFunctions');
py.importlib.reload(pyModule);

%% LOAD AND PROCESS DATA

% load data as table
dataBound = readtable(pathFile);

% remove static windows
if strcmp(type, 'static')
    % detect and count groups
    bound = bwlabel(dataBound{:,'Bound'});
    
    % delete required groups
    bound(ismember(bound, windows)) = 0;
    
    % destroy groups
    bound(bound ~= 0) = 1;
    
% remove mobile windows
elseif strcmp(type, 'mobile')
    % inverse boundary marking
    dataBound{:,'Bound'} = ~dataBound{:,'Bound'};
    
    % detect and count groups
    bound = bwlabel(dataBound{:,'Bound'});
    
    % delete required groups
    bound(ismember(bound, windows)) = 0;
    
    % delete required groups
    bound(bound ~= 0) = 1;
    
    % inverts boundary marking back to original
    bound = ~bound;
    
% unrecognized window type
else
    error('type of adjusting window do not recognised');
end

% rewrite table with new data - boundaries   
dataBound = table(dataBound{:,'Time'}, bound, ...
                 'VariableNames',{'Time' 'Bound'});

% write boundaries table to CSV
writetable(dataBound, pathFile);

%% END OF SCRIPT
ret = true;

end

