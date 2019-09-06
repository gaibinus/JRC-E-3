function resultsPlotStacked(table)

CARS = size(table, 2) / 8;

% create array with method names and data names
dataNames = ["acceleration", "gyroscope"];
methodNames = ["variance", "wentropy", "skewness", "kurtosis"];

% create figure and set it up
fig = figure();
fig.Name = strcat('Statistics of merged laps in stacked plot');

% create display variables parameter
dispVar = cell(8,1);
for method = 1 : 8
   tmp = sprintf('Car%dMeth%d,', [1:CARS; method * ones(1,CARS)]);
   tmp = strsplit(tmp, ',');
   tmp(cellfun('isempty',tmp)) = [];
   dispVar{method} = tmp;
end

% create display labels parameter
dispLab = cell(8,1);
for method = 1 : 8
    dataStr = dataNames(floor((method-1)/4) + 1);
    methodStr = methodNames(rem(method-1, 4) + 1);
    dispLab{method} = {dataStr, methodStr};
end

% create legend labels parameter
legLab = strsplit(sprintf('Car %d,', 1:CARS), ',');
legLab(cellfun('isempty',legLab)) = [];

% reate and set up the plot
stackedPlot = stackedplot(table, dispVar);
stackedPlot.DisplayLabels = dispLab;
stackedPlot.XLabel = 'Segment ID';
stackedPlot.AxesProperties(1).LegendLabels = legLab;
stackedPlot.AxesProperties(1).LegendVisible = 'on'; 
for i = 2:8
    stackedPlot.AxesProperties(i).LegendVisible = 'off';
end

end

