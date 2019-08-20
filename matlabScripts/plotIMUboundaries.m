function plotIMUboundaries(pathVelo, pathConv, pathBound)

% load data to time tables
dataVelo = data2timetable(pathVelo);
dataConv = data2timetable(pathConv);
dataBound = data2timetable(pathBound);

% merge timetables to one
data = [dataVelo dataConv dataBound];

% create figure and set it up
fig = figure();
fig.Name = 'IMU processed data';
fig.NumberTitle = 'off';

% create stacked plot
statPlot = stackedplot(data);

% set up stacked plot parameters
statPlot.Title = 'IMU processed data'; 
statPlot.DisplayVariables = {{'VeloX','VeloY','VeloZ'} 
                            'VeloNorm'
                            {'ConvX','ConvY','ConvZ'}
                            'ConvNorm'
                            'Bound'};
statPlot.DisplayLabels = {'Axial velocity'
                         'Normative velocity'
                         'Axial convolution'
                         'Normative convolution'
                         {'Detected boundaries','1 - start, 0 - end of lap'}};
statPlot.GridVisible = 'off';
statPlot.XLabel = 'Time [s]';

% set up parameters
statPlot.AxesProperties(1).LegendVisible = 'on';
statPlot.AxesProperties(1).LegendLocation = 'northeast';
statPlot.AxesProperties(1).LegendLabels = {'X axis', 'Y axis', 'Z axis'};

statPlot.AxesProperties(3).LegendVisible = 'on';
statPlot.AxesProperties(3).LegendLocation = 'northeast';
statPlot.AxesProperties(3).LegendLabels = {'X axis', 'Y axis', 'Z axis'};

statPlot.AxesProperties(5).YLimits = [-1 2];
statPlot.LineProperties(5).LineStyle = 'none';
statPlot.LineProperties(5).Marker = '+';

end

