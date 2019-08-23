function plotBoundaries(pathVelo, pathBound)

% load data to time tables
dataVelo = data2timetable(pathVelo);
dataBound = data2timetable(pathBound);

% merge timetables to one
data = [dataVelo dataBound];

% create figure and set it up
fig = figure();
fig.Name = 'IMU processed data';
fig.NumberTitle = 'off';

% create stacked plot
statPlot = stackedplot(data);

% set up stacked plot parameters
statPlot.Title = 'IMU processed data'; 
statPlot.DisplayVariables = {{'VeloX' 'VeloY' 'VeloZ'} 
                            {'VeloNorm' 'VeloDelt' 'MeanConv'}
                            'Bound'};
statPlot.DisplayLabels = {'Axial velocity'
                         'Computed velocity'
                         {'Detected boundaries'
                          '1 - static,  0 - mobile'}};
statPlot.GridVisible = 'off';
statPlot.XLabel = 'Time [s]';

% set up parameters
statPlot.AxesProperties(1).LegendVisible = 'on';
statPlot.AxesProperties(1).LegendLocation = 'northeast';
statPlot.AxesProperties(1).LegendLabels = {'X axis', 'Y axis', 'Z axis'};

statPlot.AxesProperties(2).LegendVisible = 'on';
statPlot.AxesProperties(2).LegendLocation = 'northeast';
statPlot.AxesProperties(2).LegendLabels = {'Normative', 'Delta', 'Mean'};

statPlot.AxesProperties(3).YLimits = [-1 2];

end

