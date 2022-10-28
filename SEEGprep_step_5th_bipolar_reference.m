%% bipolar reference
clc;clear;close all;
%% start the fieldtrip
ToolPath = 'E:\IEEG_DSI_connectome\x_toolbox';
% add fieldtrip
addpath(fullfile(ToolPath, 'fieldtrip'));
ft_defaults;
%% read the channel information from brianstorm database
SubjList = [23, 28, 30, 31, 33, 34, 36, 47, 54, 57, 62, 63, 65, 66, 70, 72, 77, 78, 81, 85, 87, 93, 94, 96];
SeegPrepFolder = 'E:\IEEG_DSI_connectome\d_IEEGprep\step_2_IEEGprep';
for s = 1:length(SubjList)
    SubjNum = SubjList(s);
    SubjId = ['sub-', num2str(SubjNum, '%04d')];
    BrainstormDbDir = 'E:\IEEG_DSI_connectome\e_brainstorm_database\SEEGxuanwu';
    BrainstormChanDir = dir(fullfile(BrainstormDbDir, 'data', SubjId, '@raw*', 'channel.mat'));
    ChannelInfor = load(fullfile(BrainstormChanDir(1).folder, BrainstormChanDir(1).name));
    %%  read the SEEG data
    SeegPrepFolder = 'E:\IEEG_DSI_connectome\d_IEEGprep\step_2_IEEGprep';
    DataDir = dir(fullfile(SeegPrepFolder, 'step_3_cleandata', SubjId, 'awake', 'sub-*'));
    for r = 1:length(DataDir)
        Data = load(fullfile(DataDir(r).folder, DataDir(r).name));
        ChannelBS = ChannelInfor.Channel;
        Data = bipolar_reference(Data.Data, ChannelBS);
        %% save the data
        SaveFolder = fullfile(SeegPrepFolder, 'step_4_bipolar_reference', SubjId, 'awake');
        mkdir(SaveFolder);
        SaveName = strsplit(DataDir(r).name, '.');
        SaveName = [SaveName{1}, '_bipolarref.mat'];
        save(fullfile(SaveFolder, SaveName), 'Data', '-v7.3');
    end
end

