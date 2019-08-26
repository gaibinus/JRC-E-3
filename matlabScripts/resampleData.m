function ret = resampleData(pathIn, pathOot, frequency, mode)

% load data to time table
data = data2timetable(pathIn);
	
% resample time table to desired frequency with method
data = retime(data, 'regular', mode, 'SampleRate', frequency);

% export newly sampled time table to desired csv file
data = timetable2table(data);

% change to table and exclude ' sec' from time column
data = convertvars(data,'Time','seconds');

% export table to desired csv file
writetable(data, pathOot);

% if okay, return true
ret = true;

end
