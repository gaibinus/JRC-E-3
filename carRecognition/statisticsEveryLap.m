
close all; clear; clc;

%% FILE MANAGEMENT

% load experiment data structure as data
dataPath = 'C:\Users\geibfil\Desktop\JRC-E-3\experiments\data_10.mat';

% load experiment data structure
load(dataPath, 'data');

% save constants
SEGMENT_SIZE = 20; % in [s]
SAMPLE_RATE = 10; % in [Hz]
CARS = size(data, 1);

%% COMPUTE STATISTICS

% compute increase between segments
segIncrease = SEGMENT_SIZE * SAMPLE_RATE;

% find longest lap from whole data set
maxLength = max(max(cellfun(@height,data,'UniformOutput',true)));

% compute number of segments
segCount = floor(maxLength / segIncrease);

% prealloc results cell array as: results{car, method}
results = cell(CARS, 8);

for car = 1 : CARS
    % create table header as cell array
    header = sprintf('Car%dLap%d,', [car*ones(1,20) ; 1:20]);
    header = strsplit(header, ',');
    header(cellfun('isempty',header)) = [];
    
    % create tables of every method for current car
    for method = 1 : 8
        results{car, method} = ...
            array2table(zeros(segCount, 20), 'VariableNames', header);
    end
       
    for segment = 1 : segCount
        % compute end of current segment 
        segEnd = segIncrease * segment;
        
        % prealloc tmp results as: tmpResults{method, lap}
        tmpResults = NaN(8, 20);
              
        for lap = 1 : 20    
            % check if segEnd overflov current lap
            if segEnd > size(data{car, lap}, 1)
                continue;
            end
            
            % load AccZ data from current lap in lenght of current segment
            tmpData = data{car, lap}{1:segEnd, 'AccZ'};

            tmpResults(1, lap) = var(tmpData);
            tmpResults(2, lap) = wentropy(tmpData, 'shannon');
            tmpResults(3, lap) = skewness(tmpData);
            tmpResults(4, lap) = kurtosis(tmpData);

            % load GyrY data from current lap in lenght of current segment
            tmpData = data{car, lap}{1:segEnd, 'GyrY'};

            tmpResults(5, lap) = var(tmpData);
            tmpResults(6, lap) = wentropy(tmpData, 'shannon');
            tmpResults(7, lap) = skewness(tmpData);
            tmpResults(8, lap) = kurtosis(tmpData);
        end
        
        % add current segment to results
        for method = 1 : 8
            results{car, method}{segment, :} = tmpResults(method,:);            
        end
        
    end
end

%% PLOT STATISTICS RESULTS FOR EVERY METHODE

% create array with method names and data names
methodNames = ["variance", "wentropy", "skewness", "kurtosis"];
dataNames = ["acceleration on Z axis", "gyroscope on Y axis"];

for method = 1 : 8

   % compute methode and data name strings
   methodStr = methodNames(rem(method-1, 4) + 1);
   dataStr = dataNames(floor((method-1)/4) + 1);

   % create figure and set it up
   fig = figure();
   fig.Name = strcat(methodStr, ' of ', dataStr);
   
   % join all cars to one table
   plotResults = [results{:,method}];
   
   % create display variables parameter
   dispVar = cell(20,1);
   for lap = 1 : 20
       tmp = sprintf('Car%dLap%d,', [1:CARS; lap * ones(1,CARS)]);
       tmp = strsplit(tmp, ',');
       tmp(cellfun('isempty',tmp)) = [];
       dispVar{lap} = tmp;
   end
   
   % create display labels parameter
   dispLab = strsplit(sprintf('Lap %d,', 1:20), ',');
   dispLab(cellfun('isempty',dispLab)) = [];
   
   % create legend labels parameter
   legLab = strsplit(sprintf('Car %d,', 1:CARS), ',');
   legLab(cellfun('isempty',legLab)) = [];
   
   % left side of figure
   subLeft = subplot(1,2,1);
   
   % create left plot from 1 to 10
   leftPlot = stackedplot(plotResults, dispVar(1:10));
   leftPlot.DisplayLabels = dispLab(1:10);
   leftPlot.XLabel = 'Segment ID';
   leftPlot.AxesProperties(1).LegendLabels = legLab;
   leftPlot.AxesProperties(1).LegendVisible = 'on'; 
   for i = 2:10
        leftPlot.AxesProperties(i).LegendVisible = 'off';
   end
   
   % right side of figure
   subRight = subplot(1,2,2);
   
   % create left plot from 11 to 20
   rightPlot = stackedplot(plotResults, dispVar(11:20));
   rightPlot.DisplayLabels = dispLab(11:20);
   rightPlot.XLabel = 'Segment ID';
   rightPlot.AxesProperties(1).LegendLabels = legLab;
   rightPlot.AxesProperties(1).LegendVisible = 'on'; 
   for i = 2:10
        rightPlot.AxesProperties(i).LegendVisible = 'off';
   end
      
end   

