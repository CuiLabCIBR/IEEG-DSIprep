% creat the single space delimited bval and bvec file
clc; clear; close all;
cd('E:\IEEG_DSI_connectome\MRIprep\btable_denger');
load('btable.mat');
% fprint the corrected bval file
fileID = fopen('dwi.corrected.bval', 'w');
for num = 1:length(bval)-1 
    fprintf(fileID, '%d ', bval(num)); 
end
fprintf(fileID, '%d\n', bval(num+1));
fclose(fileID);

% fprint the corrected bvec file
fileID = fopen('dwi.corrected.bvec', 'w');
for num = 1:length(bx)-1
    fprintf(fileID, '%f ', bx(num)); 
end
fprintf(fileID, '%f\n', bx(num+1));
for num = 1:length(by)-1
        fprintf(fileID, '%f ', by(num));
end
fprintf(fileID, '%f\n', by(num+1));
for num = 1:length(bz)-1
        fprintf(fileID, '%f ', bz(num));
end
fprintf(fileID, '%f\n', bz(num+1));
fclose(fileID);

