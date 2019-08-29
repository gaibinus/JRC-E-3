function ret = createDataStructure(pathExp, resampleRate)

% load experiment configuration file
config = readtable(strcat(pathExp, '\config.csv'));

% load number of cars
CARS = size(config,1);

% create data cell array CARS x LAPS
data = cell(CARS, 20);

% go thru every car and its every lap
for car = 1 : CARS
    for lap = 1 : 20
        % compute lap number according to experiment config file
        lapNum = config{car, sprintf('Lap%d', lap)};
        lapNum = sprintf('%02d', lapNum);
        
        % compute file path for current lap of current car
        pathFile = char(strcat(pathExp, '\', config{car, 'ExpName'}, ...
                   '\final_data\IMU_lap_', lapNum, '.csv'));
               
        % resample if it was requested
        if exist('resampleRate','var')
            % resampling
            table = resampleData(pathFile, 'return', resampleRate, 'mean');
        else
            % no resampling
            table = readtable(pathFile);
        end
               
        % add table to data cell array
        data(car, lap) = {table};
        
        % inform user about progress
        fprintf('INFO: table of car: %d lap: %d loaded\n', car, lap); 
    end
end

% create BNW mean table header
header = data{1, 1}.Properties.VariableNames;
header(strcmp(header,'Time')) = [];
header = [{'CarNo' 'ExpName'} , header];
 
% create BNW mean table CARS x VALUES
bnw = array2table(zeros(CARS, size(header, 2)), 'VariableNames', header);

% fill BNW mean table from car config files
for car = 1 : CARS
    % compute file path for config.txt of current car
    pathConfig = ...
        char(strcat(pathExp, '\', config{car, 'ExpName'},'\config.txt'));
    
    
    
    
end

% compute save patch
if exist('resampleRate','var')
    pathSave = strcat(pathExp, '\data_', int2str(resampleRate),'.mat');
else
    pathSave = strcat(pathExp, '\data.mat');
end

% inform user about progress
fprintf('INFO: saving data to:\n%s\n', pathSave);

% save data to disc
save(pathSave, 'data');

% if okay, return true
ret = true;

end
