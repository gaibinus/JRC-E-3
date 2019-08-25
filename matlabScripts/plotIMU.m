function plotIMU(pathFile, plotTime)﻿

% check if time frame was specified,
if exist('plotTime','var')
    % read file as table but only first two lines
    opts = detectImportOptions(pathFile);
    opts.DataLines = [2 3];
    table = readtable(pathFile, opts);
    
    % compute length between two measurements
    period = abs(table{1,'Time'} - table{2,'Time'});
    
    % compute how many lines from CSV are needed to match specified time
    rows = ceil(plotTime / period);
    
    % load data to time table
    data = data2timetable(pathFile, rows);
    
else
    % load data to time table
    data = data2timetable(pathFile);
end

% create figure and set it up
fig = figure();
fig.Name = 'MT sensor data';
fig.NumberTitle = 'off';

% create stacked plot
statPlot = stackedplot(data);

% set up stacked plot parameters
statPlot.DisplayVariables = {{'AccX','AccY','AccZ'}
                             {'GyrX','GyrY','GyrZ'}
                             {'MagX','MagY','MagZ'}};
statPlot.DisplayLabels = {'Acc','Gyr','Mag'};
statPlot.GridVisible = 'off';
statPlot.XLabel = 'Time [s]';

% set up parameters for every 'sub plot'
for i = 1:3
    statPlot.AxesProperties(i).LegendVisible = 'on';
    statPlot.AxesProperties(i).LegendLocation = 'northeast';
    statPlot.AxesProperties(i).LegendLabels = {'X axis', 'Y axis', 'Z axis'};
end

end

