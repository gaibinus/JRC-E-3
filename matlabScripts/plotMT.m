function plotMT(file)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

opts = detectImportOptions(file);
[time, acc_X, acc_Y, acc_Z, gyr_X, gyr_Y, gyr_Z, mag_X, mag_Y, mag_Z] = readvars(file,opts);

figure('Name','MT sensor data','NumberTitle','off','units','normalized','outerposition',[0 0 1 1]);

subplot(3,1,1);
plot(time,acc_X,time,acc_Y,time,acc_Z)
title('Accelerometer')
xlabel('time [s]')
legend({'X axis','y axis','Z axis'},'Location','eastoutside')

subplot(3,1,2);
plot(time,gyr_X,time,gyr_Y,time,gyr_Z)
title('Gyroscope')
xlabel('time [s]')
legend({'X axis','y axis','Z axis'},'Location','eastoutside')

subplot(3,1,3);
plot(time,mag_X,time,mag_Y,time,mag_Z)
title('Magnetometer')
xlabel('time [s]')
legend({'X axis','y axis','Z axis'},'Location','eastoutside')

end

