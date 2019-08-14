%function plotUBLOXmap(file)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

clear; close all; clc;

file = "C:\Users\geibfil\Desktop\UBOX_proc.txt"

opts = detectImportOptions(file);
[time, utc, latNum, lonNum, height, tow, gpsFix, satNum, posDOP, horAcc, verAcc, head, speed, lat, lon,] = readvars(file,opts);

figure('Name','UBLOX GPS points','NumberTitle','off','units','normalized','outerposition',[0 0 1 1]);

geoshow(lat, lon, 'DisplayType', 'Point', 'Marker', '+', 'Color', 'red');

%end

