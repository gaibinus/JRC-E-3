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

% remove required windows
if strcmp(type, 'static')
    bound = bwlabel(dataBound{:,'Bound'});
    bound(ismember(bound, windows)) = 0;
    
    bound(bound ~= 0) = 1;

elseif strcmp(type, 'mobile')
    dataBound{:,'Bound'} = ~dataBound{:,'Bound'};
    bound = bwlabel(dataBound{:,'Bound'});
    
    bound(ismember(bound, windows)) = 0;
    
    bound(bound ~= 0) = 1;
    bound = ~bound;
else
    error('type of adjusting window do not recognised');
end

% rewrite table with new data - boundaries   
dataBound = table(dataBound{:,'Time'}, bound, ...
                 'VariableNames',{'Time' 'Bound'});

% write boundarties table to CSV
writetable(dataBound, pathFile);

%% END OF SCRIPT
% if okay, return true
ret = true;

end

