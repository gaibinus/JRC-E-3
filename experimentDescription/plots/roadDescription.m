
%% CREATE FIGURE
fig = figure;
fig.WindowState = 'maximized';
fig.NumberTitle = 'off';
fig.Name = 'ROAD DESCRIPTION TEMPLATE';
fig.Color = [1 1 1];

colormap(hsv);

%% CREATE MAP

name = 'openstreetmap';
url = 'a.tile.openstreetmap.org';

attribution = char(uint8(169)) + "OpenStreetMap contributors";

displayName = 'Open Street Map';

addCustomBasemap(name,url,'Attribution',attribution,'DisplayName',displayName)

pts = gpxread('boston_placenames');
gb = geobubble(pts.Latitude,pts.Longitude,'Basemap','openstreetmap');
gb.BubbleWidthRange = 25;
gb.MapLayout = 'maximized';
gb.ZoomLevel = 14;