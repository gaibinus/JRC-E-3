function ret = computeIMUvelo(fileIn, fileOut)

% check if file exists
if exist(fileIn, 'file') == 0
    error("Path does not exists");
end

% load header from CSV
fid = fopen(fileIn, 'r');
csvHeader = strsplit(fgetl(fid), ',');
fclose(fid);

% add results names to csv header
csvHeader = [csvHeader 'VeloX' 'VeloY' 'VeloZ' 'VeloNorm'];

% load data as matrix
data = readmatrix(fileIn);

% compute sample frequency
freq = 1 / (data(2,1) - data(1,1));

% create filter
FUSE = ahrsfilter();
FUSE.SampleRate = freq;

% compute velocity and orientation
[~, velocity] = FUSE(data(:,2:4),data(:,5:7),data(:,8:10));

% compute size of velocity vector
velocityNorm = sqrt(sum(velocity.^2,2));

% merge data with new computed data
data = [data velocity velocityNorm];

% convert matrix to table and write to CSV
table = array2table(data, 'VariableNames', csvHeader);
writetable(table, fileOut);

% if okay, return true
ret = true;

end

