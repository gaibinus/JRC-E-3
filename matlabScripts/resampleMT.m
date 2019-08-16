function ret = resampleMT(inFile, outFile, freq, metod)

% load data to time table
table = data2timetable(inFile);

% resample time table to desired frequency with metod
table = retime(table, 'regular', metod, 'SampleRate', freq);

% export newly sampled time table to desired csv file
table = timetable2table(table);

% change to table and exclude ' sec' from time column
table = convertvars(table,'Time','seconds');

% export table to desired csv file
writetable(table, outFile);

% if okay, return true
ret = true;

end