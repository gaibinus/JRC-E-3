function plotIMU(filePath)

% load data to time table
timeTable = data2timetable(filePath);

% create figure and set it up
fig = figure();
fig.Name = 'MT sensor data';
fig.NumberTitle = 'off';

% create stacked plot
statPlot = stackedplot(timeTable);

% set up stacked plot parameters
statPlot.DisplayVariables = {
    {'AccX','AccY','AccZ'}
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

