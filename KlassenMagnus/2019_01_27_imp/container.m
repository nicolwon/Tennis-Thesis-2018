dir_base = '/Users/nicolewongsoo/Documents/Fourth Year Uni/Full Year/Thesis/Tennis-Thesis-2018/Grand Slam Point Data/';
% filePattern = fullfile(dir_base, '*points.csv');

filePath = fullfile(dir_base, '2011-frenchopen-points.csv');
fileID = fopen(filePath);
points = textscan(fileID, '%s %s %f %f %f %f %f %f %f %f %f %f %f %s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'Delimiter', ',', 'HeaderLines', 1);
fclose(fileID);