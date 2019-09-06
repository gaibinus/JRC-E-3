function table = normalizeDistances(table)

CARS = size(table, 2) / 8;

for method = 1 : 8
   % find minimum and maximum of the metode
   maximum = NaN;
   minimum = NaN;
   
   % search in every car
   for car = 1 : CARS
       % check for maximum
       tmp = max(table{:, sprintf('Car%dMeth%d', car, method)});
       if isnan(maximum) || maximum < tmp
          maximum = tmp; 
       end
       
       % check for minimum
       tmp = min(table{:, sprintf('Car%dMeth%d', car, method)});
       if isnan(minimum) || minimum > tmp
          minimum = tmp; 
       end
   end
   
   % normalize every car, used formula: (data - min) / (max - min)
   for car = 1 : CARS
        table{:, sprintf('Car%dMeth%d', car, method)} = ...
            (table{:, sprintf('Car%dMeth%d', car, method)} - minimum) ...
                                                    ./ (maximum - minimum);
   end
end

end

