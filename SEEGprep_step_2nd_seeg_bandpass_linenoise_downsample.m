clc;clear;close all;
%% start the fieldtrip
ToolPath = 'E:\IEEG_DSI_connectome\x_toolbox';
% add fieldtrip
addpath(fullfile(ToolPath, 'fieldtrip'));
ft_defaults;
%% 
SubjList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, ...
23, 28, 30, 31, 33, 34, 36, 47, 54, 57, 62, 63, 65, 66, 70, 72, 77, 78, 81, 85, 87, 93, 94, 96];
for SS = 1:length(SubjList)
    SubjNum = SubjList(SS);
    xlz.SubjId = ['sub-', num2str(SubjNum, '%04d')];
    xlz.ChannelType = 'SEEG';
    xlz.BrainstormDbDir = 'E:\IEEG_DSI_connectome\e_brainstorm_database\SEEGxuanwu';
    xlz.SeegRawFolder = 'E:\IEEG_DSI_connectome\d_IEEGprep\step_0_IEEGrawdata';
    xlz.SaveFolder = fullfile(['E:\IEEG_DSI_connectome\d_IEEGprep\step_2_IEEGprep\' ...
        'seeg_bandpass_delinenoise_downsample_dezerochannel'], xlz.SubjId);
    mkdir(xlz.SaveFolder);
    Data = seeg_bandpass_delinenoise_downsample_dezerochannel(xlz);
end


%%
function Data = seeg_bandpass_delinenoise_downsample_dezerochannel(xlz)
%
%
%
%
    %% read the channel information from brianstorm database
    SubjId = xlz.SubjId;
    BrainstormDbDir = xlz.BrainstormDbDir;
    BrainstormChanDir = dir(fullfile(BrainstormDbDir, 'data', SubjId, '@raw*', 'channel.mat'));
    ChannelInfor = load(fullfile(BrainstormChanDir(1).folder, BrainstormChanDir(1).name));
    BadChannelGroup = [];
    BadChannelNum=1;
    BadChannelGroup{BadChannelNum} = 'all';
    ChannelType = xlz.ChannelType;
    for CL = 1:length(ChannelInfor.Channel)
        if strcmp(ChannelInfor.Channel(CL).Type, ChannelType)
            SeegChannel = ChannelInfor.Channel(CL).Name;
        else
            BadChannel = [];
            BadChannel = ChannelInfor.Channel(CL).Name;
            BadChannelNum = BadChannelNum + 1;
            BadChannelGroup{BadChannelNum} = ['-', BadChannel];
        end
    end
    %% preprocessing the SEEG signals: exculde none-seeg channels, band pass filtering, line noise filtering
    % read the signals file
    SeegRawFolder = xlz.SeegRawFolder;
    SeegRawSubjFolder = fullfile(SeegRawFolder, SubjId, 'ieeg', 'awake');
    SeegRawDir = dir(fullfile(SeegRawSubjFolder, 'sub-*'));
    for RUN = 1:length(SeegRawDir)
        Data = [];
        cfg = [];
        cfg.dataset = fullfile(SeegRawDir(RUN).folder, SeegRawDir(RUN).name);
        Data = ft_preprocessing(cfg);
        %% exclude none-interest channels
        disp('*******************************************************');
        disp(['exclued none-seeg channels:', SubjId]);
        disp('*******************************************************');
        cfg = [];
        cfg.channel = BadChannelGroup;
        Data = ft_preprocessing(cfg, Data);
        %% bandpass filtering
        disp('*******************************************************');
        disp(['bandpass filtering:', SubjId]);
        disp('*******************************************************');
        cfg = [];
        cfg.detrend = 'yes';
        cfg.demean = 'yes';
        cfg.baselinewindow = 'all';
        cfg.bpfilter = 'yes';
        cfg.bpfreq = [0.1, 160]; 
        cfg.bpfiltord = 3; 
        Data = ft_preprocessing(cfg, Data);
        %% linenoise filtering
        disp('*******************************************************');
        disp(['line-noise filtering:', SubjId]);
        disp('*******************************************************');
        cfg = [];
        cfg.detrend = 'yes';
        cfg.demean = 'yes';
        cfg.baselinewindow = 'all';
        cfg.bsfilter = 'yes';
        cfg.bsfiltord = 3;
        cfg.bsfreq = [49 51; 99 101; 149 151]; % line frequency
        Data = ft_preprocessing(cfg, Data);
        %% downsample
        disp('*******************************************************');
        disp(['downsample:', SubjId]);
        disp('*******************************************************');
        cfg = [];
        cfg.resamplefs = 320; 
        cfg.detrend  = 'yes'; 
        cfg.demean  = 'yes'; 
        cfg.baselinewindow  = 'all'; 
        Data = ft_resampledata(cfg, Data);
        %% find zero channel and delete them
        disp('*******************************************************');
        disp(['delete zero channels:', SubjId]);
        disp('*******************************************************');
        Var = var(Data.trial{1}');
        ZeroChannels = Data.label(find(Var<0.00001));
        ZeroChannelGroup = [];
        for CL = 1:length(ZeroChannels)
            ZeroChannelGroup{CL} = ['-', ZeroChannels{CL}];
        end
        ZeroChannelGroup = [{'all'}, ZeroChannelGroup];
        cfg = [];
        cfg.channel = ZeroChannelGroup;
        Data = ft_preprocessing(cfg, Data);
        % save the data
        disp('*******************************************************');
        disp(['save:', SubjId]);
        disp('*******************************************************');
        Str = strsplit(SeegRawDir(RUN).name, '.');
        Str = strsplit(Str{1}, '_');
        SaveName = join([Str(1:end-1), {'seeg'}, {'bandpass'}, {'delinenoise'}, {'downsample'}, {'dezerochannel'}],  "_");
        SaveFolder = xlz.SaveFolder;
        save(fullfile(SaveFolder, SaveName{1}), 'Data', '-v7.3');
    end
end
