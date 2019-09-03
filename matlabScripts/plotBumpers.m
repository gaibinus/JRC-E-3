function plotBumpers(bumperPath)

% load data to time table
data = data2timetable(bumperPath);

% label windows between bumpers
data.Cnt = bwlabel(~data.Bump);
data.Cnt(data.Cnt==0) = NaN;
data.Cnt = fillmissing(data.Cnt, 'linear');

% create figure and set it up
fig = figure();
fig.Name = 'Found bumpers';	
fig.NumberTitle = 'off';

% create stacked plot
statPlot = stackedplot(data);

% set up stacked plot parameters
statPlot.DisplayVariables = {'Bound' 'Conv' 'Bump' 'Cnt'};
statPlot.DisplayLabels = {'Laps boundaries' 'Convoluted velocity'  ...
                          'Detected bumpers' 'Window count'};
statPlot.GridVisible = 'off';
statPlot.XLabel = 'Time [s]';

% compute processed data directory
[filepath, ~, ~] = fileparts(bumperPath);

% save figure to experiment directory
savefig(strcat(filepath, '\finalBumpers.fig'));

end
