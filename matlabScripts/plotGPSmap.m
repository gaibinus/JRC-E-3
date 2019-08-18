function plotGPSmap(file)

% load data as table
data = readtable(file);

% create figure and set it up
fig = figure();
fig.Name = 'GPS points deviation map';
fig.NumberTitle = 'off';

% create geo map
geoshow(data{:,'Lat'}, data{:,'Lon'}, 'DisplayType', 'Point', 'Marker', '+', 'Color', 'red');

end
