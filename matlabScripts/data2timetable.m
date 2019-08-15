function [timeTable] = data2timetable(filePath)

% check if file exists
if exist(filePath, 'file') == 0
    error("Path does not exists");
end

% load data file
timeTable = readtable(filePath);

% convert first column to time vector
time = seconds(table2array(timeTable(1:end,1)));

% convert table to timetable using converted time vector
timeTable = table2timetable(timeTable(:,2:end),'RowTimes',time);

end

