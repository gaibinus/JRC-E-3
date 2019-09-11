function turnsPlot(turnPath)

% load data to time table
data = data2timetable(turnPath);

% label windows and turns
data.Cnt = bwlabel(~data.Turn); % windows
tmp = bwlabel(data.Turn); % turns
data.Cnt(data.Cnt==0) = tmp(data.Cnt==0);
data.Cnt = fillmissing(data.Cnt, 'linear');

% create figure and set it up
fig = figure();
fig.Name = 'Found Turners';	
fig.NumberTitle = 'off';

% create stacked plot
plot = stackedplot(data);
plot.DisplayVariables = {'Bound' {'Conv' 'PosTH' 'NegTH'} ...
                         'Turn' 'Acc' 'Cnt'};

plot.Title = 'Found Turns';	
plot.DisplayLabels = {'Laps boundaries' 'Velocity in Z' ...
                      'Detected turns' 'Acceleration in Z' ...
                      'Window & turn count'};
                  
plot.GridVisible = 'off';
plot.XLabel = 'Time [s]';

plot.AxesProperties(2).LegendLabels = {'Velocity' 'Left TH' 'Right TH'};
plot.AxesProperties(2).LegendVisible = 'on'; 

% compute processed data directory
[filepath, ~, ~] = fileparts(turnPath);

% save figure to experiment directory
savefig(strcat(filepath, '\finalTurns.fig'));

end
