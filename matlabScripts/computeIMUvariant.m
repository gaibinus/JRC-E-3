%function ret = computeIMUvariant(fileIn, fileOut)

fileIn = '/home/filip/CVUT/intership/JRC/work/IMU_parsed.csv';
fileOut = '/home/filip/CVUT/intership/JRC/work/IMU_config.txt';
startTime = 0;
stopTime = 10;

% load header from CSV
%fid = fopen(fileIn, 'r');
%csvHeader = strsplit(fgetl(fid), ',');
%fclose(fid);

% add results names to csv header
%csvHeader = [csvHeader 'AccVar' 'GyrVar' 'MagVar'];

% load data as matrix
data = readtable(fileIn);

accVar = var(data(:,1:3));
gyrVar = var(data(:,4:6));
magVar = var(data(:,7:9));

% merge data with new computed data
data = addvars(data, accVar gyrVar magVar];

% convert matrix to table and write to CSV
%table = array2table(data, 'VariableNames', csvHeader);
writetable(table, fileOut);

% if okay, return true
ret = true;

%end