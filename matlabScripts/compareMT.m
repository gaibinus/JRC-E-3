clear; close all; clc;

oldTable = data2timetable('/home/filip/CVUT/intership/JRC/work/MT_proc.csv');
newTable = data2timetable('/home/filip/CVUT/intership/JRC/work/MT_mean_20.csv');

oldTable = oldTable(:,1:end-1);
newTable = newTable(:,1:end-1);

timeTable = synchronize(oldTable, newTable, 'union', 'linear');

% create figure and set it up
figAcc = figure();
figAcc.Name = 'comparation of MT acceleration';
figAcc.NumberTitle = 'off';

% create stacked plot
statPlot = stackedplot(timeTable,'-');
statPlot.DisplayVariables = {{'acc_X','Nacc_X'},{'acc_Y','Nacc_Y'},{'acc_Z','Nacc_Z'}};

statPlot.GridVisible = 'off';
statPlot.XLabel = 'Time [s]';