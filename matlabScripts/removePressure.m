function ret = removePressure(path)

% load data as table
data = readtable(path);

% remove pressure
data = removevars(data, 'Pres');

% write table to CSV
writetable(data, path);

% end of code
ret = true;

end