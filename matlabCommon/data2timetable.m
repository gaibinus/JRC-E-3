function [data] = data2timetable(pathFile, rows)

% check if file exists
if exist(pathFile, 'file') == 0
    error("Path does not exists");
end

% recognize options for csv loading
opts = detectImportOptions(pathFile);

% check if number of rows was specified,
if exist('rows','var')
    % set options to load only required number of rows
    opts.DataLines = [2 rows+1];	
end

% load data file
data = readtable(pathFile, opts);

% convert first column to time vector
time = seconds(table2array(data(1:end,1)));

% convert table to timetable using converted time vector
data = table2timetable(data(:,2:end),'RowTimes',time);

end

