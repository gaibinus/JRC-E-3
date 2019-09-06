function ret = datastructSqueeze(pathExp, configName, resampleRate)

%% LOAD CONFIG FILE

% load experiment configuration file
config = readtable(fullfile(pathExp, 'dataStructures', configName));
configName = erase(configName, '.csv');

% load number of cars
CARS = size(config,1);

%% FIND THE LONGEST PARTS

% name of parts
parts = {'Start' 'StartTurn' 'FastFirstBump' 'PreRound' 'RoundOne'...
         'SecondBump' 'Curve' 'WindowOne' 'CrossOne' 'VisitBump'...
         'CrossTwo' 'WindowTwo' 'RoundTwo' 'WindowThree'};
 
% create table for minimum of erery part
maxParts = [table(['Car'; 'Lap'; 'Max'], 'VariableNames', {'Info'}), ...
                          array2table(NaN(3, 14), 'VariableNames', parts)];
        
% search for every part in every car
for car = 1 : CARS
    % compute file path for part sizes file of current car
    pathSizes = char(fullfile(pathExp, config{car, 'ExpName'}, ...
                                    'processed_data\IMU_parts_sizes.csv'));
           
    % open part sizes file as table
    sizes = readtable(pathSizes);
    
    for part = 1 : 14
        for lap = 1 : 20
            % compute lap number according to experiment config file
            lapNum = config{car, sprintf('Lap%d', lap)};
            
            % check if current size is minimal one
            if any(ismissing(maxParts{:, parts(part)})) || ...
               maxParts{3, parts(part)} < sizes{lapNum, parts(part)}

                % rewrite minimum table with new data
                tmp = sizes{lapNum, parts(part)};
                maxParts{:, parts(part)} = [car; lap; tmp];
            end
            
        end
    end
end
                                               
%% SQUEEZE DATA AND GENERATE DATA STRUCTURE

% create data cell array CARS X {LAPS x PARTS}
data = repmat({[array2table((1:20)', 'VariableNames', {'LapNo'}),...
               cell2table(cell(20,14), 'VariableNames', parts)]}, 1, CARS);

for car = 1 : CARS
    % compute file path for part times file of current car
    pathTimes = char(fullfile(pathExp, config{car, 'ExpName'}, ...
                                    'processed_data\IMU_parts_times.csv'));

    % open part times file as table
    times = readtable(pathTimes);

    % compute file path for part sizes file of current car
    pathSizes = char(fullfile(pathExp, config{car, 'ExpName'}, ...
                                    'processed_data\IMU_parts_sizes.csv'));

    % open part sizes file as table
    sizes = readtable(pathSizes);

    for lap = 1 : 20
        % compute lap number according to experiment config file
        lapNum = config{car, sprintf('Lap%d', lap)};
        lapStr = sprintf('%02d', lapNum);

        % compute file path for current lap of current car
        patchLap = char(strcat(pathExp, '\', config{car, 'ExpName'}, ...
                                  '\final_data\IMU_lap_', lapStr, '.csv'));

        % open current lap
        lapData = readtable(patchLap);

        for part = 1 : 14
            % compute resampling frequency
            freq = (resampleRate * maxParts{3, parts(part)}) / ...
                                                sizes{lapNum, parts(part)};

            % compute start and end line for current part
            partSt = round(times{lapNum, parts(part)} * 2000 + 1);
            partEn = round(partSt + sizes{lapNum, parts(part)} * 2000 - 1);

            % resample table
            data{car}{lap, parts(part)} = ...
                {resampleTable(lapData(partSt : partEn, :), freq, 'mean')};
           
            % inform user about progress
            fprintf('SQUEEZED: car: %d/%d; lap: %d/%d; part: %d/%d\n', ...
                                             car, CARS, lap, 20, part, 14); 
        end
    end
end


%% SAVE CREATED STRUCTURE

% compute save patch
pathSave = strcat(pathExp, '\dataStructures\', configName, '_', ...
                                   int2str(resampleRate), '_squeezed.mat');

% inform user about progress
fprintf('INFO: saving data to:\n%s\n', pathSave);

% save data to disc
save(pathSave, 'data');

% if okay, return true
ret = true;

end
