close all; clear; clc;

%% FILE MANAGEMENT

% load experiment data structure as data
load('C:\Users\geibfil\Desktop\JRC-E-3\experiments\data_10.mat', 'data');

% save constants
SEGMENT_SIZE = 20; % in [s]
SAMPLE_RATE = 10; % in [Hz]
PERIOD = 1 / SAMPLE_RATE; % in [s]
CARS = size(data, 1);

% find maximal lenght of every lap
lapMax = max(cellfun(@height,data,'UniformOutput',true));

% normalize lap length for every car
for lap = 1 : 20
    for car = 1 : CARS
        % compute difference of actual lap from maximal lap in rows
        delta = lapMax(lap) - size(data{car, lap}, 1);
       
        % create append table with correct dimensions
        header = data{car, lap}.Properties.VariableNames;
        append = array2table(zeros(delta, size(data{car, lap}, 2)));
        append.Properties.VariableNames = header;
        
        % compute starting and ending time of append table and write them
        startTime = data{car, lap}{end, 'Time'} + PERIOD;
        endTime = startTime + delta * PERIOD;
        append{:, 'Time'} = transpose(linspace(startTime, endTime, delta));
        
        % merge append table under the original table
        data{car, lap} = [data{car, lap}; append]; 
    end
end

% connect laps in time domain
for lap = 2 : 20
    for car = 1 : CARS    
        % compute delta time between two laps
        delta = data{car, lap-1}{end, 'Time'} + PERIOD;
        
        % add time delta to time domain of second lap
        data{car, lap}{:, 'Time'} = data{car, lap}{:, 'Time'} + delta;   
    end
end

% join laps of car to one long record
for car = 1 : CARS
    for lap = 2 : 20
        % append current lap under first one
        data{car, 1} = [data{car, 1}; data{car, lap}];
        
        % delete current lap
        data{car, lap} = [];        
    end
end

% format data: remove empty cells and transpose to row format
data = transpose(data(:, 1));

%% COMPUTE STATISTICS




 
 
 
 