function ret = adjustBumpers(pathBump, windows, type)

%% LOAD AND PROCESS DATA

% load data as table
data = readtable(pathBump);

% remove static windows
if strcmp(type, 'bumper')
    % detect and count groups
    data.Bump = bwlabel(data.Bump);
    
    % delete required groups
    data.Bump(ismember(data.Bump, windows)) = 0;
    
    % destroy groups
    data.Bump(data.Bump ~= 0) = 1;
    
% remove mobile windows
elseif strcmp(type, 'window')
    % inverse and detect boundary groups
    data.Bump = bwlabel(~data.Bump);
      
    % delete required groups
    data.Bump(ismember(data.Bump, windows)) = 0;
    
    % delete required groups
    data.Bump(data.Bump ~= 0) = 1;
    
    % inverts boundary marking back to original
    data.Bump = ~data.Bump;
    
% unrecognized window type
else
    error('type of adjusting window do not recognised');
end

% write boundaries table to CSV
writetable(data, pathBump);

%% END OF SCRIPT
ret = true;

end