
%% FILE MANAGEMENT
close all; clear; clc;

% \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

EXP_PATCH = 'C:\Users\geibfil\Desktop\JRC-E-3\experiments';
DATA_NAME = '11carsFull_200_normal.mat';
SEGMENT_SIZE = 120; % in [s]
SAMPLE_RATE = 200; % in [Hz]
PARTS = {'FastFirstBump' 'SecondBump' 'WindowOne' 'VisitBump' 'WindowTwo'};

% \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

% inform user
fprintf("Loading data\n");

% load experiment data structure
dataPath = strcat(EXP_PATCH, '\dataStructures\', DATA_NAME);
load(dataPath, 'data');
load(dataPath, 'bnw');

% compute rest of parameters
period = 1 / SAMPLE_RATE; % in [s]
cars = size(data, 1);


%% PREPARE DATA
fprintf("Normalising laps lenghts\n");

% find maximal lenght of every lap
lapMax = max(cellfun(@height,data,'UniformOutput',true));

% normalize lap length for every car, fill with BNW means
for lap = 1 : 20
    for car = 1 : cars
        % compute difference of actual lap from maximal lap in rows
        delta = lapMax(lap) - size(data{car, lap}, 1);
        
        % create append table with correct dimensions
        header = data{car, lap}.Properties.VariableNames;
        append = array2table(ones(delta, size(data{car, lap}, 2)));
        append.Properties.VariableNames = header;
        
        % change values to means from BNW
        append{:, 'AccX'} = append{:, 'AccX'} .* bnw{car, 'AccX'};
        append{:, 'AccY'} = append{:, 'AccY'} .* bnw{car, 'AccY'};
        append{:, 'AccZ'} = append{:, 'AccZ'} .* bnw{car, 'AccZ'};
        
        append{:, 'GyrX'} = append{:, 'GyrX'} .* bnw{car, 'GyrX'};
        append{:, 'GyrY'} = append{:, 'GyrY'} .* bnw{car, 'GyrY'};
        append{:, 'GyrZ'} = append{:, 'GyrZ'} .* bnw{car, 'GyrZ'};
        
        append{:, 'MagX'} = append{:, 'MagX'} .* bnw{car, 'MagX'};
        append{:, 'MagY'} = append{:, 'MagY'} .* bnw{car, 'MagY'};
        append{:, 'MagZ'} = append{:, 'MagZ'} .* bnw{car, 'MagZ'};
        
        % compute starting and ending time of append table and write them
        startTime = data{car, lap}{end, 'Time'} + period;
        endTime = startTime + delta * period;
        append{:, 'Time'} = transpose(linspace(startTime, endTime, delta));
        
        % merge append table under the original table
        data{car, lap} = [data{car, lap}; append]; 
    end
end

% connect laps in time domain
for lap = 2 : 20
    for car = 1 : cars    
        % compute delta time between two laps
        delta = data{car, lap-1}{end, 'Time'} + period;
        
        % add time delta to time domain of second lap
        data{car, lap}{:, 'Time'} = data{car, lap}{:, 'Time'} + delta;   
    end
end

% join laps of car to one long record
for car = 1 : cars
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
fprintf("Computing statistics\n");

% compute increase between segments
segIncrease = SEGMENT_SIZE * SAMPLE_RATE;

% find how long is the record
length = max(max(cellfun(@height,data,'UniformOutput',true)));

% compute number of segments
SEGS = floor(length / segIncrease);

% create table header
header = ...
    sprintf('Car%dMeth%d,', [repmat((1:cars),1,8); repelem((1:8),cars)]);
header = strsplit(header, ',');
header(cellfun('isempty',header)) = [];

% create results table
results = array2table(zeros(SEGS, cars * 8));
results.Properties.VariableNames = header;

% compute for every car for every segment
for car = 1 : cars
    for seg = 1 : SEGS
        % compute end of current segment 
        segEnd = segIncrease * seg;
        
        % load AccZ data from current car in lenght of current segment
        tmp = data{car}{1:segEnd, 'AccZ'};
        
        results{seg, sprintf('Car%dMeth1',car)} = var(tmp);
        results{seg, sprintf('Car%dMeth2',car)} = wentropy(tmp, 'shannon');
        results{seg, sprintf('Car%dMeth3',car)} = skewness(tmp);
        results{seg, sprintf('Car%dMeth4',car)} = kurtosis(tmp);
        
        % load GyrY data from current car in lenght of current segment
        tmp = data{car}{1:segEnd, 'GyrY'};
        
        results{seg, sprintf('Car%dMeth5',car)} = var(tmp);
        results{seg, sprintf('Car%dMeth6',car)} = wentropy(tmp, 'shannon');
        results{seg, sprintf('Car%dMeth7',car)} = skewness(tmp);
        results{seg, sprintf('Car%dMeth8',car)} = kurtosis(tmp);
        
        % inform user about progress
        fprintf("Car: %d segment: %d / %d done\n", car, seg, SEGS);
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

resultsPlotStacked(pathSave);

%% PLOT STATISTICS RESULTS IN SCATTER
fprintf("Printing scatter plot\n");

resultsPlotScatter(pathSave, [2, 7, 8]);

%% CODE END
