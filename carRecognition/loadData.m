function data = loadData(pathExp)

% load experiment configuration file
config = readtable(strcat(pathExp, '\config.csv'));

% create cell array CARS x LAPS
data = cell(size(config,1), 20);

% go thru every car and its every lap
for car = 1:size(config,1)
    for lap = 1:20
        
        % compute lap number according to experiment config file
        lapNum = config{car, sprintf('Lap%d', lap)};
        lapNum = sprintf('%02d', lapNum);
        
        % compute file path for current lap of current car
        pathFile = char(strcat(pathExp, '\', config{car, 'ExpName'}, ...
                   '\final_data\IMU_lap_', lapNum, '.csv'));
              
        % add current lap of current car to data cell array
        data(car, lap) = {readtable(pathFile)};
        
        % inform user about progress
        fprintf('INFO: table of car: %d lap: %d loaded\n', car, lap);
        
    end
end

end
