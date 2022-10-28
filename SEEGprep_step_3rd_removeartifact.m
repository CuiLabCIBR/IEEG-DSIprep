%% find bad channel of the seeg data
clc;clear;close all;
%% start the fieldtrip
ToolPath = 'E:\IEEG_DSI_connectome\x_toolbox';
% add fieldtrip
addpath(fullfile(ToolPath, 'fieldtrip'));
ft_defaults;
%% read the data
SeegPrepFolder = 'E:\IEEG_DSI_connectome\d_IEEGprep\step_2_IEEGprep';
SubjList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, ...
23, 28, 30, 31, 33, 34, 36, 47, 54, 57, 62, 63, 65, 66, 70, 72, 77, 78, 81, 85, 87, 93, 94, 96];
for SS = 1:length(SubjList)
        SubjNum = SubjList(SS);
        SubjId = ['sub-', num2str(SubjNum, '%04d')];
        DataFolder = fullfile(SeegPrepFolder, 'step_2_seeg_bandpass_delinenoise_downsample_dezerochannel', SubjId);
        DataDir = dir(fullfile(DataFolder, 'sub-*'));
        for RUN=1:length(DataDir)
            Data = load(fullfile(DataDir(RUN).folder, DataDir(RUN).name));
            [Data, ArtifactInfo] = artifact_reject(Data.Data);
            % save the artifact information
            ArtifactFolder = fullfile(SeegPrepFolder, 'step_3_artifact_info', SubjId, 'awake');
            mkdir(ArtifactFolder);
            SaveName = strsplit(DataDir(RUN).name, '.');
            SaveName = [SaveName{1}, '_artifactinfo.mat'];
            save(fullfile(ArtifactFolder, SaveName), 'ArtifactInfo');
            % save the file
            CleanDataFolder = fullfile(SeegPrepFolder, 'step_3_cleandata', SubjId, 'awake');
            mkdir(CleanDataFolder);
            SaveName = strsplit(DataDir(RUN).name, '.');
            SaveName = [SaveName{1}, '_clean.mat'];
            save(fullfile(CleanDataFolder, SaveName), 'Data', '-v7.3');
        end
end

