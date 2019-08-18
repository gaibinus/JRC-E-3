function ret = computeIMUvelo(fileIn, fileOut)

% load data as table
data = readtable(fileIn);

% compute sample frequency
freq = 1 / (data{2,'Time'} - data{1,'Time'});

% create filter
FUSE = ahrsfilter();
FUSE.SampleRate = freq;

% compute velocity and orientation
[~, velo] = FUSE([data{:,'AccX'}, data{:,'AccY'}, data{:,'AccZ'}], ...
                 [data{:,'GyrX'}, data{:,'GyrY'}, data{:,'GyrZ'}], ...
                 [data{:,'MagX'}, data{:,'MagY'}, data{:,'MagZ'}]);

% compute size of velocity vector
veloNorm = sqrt(sum(velo.^2,2));

% merge data with new computed data
data = addvars(data, velo(:,1), velo(:,2),velo(:,3), veloNorm, ...
               'NewVariableNames',{'VeloX' 'VeloY' 'VeloZ' 'VeloNorm'});

% convert matrix to table and write to CSV
writetable(data, fileOut);

% if okay, return true
ret = true;

end
