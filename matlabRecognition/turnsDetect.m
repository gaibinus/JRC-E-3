function ret = turnsDetect(carPath)

%% LOAD DATA

% constant frequency
FREQ = 20;

% load car data
prev = readtable(strcat(carPath, '\processed_data\IMU_velocity.csv'));
data = readtable(strcat(carPath, '\parsed_data\IMU_compensated_20.csv'));
bound = readtable(strcat(carPath, '\processed_data\IMU_boundaries.csv'));
laps = readtable(strcat(carPath, '\processed_data\IMU_laps.csv'));

% edit table
data = table(data.Time, data.AccZ, prev.VeloZ, bound.Bound, ...
                           'VariableNames', {'Time' 'Acc' 'Velo' 'Bound'});

% modifi velocity data
data.Acc = abs(data.Acc - 9.8058129520 / 10);

% create convolution matrix and proceed convolution
convMat = ones(1, FREQ * 2) / FREQ * 2;
tmp = conv(convMat, data.Acc, 'full');

% compute convolution offsets and cut edges
data.Acc = tmp(ceil(size(convMat,2)/2) : end-floor(size(convMat,2)/2));

%% FIND TURNS

% create convolution matrix and proceed convolution
convMat = ones(1, FREQ * 2) / FREQ * 2;
tmp = conv(convMat, data.Velo, 'full');

% compute convolution offsets and cut edges
data.Conv = tmp(ceil(size(convMat,2)/2) : end-floor(size(convMat,2)/2));
        
% create copy
data.Turn = data.Conv;

% create new data columns for treshold values
data.PosTH = nan(size(data.Turn, 1), 1);
data.NegTH = nan(size(data.Turn, 1), 1);

% process lap by lap
for lap = 1 : size(laps, 1)
    % compute first and last data line of current lap
    lapSt = laps.Start(lap) * FREQ;
    lapEn = laps.End(lap) * FREQ;
    
    % treshold for left and right turn, treshold for roundabout
    lapMed = median(data.Turn(lapSt:lapEn));
    signStd = sign(data.Turn(lapSt:lapEn));
    posTH = lapMed + std(data{lapSt:lapEn, 'Turn'}(signStd == 1));
    negTH = lapMed + std(data{lapSt:lapEn, 'Turn'}(signStd == -1)) * -1/2;
    rouTH = max(data.Turn(lapSt:lapEn)) - posTH;
    
    % write computed treshold to CSV file
    data.PosTH(lapSt : lapEn) = posTH;
    data.NegTH(lapSt : lapEn) = negTH;
    
    % clear background noise based on treshold
    ind = negTH < data.Turn(lapSt:lapEn) & data.Turn(lapSt:lapEn) < posTH;
    data{lapSt:lapEn, 'Turn'}(ind) = 0;
    
    % label everything expect detected turns
    label = bwlabel(data.Turn(lapSt:lapEn) ~= 0);
    
    % go thru all of the labeled groups
    for group = 1 : max(label)
        % check if current group contains roundabout
        if max(data{lapSt:lapEn, 'Turn'}(ismember(label, group))) >= rouTH
            data{lapSt:lapEn, 'Turn'}(ismember(label, group)) = 0;
        end
        
        % remove turn if is shorter then 1 s
        if nnz(label == group) <= FREQ
            data{lapSt:lapEn, 'Turn'}(ismember(label, group)) = 0;
        end
    end
    
    % if value is not 0 then it is turn
    data{lapSt:lapEn, 'Turn'}(data.Turn(lapSt:lapEn) ~= 0) = 1; 
       
    % remove last right turn before end of lap ~ last 10 s
    lapBrake = (laps{lap, 'End'} - 10) * FREQ;
    data.Turn(lapBrake:lapEn) = 0;
end

% normalize data
data.Turn(data.Bound == 1) = 0;

% write table to CSV
writetable(data, strcat(carPath, '\processed_data\IMU_turns.csv'));

%% END OF SCRIPT
ret = true;

end
