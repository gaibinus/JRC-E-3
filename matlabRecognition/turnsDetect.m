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
    
    % create copy of values
    lapVals = data.Turn(lapSt:lapEn);
    
    % treshold for left and right turn, treshold for roundabout
    lapMed = median(data.Turn(lapSt:lapEn));
    posTH = lapMed + std(data{lapSt:lapEn, 'Turn'}) * 1/4;
    negTH = posTH * -1;
    rouTH = max(data.Turn(lapSt:lapEn)) - posTH;
    
    % write computed treshold to CSV file
    data.PosTH(lapSt : lapEn) = posTH;
    data.NegTH(lapSt : lapEn) = negTH;
    
    % clear background noise based on treshold
    ind = negTH < lapVals & lapVals < posTH;
    data{lapSt:lapEn, 'Turn'}(ind) = 0;
    data{lapSt:lapEn, 'Turn'}(~ind) = 1;
    
    % label every turn
    label = bwlabel(data.Turn(lapSt:lapEn));
    
    % remove ROUNDABOUT: go thru all of the labeled groups
    for group = 1 : max(label)
        % check if current group contains roundabout
        if max(lapVals(ismember(label, group))) >= rouTH
            data{lapSt:lapEn, 'Turn'}(ismember(label, group)) = 0;
        end
    end
     
    % check for area between value and treshold for TURNS
    label = bwlabel(data.Turn(lapSt:lapEn));
    for group = 1 : max(label)
        
        % compute area in current group for LEFT turn
        if sum(lapVals(ismember(label, group))) > lapMed
            area = sum(abs(lapVals(ismember(label, group)) - posTH));
            
            % remove turn if area is too small
            if area < nnz(label == group) * posTH
                data{lapSt:lapEn, 'Turn'}(ismember(label, group)) = 0;
            end
                 
        % compute area in current group for RIGHT turn
        else
            area = sum(abs(lapVals(ismember(label, group)) - negTH));
        
            % remove turn if area is too small
            if area < abs(nnz(label == group) * negTH)
                data{lapSt:lapEn, 'Turn'}(ismember(label, group)) = 0;
            end
         end
        
    end
     
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
