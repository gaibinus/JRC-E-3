function ret = resampleData(pathIn, pathOut, frequency, mode)

% load data to time table
data = data2timetable(pathIn);

% resample time table to desired frequency with method
data = retime(data, 'regular', mode, 'SampleRate', frequency);

% change timetable to table
data = timetable2table(data);

% change to table and exclude ' sec' from time column
data = convertvars(data,'Time','seconds');

% export table to new file or return as table
if strcmp(pathOut, 'return') == true
    % return resampled data as table
    ret = data;
else
    % export table to desired csv file
    writetable(data, pathOut);

    % if okay, return true
    ret = true;
end

end
