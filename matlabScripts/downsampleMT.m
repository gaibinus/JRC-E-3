
close all; clear; clc;

file = "C:\Users\geibfil\Desktop\MT_proc.csv";
table = readtable(file);
table = table2timetable(table);