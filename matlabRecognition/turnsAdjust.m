function ret = turnsAdjust(turnPath, windows, type)

%% LOAD AND PROCESS DATA

% load data as table
data = readtable(turnPath);

% remove turns
if strcmp(type, 'turn')
    % detect and count groups
    data.Turn = bwlabel(data.Turn);
    
    % delete required groups
    data.Turn(ismember(data.Turn, windows)) = 0;
    
    % destroy groups
    data.Turn(data.Turn ~= 0) = 1;
    
% remove windows
elseif strcmp(type, 'window')
    % inverse and detect boundary groups
    data.Turn = bwlabel(~data.Turn);
      
    % delete required groups
    data.Turn(ismember(data.Turn, windows)) = 0;
    
    % delete required groups
    data.Turn(data.Turn ~= 0) = 1;
    
    % inverts boundary marking back to original
    data.Turn = ~data.Turn;
    
% unrecognized window type
else
    error('type of adjusting type do not recognised');
end

% write boundaries table to CSV
writetable(data, turnPath);

%% END OF SCRIPT
ret = true;

end