
%% CREATE FIGURE
fig = figure;
fig.WindowState = 'maximized';
fig.NumberTitle = 'off';
fig.Name = 'BOUNDARIES ZOOM TEMPLATE';
fig.Color = [1 1 1];

colormap(hsv);

%% CREATE PLOT

% load data to time table
car = 'C:\Users\geibfil\Desktop\JRC-E-3\experimentData\1908-01';
imu = data2timetable([car,'\parsed_data\IMU_compensated_20.csv']);
velo = data2timetable([car,'\processed_data\IMU_velocity.csv']);
bound = data2timetable([car,'\processed_data\IMU_boundaries.csv']);

% merge loaded data
data = [imu(1:456*20, : ) velo(1:456*20, : ) bound(1:456*20, : )];

% create stacked plot
statPlot = stackedplot(data);
statPlot.DisplayVariables = {{'AccX','AccY','AccZ'}
                             {'GyrX','GyrY','GyrZ'}
                             {'MagX','MagY','MagZ'}
                             'MeanConv'
                             'Bound'};
 
% set up stacked plot
statPlot.Title = 'Boundaries Zoom Template';
statPlot.FontSize = 12;
statPlot.DisplayLabels = {'Acc' 'Gyr' 'Mag' 'Velo' 'Bound'};
statPlot.GridVisible = 'off';
statPlot.XLabel = '';

% set up parameters for every 'sub plot'
% 1st - 3rd plot
for i = 1:3
    statPlot.AxesProperties(i).LegendVisible = 'on';
    statPlot.AxesProperties(i).LegendLocation = 'northeast';
    statPlot.AxesProperties(i).LegendLabels = {'X axis', 'Y axis', 'Z axis'}; 
    statPlot.LineProperties(i).LineWidth = 0.5;
end

% 4th plot
statPlot.LineProperties(4).LineWidth = 1;

% 5th plot
statPlot.LineProperties(5).LineWidth = 1.5;
statPlot.AxesProperties(5).YLimits = [-0.5 1.5];

%% CERATE MARKERS

% Create rectangle
annotation(fig,'rectangle',...
    [0.880208333333333 0.1061865189289 0.0265624999999997 0.820867959372114],...
    'LineStyle',':',...
    'FaceColor',[0.466666666666667 0.674509803921569 0.188235294117647],...
    'FaceAlpha',0.5);

% Create rectangle
annotation(fig,'rectangle',...
    [0.519791666666667 0.107109879963064 0.0218749999999995 0.820867959372114],...
    'LineStyle',':',...
    'FaceColor',[0.466666666666667 0.674509803921569 0.188235294117647],...
    'FaceAlpha',0.5);

% Create rectangle
annotation(fig,'rectangle',...
    [0.130729166666667 0.107109879963064 0.0281249999999998 0.820867959372114],...
    'LineStyle',':',...
    'FaceColor',[0.466666666666667 0.674509803921569 0.188235294117647],...
    'FaceAlpha',0.5);

% Create textbox
annotation(fig,'textbox',...
    [0.313520833760186 0.197368421169584 0.0296874991462877 0.0175438591813117],...
    'VerticalAlignment','middle',...
    'String','Lap 01',...
    'Margin',1,...
    'LineWidth',1,...
    'HorizontalAlignment','center',...
    'FontWeight','bold',...
    'FitBoxToText','off');

% Create textbox
annotation(fig,'textbox',...
    [0.704145833760178 0.197368421169584 0.0296874991462877 0.0175438591813117],...
    'VerticalAlignment','middle',...
    'String','Lap 02',...
    'Margin',1,...
    'LineWidth',1,...
    'HorizontalAlignment','center',...
    'FontWeight','bold',...
    'FitBoxToText','off');
