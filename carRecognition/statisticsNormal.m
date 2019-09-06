
%% FILE MANAGEMENT
close all; clear; clc;

% \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

EXP_PATCH = 'C:\Users\geibfil\Desktop\JRC-E-3\experiments';
DATA_NAME = '11carsFull_200_squeezed.mat';
SEGMENT_SIZE = 120; % in [s]
SAMPLE_RATE = 200; % in [Hz]
PARTS = {'FastFirstBump' 'SecondBump' 'WindowOne' 'VisitBump' 'WindowTwo'};

% \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

% inform user
fprintf("Loading data\n");

% load experiment data structure
dataPath = strcat(EXP_PATCH, '\dataStructures\', DATA_NAME);
load(dataPath, 'data');

% compute rest of parameters
period = 1 / SAMPLE_RATE; % in [s]
cars = size(data, 2);


%% PREPARE DATA
fprintf("Normalising laps lenghts\n");

% find maximal lenght of every lap
lapMax = max(cellfun(@height,data,'UniformOutput',true));

% normalize lap length for every car, fill with BNW means
for lap = 1 : 20
    for computedCar = 1 : cars
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
        startTime = data{computedCar, lap}{end, 'Time'} + period;
        endTime = startTime + delta * period;
        append{:, 'Time'} = transpose(linspace(startTime, endTime, delta));
        
        % merge append table under the original table
        data{computedCar, lap} = [data{computedCar, lap}; append]; 
    end
end

% connect laps in time domain
for lap = 2 : 20
    for computedCar = 1 : cars    
        % compute delta time between two laps
        delta = data{computedCar, lap-1}{end, 'Time'} + period;
        
        % add time delta to time domain of second lap
        data{computedCar, lap}{:, 'Time'} = data{computedCar, lap}{:, 'Time'} + delta;   
    end
end

% join laps of car to one long record
for computedCar = 1 : cars
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
    sprintf('Car%dMethod%d,', [repmat((1:cars),1,8); repelem((1:8),cars)]);
header = strsplit(header, ',');
header(cellfun('isempty',header)) = [];

% create results table
results = array2table(zeros(segCount, cars * 8));
results.Properties.VariableNames = header;

% compute for every car for every segment
for computedCar = 1 : cars
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
    
%% NORMALIZE DISTANCE INTO <0;1> INTERVAL
fprintf("Normalizing distances\n");

results = normalizeDistances(results);

%% SAVE RESULTS TO RESULTS FOLDER

% compute saving path
DATA_NAME = strrep(DATA_NAME, '.mat', '_');
pathSave = strcat(EXP_PATCH, '\results\', DATA_NAME, ...
    int2str(SEGMENT_SIZE), '.mat');

fprintf('INFO: saving results to:\n%s\n', pathSave);

% save data to disc
save(pathSave, 'results');

%% PLOT STATISTICS RESULTS IN STACKED PLOT
fprintf("Printing stacked plot\n");

plotResultsStacked(results);

%% PLOT STATISTICS RESULTS IN SCATTER
fprintf("Printing scatter plot\n");

plotResultsScatter(results, [2, 7, 8]);

%% CODE END
