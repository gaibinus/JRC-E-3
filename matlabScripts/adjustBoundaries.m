function ret = adjustBoundaries(pathFile, windows, type)

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
    % invers boundary marking
    dataBound{:,'Bound'} = ~dataBound{:,'Bound'};
    
    % detect and count groups
    bound = bwlabel(dataBound{:,'Bound'});
    
    % delete required groups
    bound(ismember(bound, windows)) = 0;
    
    % delete required groups
    bound(bound ~= 0) = 1;
    
    % invers boundary marking back to original
    bound = ~bound;
    
% unrecognised window type
else
    error('type of adjusting window do not recognised');
end

% rewrite table with new data - boundaries   
dataBound = table(dataBound{:,'Time'}, bound, ...
                 'VariableNames',{'Time' 'Bound'});

% write boundarties table to CSV
writetable(dataBound, pathFile);

%% END OF SCRIPT
ret = true;

end

