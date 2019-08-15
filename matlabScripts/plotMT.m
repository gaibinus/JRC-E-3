function plotMT(filePath)

% load data to time table
timeTable = data2timetable(filePath);

% create figure and set it up
fig = figure();
fig.Name = 'MT sensor data';
fig.NumberTitle = 'off';
fig.Units = 'normalized';
fig.OuterPosition = [0 0 1 1];

% create stacked plot
statPlot = stackedplot(timeTable);

% set up stacked plot parameters
statPlot.DisplayVariables = {
    {'acc_X','acc_Y','acc_Z'}
    {'gyr_X','gyr_Y','gyr_Z'}
    {'mag_X','mag_Y','mag_Z'}};
statPlot.DisplayLabels = {'Acceleration','Rotation','Magnetic field'};
statPlot.GridVisible = 'off';
statPlot.XLabel = 'Time [s]';

% set up parameters for every 'sub plot'
for i = 1:3
    statPlot.AxesProperties(i).LegendVisible = 'on';
    statPlot.AxesProperties(i).LegendLocation = 'northeast';
    statPlot.AxesProperties(i).LegendLabels = {'X axis', 'Y axis', 'Z axis'};
end

end

