%function plotUBLOXmap(file)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

clear; close all; clc;

file = "C:\Users\geibfil\Desktop\JRC-E-3\experiments\1308-01\parsed_data\UBOX_proc.csv"

opts = detectImportOptions(file);
[time, utc, latNum, lonNum, height, tow, gpsFix, satNum, posDOP, horAcc, verAcc, head, speed, lat, lon,] = readvars(file,opts);

figure('Name','UBLOX GPS points','NumberTitle','off','units','normalized','outerposition',[0 0 1 1]);

geoshow(lat, lon, 'DisplayType', 'Point', 'Marker', '+', 'Color', 'red');

%end

