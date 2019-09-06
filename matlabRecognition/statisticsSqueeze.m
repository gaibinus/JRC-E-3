
%% FILE MANAGEMENT
close all; clear; clc;

% \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

JRC_PATCH = 'C:\Users\geibfil\Desktop\JRC-E-3';
DATA_NAME = '11carsFull_200_squeezed.mat';
SEG_SIZE = 120; % in [s]
SAMPLE_RATE = 200; % in [Hz]
PARTS = {'FastFirstBump' 'SecondBump' 'WindowOne' 'VisitBump' 'WindowTwo'};

% \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

% inform user
fprintf("Loading data\n");

% load experiment data structure
dataPath = strcat(JRC_PATCH, '\experimentStructures\', DATA_NAME);
load(dataPath, 'data');

% compute rest of parameters
period = 1 / SAMPLE_RATE; % in [s]
cars = size(data, 2);


%% PREPARE DATA
fprintf("Merging laps of each car\n");

% connect laps in time domain
for car = 1 : cars
   for lap = 1 : 20
      for part = 2 : size(PARTS, 2)
         data{car}.(char(PARTS(part))){lap}{:,'Time'} = ...
               data{car}.(char(PARTS(part))){lap}{:,'Time'} + ...
               data{car}.(char(PARTS(part - 1))){lap}{end,'Time'} + period;     
      end
   end
   
   % add empty table column for future merged parts
   tmp = cell2table(cell(20, 1), 'VariableNames', {'Merged'});
   data{car} = [data{car} tmp];
end

% join parts of every lap of every car
for car = 1 : cars
   for lap = 1 : 20
      % copy first data table to 'Merged'
      data{car}.('Merged'){lap} = data{car}.(char(PARTS(1))){lap};
       
      % add next and next data table to 'Merged'
      for part = 2 : size(PARTS, 2)
        data{car}.('Merged'){lap} = ...
           [data{car}.('Merged'){lap}; data{car}.(char(PARTS(part))){lap}];
      end
   end
end

% join laps of every car
for car = 1 : cars
   % create lap shuffling permutation
   lapShuff = randperm(20);
    
   % copy first lap table to tmp variable
   tmp = data{car}.('Merged'){lapShuff(1)};
    
   % add next and next lap to tmp
   for lap = 2 : 20
      tmp = [tmp; data{car}.('Merged'){lapShuff(lap)}];         %#ok<AGROW>
   end
   
   % rewrite car cell
   data{car} = tmp;
end

%% COMPUTE STATISTICS
fprintf("Computing statistics\n");

% compute increase between segments
segIncrease = SEG_SIZE * SAMPLE_RATE;

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
        fprintf("Car: %d/%d segment: %d/%d done\n", car, cars, seg, SEGS);
    end    
end
    
%% NORMALIZE DISTANCE INTO <0;1> INTERVAL
fprintf("Normalizing distances\n");

results = normalizeDistances(results);

%% SAVE RESULTS TO RESULTS FOLDER

% compute saving path
DATA_NAME = strrep(DATA_NAME, '.mat', '_');
pathSave = strcat(JRC_PATCH, '\experimentResults\', DATA_NAME, ...
                  int2str(SEG_SIZE), '_(', char(join(PARTS,'-')), ').mat');

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
