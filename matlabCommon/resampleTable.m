function data = resampleTable(data, frequency, mode)

% change time to table time
data{:,'Time'} = data{:,'Time'} - data{1,'Time'};

% convert first column to time vector
time = seconds(table2array(data(1:end,1)));

% convert table to timetable using converted time vector
data = table2timetable(data(:,2:end),'RowTimes',time);

% resample time table to desired frequency with method
data = retime(data, 'regular', mode, 'SampleRate', frequency);

% change timetable to table
data = timetable2table(data);

% change to table and exclude ' sec' from time column
data = convertvars(data,'Time','seconds');

end
