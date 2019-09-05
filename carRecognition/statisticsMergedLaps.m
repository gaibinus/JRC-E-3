close all; clear; clc;

%% FILE MANAGEMENT

dataPath = 'C:\Users\geibfil\Desktop\JRC-E-3\experiments\data_200.mat';

% inform user
fprintf("Loading data\n");

% load experiment data structure
load(dataPath, 'data');
load(dataPath, 'bnw');

% save constants
SEGMENT_SIZE = 60; % in [s]
SAMPLE_RATE = 200; % in [Hz]
PERIOD = 1 / SAMPLE_RATE; % in [s]
CARS = size(data, 1);

% inform user
fprintf("Normalising laps lenghts\n");

% find maximal lenght of every lap
lapMax = max(cellfun(@height,data,'UniformOutput',true));

% normalize lap length for every car, fill with BNW means
for lap = 1 : 20
    for computedCar = 1 : CARS
        % compute difference of actual lap from maximal lap in rows
        delta = lapMax(lap) - size(data{computedCar, lap}, 1);
        
        % create append table with correct dimensions
        header = data{computedCar, lap}.Properties.VariableNames;
        append = array2table(ones(delta, size(data{computedCar, lap}, 2)));
        append.Properties.VariableNames = header;
        
        % change values to means from BNW
        append{:, 'AccX'} = append{:, 'AccX'} .* bnw{computedCar, 'AccX'};
        append{:, 'AccY'} = append{:, 'AccY'} .* bnw{computedCar, 'AccY'};
        append{:, 'AccZ'} = append{:, 'AccZ'} .* bnw{computedCar, 'AccZ'};
        
        append{:, 'GyrX'} = append{:, 'GyrX'} .* bnw{computedCar, 'GyrX'};
        append{:, 'GyrY'} = append{:, 'GyrY'} .* bnw{computedCar, 'GyrY'};
        append{:, 'GyrZ'} = append{:, 'GyrZ'} .* bnw{computedCar, 'GyrZ'};
        
        append{:, 'MagX'} = append{:, 'MagX'} .* bnw{computedCar, 'MagX'};
        append{:, 'MagY'} = append{:, 'MagY'} .* bnw{computedCar, 'MagY'};
        append{:, 'MagZ'} = append{:, 'MagZ'} .* bnw{computedCar, 'MagZ'};
        
        % compute starting and ending time of append table and write them
        startTime = data{computedCar, lap}{end, 'Time'} + PERIOD;
        endTime = startTime + delta * PERIOD;
        append{:, 'Time'} = transpose(linspace(startTime, endTime, delta));
        
        % merge append table under the original table
        data{computedCar, lap} = [data{computedCar, lap}; append]; 
    end
end

% connect laps in time domain
for lap = 2 : 20
    for computedCar = 1 : CARS    
        % compute delta time between two laps
        delta = data{computedCar, lap-1}{end, 'Time'} + PERIOD;
        
        % add time delta to time domain of second lap
        data{computedCar, lap}{:, 'Time'} = data{computedCar, lap}{:, 'Time'} + delta;   
    end
end

% join laps of car to one long record
for computedCar = 1 : CARS
    for lap = 2 : 20
        % append current lap under first one
        data{computedCar, 1} = [data{computedCar, 1}; data{computedCar, lap}];
        
        % delete current lap
        data{computedCar, lap} = [];        
    end
end

% format data: remove empty cells and transpose to row format
data = transpose(data(:, 1));

%% COMPUTE STATISTICS
fprintf("Computing statistics\n");

% compute increase between segments
segIncrease = SEGMENT_SIZE * SAMPLE_RATE;

% find how long is the record
length = max(max(cellfun(@height,data,'UniformOutput',true)));

% compute number of segments
segCount = floor(length / segIncrease);
fprintf("Segment no.: %d\n", segCount);

% create table header
header = ...
    sprintf('Car%dMethod%d,', [repmat((1:CARS),1,8); repelem((1:8),CARS)]);
header = strsplit(header, ',');
header(cellfun('isempty',header)) = [];

% create results table
results = array2table(zeros(segCount, CARS * 8));
results.Properties.VariableNames = header;

% compute for every car for every segment
for computedCar = 1 : CARS
    for segment = 1 : segCount
        % compute end of current segment 
        segEnd = segIncrease * segment;
        
        % load AccZ data from current car in lenght of current segment
        tmpData = data{computedCar}{1:segEnd, 'AccZ'};
        
        results{segment,sprintf('Car%dMethod1', computedCar)} = var(tmpData);
        results{segment,sprintf('Car%dMethod2', computedCar)} = ...
                                              wentropy(tmpData, 'shannon');
        results{segment,sprintf('Car%dMethod3', computedCar)} = skewness(tmpData);
        results{segment,sprintf('Car%dMethod4', computedCar)} = kurtosis(tmpData);
        
        % load GyrY data from current car in lenght of current segment
        tmpData = data{computedCar}{1:segEnd, 'GyrY'};
        
        results{segment,sprintf('Car%dMethod5', computedCar)} = var(tmpData);
        results{segment,sprintf('Car%dMethod6', computedCar)} = ...
                                              wentropy(tmpData, 'shannon');
        results{segment,sprintf('Car%dMethod7', computedCar)} = skewness(tmpData);
        results{segment,sprintf('Car%dMethod8', computedCar)} = kurtosis(tmpData);
        
        % inform user about progress
        fprintf("Car: %d segment: %d / %d done\n", computedCar, segment, segCount);
    end    
end
    
return

%% NORMALIZE DISTANCE

% for every method
for method = 1 : 8                                              %#ok<UNRCH>
    
   % create mothot-size tmp array
   tmp = zeros(segCount, CARS);
   
   % compute distance of every car in methot to others
   for computed = 1 : CARS 
       for compared = 1 : CARS
       tmp(:, computed) = tmp(:, computed) + abs( ... 
           results{:, sprintf('Car%dMethod%d',computed,method)} - ...
           results{:, sprintf('Car%dMethod%d',compared,method)});
       end
   end
   
   % rewrite after finishing metode
   for car = 1 : CARS
        results{:, sprintf('Car%dMethod%d',car,method)} = tmp(:, car); 
   end
end

%% PLOT STATISTICS RESULTS IN STACKED PLOT

% create array with method names and data names
dataNames = ["acceleration", "gyroscope"];
methodNames = ["variance", "wentropy", "skewness", "kurtosis"];

% create figure and set it up
fig = figure();
fig.Name = strcat('Statistics of merged laps in stacked plot');

% create display variables parameter
dispVar = cell(8,1);
for method = 1 : 8
   tmp = sprintf('Car%dMethod%d,', [1:CARS; method * ones(1,CARS)]);
   tmp = strsplit(tmp, ',');
   tmp(cellfun('isempty',tmp)) = [];
   dispVar{method} = tmp;
end

% create display labels parameter
dispLab = cell(8,1);
for method = 1 : 8
    dataStr = dataNames(floor((method-1)/4) + 1);
    methodStr = methodNames(rem(method-1, 4) + 1);
    dispLab{method} = {dataStr, methodStr};
end
% create legend labels parameter
legLab = strsplit(sprintf('Car %d,', 1:CARS), ',');
legLab(cellfun('isempty',legLab)) = [];

stackedPlot = stackedplot(results, dispVar);
stackedPlot.DisplayLabels = dispLab;
stackedPlot.XLabel = 'Segment ID';
stackedPlot.AxesProperties(1).LegendLabels = legLab;
stackedPlot.AxesProperties(1).LegendVisible = 'on'; 
for i = 2:8
    stackedPlot.AxesProperties(i).LegendVisible = 'off';
end
   
return

%% PLOT STATISTICS RESULTS IN SCATTER

% CHOOSE 2/3 METHODS TO PLOT
methods = [2, 7, 8];                                            

% create figure and set it up
fig = figure();
fig.Name = strcat('Statistics of merged laps in scatter plot');

% create layers of scatter plot in 2D or 3D
for computedCar = 1 : CARS
    if size(methods, 2) == 2
        scatter(results{:, sprintf('Car%dMethod%d', computedCar, methods(1))}, ...
                results{:, sprintf('Car%dMethod%d', computedCar, methods(2))});
    elseif size(methods, 2) == 3
        scatter3(results{:, sprintf('Car%dMethod%d', computedCar, methods(1))}, ...
                 results{:, sprintf('Car%dMethod%d', computedCar, methods(2))}, ...
                 results{:, sprintf('Car%dMethod%d', computedCar, methods(3))});  
    else
        error('Wrong number of methots to plot');
    end
    
    % keep adding layers to plot
    hold on;
end

% create X axis label
methodStr = methodNames(rem(methods(1)-1, 4) + 1);
dataStr = dataNames(floor((methods(1)-1)/4) + 1);
xlabel(strcat(methodStr, " of ", dataStr));

% create Y axis label
methodStr = methodNames(rem(methods(2)-1, 4) + 1);
dataStr = dataNames(floor((methods(2)-1)/4) + 1);
ylabel(strcat(methodStr, " of ",  dataStr));

% create Z axis label
if size(methods, 2) == 3
    methodStr = methodNames(rem(methods(3)-1, 4) + 1);
    dataStr = dataNames(floor((methods(3)-1)/4) + 1);
    zlabel(strcat(methodStr, " of ", dataStr));
end

% create legend
legArr = strsplit(sprintf('Car %d,', 1:CARS), ',');
legArr(cellfun('isempty',legArr)) = [];
legend(legArr, 'Location','Best');

% end of hold
hold off;




