%% FILE MANAGEMENT

close all; clear; clc;

% load experiment data structure as data
load('C:\Users\geibfil\Desktop\JRC-E-3\experiments\data_10.mat', 'data');

% save constants
SEGMENT_SIZE = 20; % in [s]
SAMPLE_RATE = 10; % in [Hz]
CARS = size(data, 1);

%% COMPUTE FAST FOURIER TRANSFORM

% compute increase between segments
segSize = SEGMENT_SIZE * SAMPLE_RATE;

% find longest lap from whole data set
maxLength = max(max(cellfun(@height,data,'UniformOutput',true)));

% compute number of segments
segCount = ceil(maxLength / segSize);

for imuid = 1 : 6
    for segment = 1 : segCount
        
        
        
    end
end