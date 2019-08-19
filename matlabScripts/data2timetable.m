function [timeTable] = data2timetable(filePath, rows)

% check if file exists
if exist(filePath, 'file') == 0
    error("Path does not exists");
end

% recognise options for csv loading
opts = detectImportOptions(filePath);

% check if number of rows was specified,
if exist('rows','var')
    % set options to load only required number of rows
    opts.DataLines = [2 rows+1];
end

% load data file
timeTable = readtable(filePath, opts);

% convert first column to time vector
time = seconds(table2array(timeTable(1:end,1)));

% convert table to timetable using converted time vector
timeTable = table2timetable(timeTable(:,2:end),'RowTimes',time);

end

