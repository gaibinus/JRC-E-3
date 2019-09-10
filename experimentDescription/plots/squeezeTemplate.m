
clear; close all; clc;

%% PREPARE DATA

% car/lapNorm(new) >>> 5/8(8) ; 6/10(9) ; 7/13(12)
cars = [5 6 7];
laps = [8 9 12];

% load normal data
carNorm(1) = {readtable('C:\Users\geibfil\Desktop\JRC-E-3\experimentData\2008-01\final_data\IMU_lap_08.csv')};
carNorm(2) = {readtable('C:\Users\geibfil\Desktop\JRC-E-3\experimentData\2008-02\final_data\IMU_lap_10.csv')};
carNorm(3) = {readtable('C:\Users\geibfil\Desktop\JRC-E-3\experimentData\2108-01\final_data\IMU_lap_13.csv')};

% resample to 200 Hz and change header
for car = 1 : 3
    carNorm(car) = {resampleTable(carNorm{car}, 200, 'mean')};
    carNorm{car}.Properties.VariableNames = ...
      strcat(sprintf('Car%d', car), carNorm{car}.Properties.VariableNames);
end

% find biggest lap
maxSize = max(cellfun(@height,carNorm,'UniformOutput',true));

% extend laps with 'nan' values and generate time vector
time = seconds(transpose(0 : maxSize-1) ./ 200);
for car = 1 : 3
   carNorm{car}{end + 1 : maxSize, : } = nan;
   carNorm(car) = {table2timetable(carNorm{car}(:,2:end),'RowTimes',time)};
end

% merge timetables
carNorm = [carNorm{1} carNorm{2} carNorm{3}];

% load squeezed data
load('C:\Users\geibfil\Desktop\JRC-E-3\experimentStructures\13carsFull_200_squeezed.mat', 'data');

% % connect laps in time domain
% for car = 1 : 3
%    % first part set manually
%    data{cars(car)}.(2){laps(car)}{:,'Time'} = ... 
%      (0 : size(data{cars(car)}.(2){laps(car)}{:,'Time'}, 1)-1)' ./ 200;
%     
%    for part = 3 : 15
%       data{cars(car)}.(part){laps(car)}{:,'Time'} = ...
%         (0 : size(data{cars(car)}.(part){laps(car)}{:,'Time'}, 1)-1)' + ...
%         data{cars(car)}.(part-1){laps(car)}{end,'Time'} + 1/200;     
%    end
%    
%    % add empty table column for future merged parts
%    tmp = cell2table(cell(20, 1), 'VariableNames', {'Merged'});
%    data{cars(car)} = [data{cars(car)} tmp];
% end

% join parts of every lap of every car
for car = 1 : 3
   % copy first data table to 'Merged'
   data{cars(car)}.('Merged'){laps(car)} = data{cars(car)}.(2){laps(car)};

   % add next and next data table to 'Merged'
   for part = 3 : 15
       data{cars(car)}.('Merged'){laps(car)} = ...
                                [data{cars(car)}.('Merged'){laps(car)}; ...
                                data{cars(car)}.(part){laps(car)}];
   end
   
   % rename header
    data{cars(car)}.('Merged'){laps(car)}.Properties.VariableNames = ...
           strcat(sprintf('Car%d', car), ...
           data{cars(car)}.('Merged'){laps(car)}.Properties.VariableNames);
   
   % generate time vector
   time = seconds(transpose(0 : ...
                    size(data{cars(car)}.('Merged'){laps(car)})-1) ./ 200);
                
   % change table to timetable
   data{cars(car)}.('Merged'){laps(car)} = ...
       table2timetable(data{cars(car)}.('Merged'){laps(car)}(:, 2:end), ...
       'RowTimes',time);
end

carSque = [data{cars(1)}.('Merged'){laps(1)}, ...
           data{cars(2)}.('Merged'){laps(2)}, ...
           data{cars(3)}.('Merged'){laps(3)}];

%% CREATE FIGURE

fig = figure;
fig.WindowState = 'maximized';
fig.NumberTitle = 'off';
fig.Name = 'SQUEEZE TEMPLATE';
fig.Color = [1 1 1];

colormap(hsv);

%% CREATE PLOTS

% FIRST SUBPLOT
subplot(2,1,1);

% create stacked plot
nomrPlot = stackedplot(carNorm);
nomrPlot.DisplayVariables = {{'Car1AccX' 'Car1AccY' 'Car1AccZ'}
                             {'Car2AccX' 'Car2AccY' 'Car2AccZ'}
                             {'Car3AccX' 'Car3AccY' 'Car3AccZ'}
                             {'Car1GyrX' 'Car1GyrY' 'Car1GyrZ'}
                             {'Car2GyrX' 'Car2GyrY' 'Car2GyrZ'}
                             {'Car3GyrX' 'Car3GyrY' 'Car3GyrZ'}};

nomrPlot.Title = 'Acc and Gyr before squeezing';
nomrPlot.FontSize = 12;
nomrPlot.DisplayLabels = {{'Acc';'car 1'} {'Acc';'car 2'} ...
                          {'Acc';'car 3'} {'Gyr';'car 1'} ...
                          {'Gyr';'car 2'} {'Gyr';'car 3'}};
nomrPlot.GridVisible = 'off';
nomrPlot.XLabel = '';
                      
% 1st - 3rd plot
for i = 1:3
    nomrPlot.AxesProperties(i).LegendVisible = 'off';
    nomrPlot.AxesProperties(i).LegendLocation = 'northeast';
    nomrPlot.AxesProperties(i).LegendLabels = {'X axis','Y axis','Z axis'}; 
    nomrPlot.LineProperties(i).LineWidth = 0.5;
end


% SECOND SUBPLOT
subplot(2,1,2);

% create stacked plot
nomrPlot = stackedplot(carSque);
nomrPlot.DisplayVariables = {{'Car1AccX' 'Car1AccY' 'Car1AccZ'}
                             {'Car2AccX' 'Car2AccY' 'Car2AccZ'}
                             {'Car3AccX' 'Car3AccY' 'Car3AccZ'}
                             {'Car1GyrX' 'Car1GyrY' 'Car1GyrZ'}
                             {'Car2GyrX' 'Car2GyrY' 'Car2GyrZ'}
                             {'Car3GyrX' 'Car3GyrY' 'Car3GyrZ'}};

nomrPlot.Title = 'Acc and Gyr after squeezing';
nomrPlot.FontSize = 12;
nomrPlot.DisplayLabels = {{'Acc';'car 1'} {'Acc';'car 2'} ...
                          {'Acc';'car 3'} {'Gyr';'car 1'} ...
                          {'Gyr';'car 2'} {'Gyr';'car 3'}};
nomrPlot.GridVisible = 'off';
nomrPlot.XLabel = '';
                      
% 1st - 3rd plot
for i = 1:3
    nomrPlot.AxesProperties(i).LegendVisible = 'off';
    nomrPlot.AxesProperties(i).LegendLocation = 'northeast';
    nomrPlot.AxesProperties(i).LegendLabels = {'X axis','Y axis','Z axis'}; 
    nomrPlot.LineProperties(i).LineWidth = 0.5;
end


%% CERATE MARKERS
