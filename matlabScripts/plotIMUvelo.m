function plotIMUvelo(filePath)

% load data to time table
timeTable = data2timetable(filePath);

% create figure and set it up
fig = figure();
fig.Name = 'IMU angular velocity';
fig.NumberTitle = 'off';

% create stacked plot
statPlot = stackedplot(timeTable);

% set up stacked plot parameters
statPlot.DisplayVariables = {{'VeloX','VeloY','VeloZ'} 'VeloNorm'};
statPlot.DisplayLabels = {'Axial velocity','Normative velocity'};
statPlot.GridVisible = 'off';
statPlot.XLabel = 'Time [s]';

% set up parameters
statPlot.AxesProperties(1).LegendVisible = 'on';
statPlot.AxesProperties(1).LegendLocation = 'northeast';
statPlot.AxesProperties(1).LegendLabels = {'X axis', 'Y axis', 'Z axis'};

end

