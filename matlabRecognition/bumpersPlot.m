function bumpersPlot(bumperPath)

% load data to time table
data = data2timetable(bumperPath);

% label windows and bumpers
data.Cnt = bwlabel(~data.Bump); % windows
tmp = bwlabel(data.Bump); % bumpers
data.Cnt(data.Cnt==0) = tmp(data.Cnt==0);
data.Cnt = fillmissing(data.Cnt, 'linear');

% create figure and set it up
fig = figure();
fig.Name = 'Found bumpers';	
fig.NumberTitle = 'off';

% create stacked plot
statPlot = stackedplot(data);
statPlot.Title = 'Found bumpers';	

% set up stacked plot parameters
statPlot.DisplayVariables = {'Bound' 'Conv' 'Bump' 'Acc' 'Cnt'};
statPlot.DisplayLabels = {'Laps boundaries' 'Velocity in  in Z axis' ...
                          'Detected bumpers' 'Acceleration in Z axis' ...
                          'Window and buper count'};
statPlot.GridVisible = 'off';
statPlot.XLabel = 'Time [s]';

% compute processed data directory
[filepath, ~, ~] = fileparts(bumperPath);

% save figure to experiment directory
savefig(strcat(filepath, '\finalBumpers.fig'));

end
