function plotIMUvelo(pathFile)

% load data to time table
data = data2timetable(pathFile);

% create figure and set it up
fig = figure();
fig.Name = 'IMU angular velocity and its convolution';
fig.NumberTitle = 'off';

% create stacked plot
statPlot = stackedplot(data);

% set up stacked plot parameters
statPlot.DisplayVariables = {{'VeloX','VeloY','VeloZ'} 
                            'VeloNorm'
                            {'ConvX','ConvY','ConvZ'}
                            'ConvNorm'};
statPlot.DisplayLabels = {'Axial velocity'
                         'Normative velocity'
                         'Axial velocity convolution'
                         'Normative velocity convolution'};
statPlot.GridVisible = 'off';
statPlot.XLabel = 'Time [s]';

% set up parameters
statPlot.AxesProperties(1).LegendVisible = 'on';
statPlot.AxesProperties(1).LegendLocation = 'northeast';
statPlot.AxesProperties(1).LegendLabels = {'X axis', 'Y axis', 'Z axis'};

statPlot.AxesProperties(3).LegendVisible = 'on';
statPlot.AxesProperties(3).LegendLocation = 'northeast';
statPlot.AxesProperties(3).LegendLabels = {'X axis', 'Y axis', 'Z axis'};

end

