function resultsPlotScatter(pathResults, methods)

% load data and compute number of cars
load(pathResults, 'results');
CARS = size(results, 2) / 8;

% create array with method names and data names
dataNames = ["acceleration", "gyroscope"];
methodNames = ["variance", "wentropy", "skewness", "kurtosis"];

% create figure and set it up
fig = figure();
[~, fig.Name, ~] = fileparts(pathResults);

% create layers of scatter plot in 2D or 3D
for car = 1 : CARS
    if size(methods, 2) == 2
        scatter(results{:, sprintf('Car%dMeth%d', car, methods(1))}, ...
                results{:, sprintf('Car%dMeth%d', car, methods(2))});
    elseif size(methods, 2) == 3
        scatter3(results{:, sprintf('Car%dMeth%d', car, methods(1))}, ...
                 results{:, sprintf('Car%dMeth%d', car, methods(2))}, ...
                 results{:, sprintf('Car%dMeth%d', car, methods(3))});  
    else
        error('Wrong number of methots to plot');
    end
    
    % keep adding layers to plot
    hold on;
end

% create X axis label
methodStr = methodNames(rem(methods(1)-1, 4) + 1);
dataStr = dataNames(floor((methods(1)-1)/4) + 1);
xlabel(strcat(methodStr, " of ", dataStr));

% create Y axis label
methodStr = methodNames(rem(methods(2)-1, 4) + 1);
dataStr = dataNames(floor((methods(2)-1)/4) + 1);
ylabel(strcat(methodStr, " of ",  dataStr));

% create Z axis label
if size(methods, 2) == 3
    methodStr = methodNames(rem(methods(3)-1, 4) + 1);
    dataStr = dataNames(floor((methods(3)-1)/4) + 1);
    zlabel(strcat(methodStr, " of ", dataStr));
end

% create legend
legArr = strsplit(sprintf('Car %d,', 1:CARS), ',');
legArr(cellfun('isempty',legArr)) = [];
legend(legArr, 'Location','Best');

% end of hold
hold off;

end

