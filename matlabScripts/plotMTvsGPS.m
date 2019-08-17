%function plotAccMTUvsGPS(mtuFile,gpsFile)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

close all; clear; clc;

mtuFile = '/home/filip/CVUT/intership/JRC/work/experiments/1408-01/parsed_data/MT_proc.csv';
gpsFile = '/home/filip/CVUT/intership/JRC/work/experiments/1408-01/parsed_data/UBOX_proc.csv';

% load files into timetables
mtuTT = data2timetable(mtuFile);
gpsTT = data2timetable(gpsFile);

mtuTT = mtuTT(timerange(seconds(0),seconds(120)),:);
gpsTT = gpsTT(timerange(seconds(0),seconds(120)),:);

% create figure and set it up
fig = figure();
fig.Name = 'Acceleration domain comparison';
fig.NumberTitle = 'off';

% plot data
subplot(2,1,1)
stackedplot(mtuTT, {'AccX' 'AccY' 'AccZ'});

subplot(2,1,2)
stackedplot(gpsTT, {'HorAcc' 'VerAcc'});

%end

