close all; clear; clc;

file = "/home/filip/CVUT/intership/JRC/work/MT_proc.csv";
data = readtable(file);
time = seconds(table2array(data(1:end,1)));
data = table2timetable(data(:,2:end),'RowTimes',time);


