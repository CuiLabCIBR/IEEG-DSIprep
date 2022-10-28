clc; clear; close all;
%% start the brainstrom
toolpath = 'E:\IEEG_DSI_connectome\x_toolbox';
% add brainstorm3
addpath(fullfile(toolpath, 'brainstorm3'));
% add spm12
addpath(fullfile(toolpath, 'spm12'));
% add fieldtrip
addpath(fullfile(toolpath, 'fieldtrip'));
ft_defaults;
brainstorm;
iProtocol = 1;
%% set the brainstorm database dir
BrainstormDbDir = 'E:\IEEG_DSI_connectome\e_brainstorm_database';
bst_set('BrainstormDbDir',   BrainstormDbDir);
protocol_name = 'SEEGxuanwu';
%% create new protocol
try 
    action = 'create';
    sProtocol.Comment = protocol_name;
    sProtocol.SUBJECTS = [BrainstormDbDir, '\SEEGxuanwu\anat'];
    sProtocol.STUDIES = [BrainstormDbDir, '\SEEGxuanwu\data'];
    sProtocol.UseDefaultAnat = 1;
    sProtocol.UseDefaultChannel = 1;
    iProtocol = db_edit_protocol(action, sProtocol);
catch
    disp('the protocol is already existing');
end
%% add new subject and import freesurfer file
iProtocol = 1;
bst_set('iProtocol', iProtocol);
iProtocol=bst_get('iProtocol');
list = [7, 29, 30, 34, 37, 38, 39, 52, 54, 55, 62, 63, 66, 70, 77];
for L = 1:length(list)
    n = list(L);
    try
    SubjectName = ['sub-', num2str(n, '%04d')];
    [sSubject, iSubject] = db_add_subject(SubjectName, n, 0, 0);
    FsDir = ['E:\IEEG_DSI_connectome\c_MRIprep\step_3_freesurfer\sub-', num2str(iSubject, '%04d')];
    nVertices=15000;
    isInteractive=0;
    sFid = [];
    isExtraMaps = 0;
    isVolumeAtlas = 1;
    isKeepMri = 0;
    errorMsg = import_anatomy_fs(iSubject, FsDir, nVertices, isInteractive, sFid, isExtraMaps, isVolumeAtlas, isKeepMri);
    catch
        continue;
    end
end
%% import CT images and coregistration
% % 0. delete old ct file in brainstorm database
list = [7, 29, 30, 34, 37, 38, 39, 52, 54, 55, 62, 63, 66, 70, 77];
for a = 1:length(list)
    n = list(a);
    cd([BrainstormDbDir, '\SEEGxuanwu\anat\sub-', num2str(n, '%04d')]);
    CT_dir = dir('subjectimage_sub-*CT*mat');
    for m = 1:length(CT_dir)
         delete(fullfile(CT_dir(m).folder, CT_dir(m).name));
    end
    cd([BrainstormDbDir, '\SEEGxuanwu\data']);
end
% modify the protocol file
cd([BrainstormDbDir, '\SEEGxuanwu\data'])
protocol_mat = load('protocol.mat');
for a = 1:length(list)
    n = list(a);
    Anatomy = protocol_mat.ProtocolSubjects.Subject(n).Anatomy;
    m = 0;
    Anatomy_new = struct('Comment', {}, 'FileName', {});
    for L = 1:length(Anatomy)
        if ~contains(Anatomy(L).FileName, ['sub-',num2str(n, '%04d'), '_ses-001_run-001_CT'], 'IgnoreCase', true)
            disp(Anatomy(L).Comment);
            disp(Anatomy(L).FileName);
            m = m+1;
            Anatomy_new(m).Comment = Anatomy(L).Comment;
            Anatomy_new(m).FileName = Anatomy(L).FileName;
        end
    end
    protocol_mat.ProtocolSubjects.Subject(n).Anatomy = Anatomy_new;
end
save('protocol.mat', '-struct', 'protocol_mat');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
list = [7, 29, 30, 34, 37, 38, 39, 52, 54, 55, 62, 63, 66, 70, 77];
for n = 1:length(list)
        iSubject = list(n);
        try
        % 1. import the ct images
        CT_path = ['E:\IEEG_DSI_connectome\d_IEEGprep\step_0_IEEGrawdata\sub-', num2str(iSubject, '%04d'), '\Electrodes'];
        MriFile_dir = dir([CT_path, '\sub-',num2str(iSubject, '%04d'), '*CT*nii*']);
        MriFile = fullfile(MriFile_dir(1).folder, MriFile_dir(1).name);
        FileFormat = 'ALL';
        isInteractive = 0;
        isAutoAdjust = 0;
        Comment = ['sub-', num2str(iSubject, '%04d'), '_ses-001_run-001_CT'];
        Labels = [];
        [BstMriFile, sMri, Messages] = import_mri(iSubject, MriFile, FileFormat, isInteractive, isAutoAdjust, Comment, Labels);
        % 2. co-registration the CT to T1w
        sMriRef = load([BrainstormDbDir, '\SEEGxuanwu\anat\sub-', num2str(iSubject, '%04d'), '\subjectimage_MRI.mat']);
        Method = 'spm';
        isReslice = 0;
        isAtlas = 0;
        [MriFileReg, errMsg, fileTag, sMriReg] = mri_coregister(sMri, sMriRef, Method, isReslice, isAtlas);
        save(fullfile(CT_path, ['subjectimage_', sMriReg.Comment, '.mat']), '-struct', 'sMriReg');
        % 3. import the coregistration ct image
        MriFile = fullfile(CT_path, ['subjectimage_', sMriReg.Comment, '.mat']);
        FileFormat = 'ALL';
        isInteractive = 0;
        isAutoAdjust = 0;
        Comment = sMriReg.Comment;
        Labels = [];
        [BstMriFile, ~, Messages] = import_mri(iSubject, MriFile, FileFormat, isInteractive, isAutoAdjust, Comment, Labels);
        % 4. reslice the CT to T1w
        Method = 'spm';
        isReslice = 1;
        isAtlas = 0;
        [MriFileReg, errMsg, fileTag, sMriReg] = mri_coregister(sMri, sMriRef, Method, isReslice, isAtlas);
        save(fullfile(CT_path, ['subjectimage_', sMriReg.Comment, '.mat']), '-struct', 'sMriReg');
        % 5. import the coregistration and reslice ct image
        MriFile = fullfile(CT_path, ['subjectimage_', sMriReg.Comment, '.mat']);
        FileFormat = 'ALL';
        isInteractive = 0;
        isAutoAdjust = 0;
        Comment = sMriReg.Comment;
        Labels = [];
        [BstMriFile, ~, Messages] = import_mri(iSubject, MriFile, FileFormat, isInteractive, isAutoAdjust, Comment, Labels);
        catch
            continue;
        end
end
%% import the SEEG raw data
for iSubject = 1:112
    try
        SubjectNames = {['sub-', num2str(iSubject, '%04d')]};
        % Input files
        sFiles = [];
        path = 'E:\IEEG_DSI_connectome\d_IEEGprep\step_0_IEEGrawdata';
        seeg_dir = dir(fullfile(path, ['sub-', num2str(iSubject, '%04d')], 'ieeg', 'awake', 'sub-*'));
        RawFiles = fullfile(seeg_dir(1).folder, seeg_dir(1).name);
        % Start a new report
        bst_report('Start', sFiles);
        % Process: Create link to raw file
        if contains(seeg_dir(1).name, 'edf')
            FileFormat = 'EEG-EDF';
        elseif contains(seeg_dir(1).name, 'bdf')
            FileFormat = 'EEG-BDF';
        end
        sFiles = bst_process('CallProcess', 'process_import_data_raw', sFiles, [], ...
                'subjectname',    SubjectNames{1}, ...
                'datafile',       {RawFiles, FileFormat}, ...
                'channelreplace', 1, ...
                'channelalign',   1, ...
                'evtmode',        'value');
        % Save and display report
        ReportFile = bst_report('Save', sFiles);
        bst_report('Open', ReportFile);
    catch
        continue;
    end
end
%% modify the IEEG channel 
for iSubject = 76:76
    try
        cd([BrainstormDbDir, ...
            '\SEEGxuanwu\data\sub-', num2str(iSubject, '%04d'), ...
            '\@rawsub-', num2str(iSubject, '%04d'), '_state-awake_ses-001_task-rest_run-002_data']);
        channel_mat=load('channel.mat');
        for L = 1:length(channel_mat.Channel)
            name = channel_mat.Channel(L).Name;
            group = name(~isstrprop(name, "digit"));
            index = name(isstrprop(name, "digit"));
            index = str2double(index);
            if contains(name, 'Ch')
                channel_mat.Channel(L).Type = 'EEG';
                channel_mat.Channel(L).Group = [];
            elseif contains(name, 'DC')
                channel_mat.Channel(L).Type = 'EEG';
                channel_mat.Channel(L).Group = [];
            elseif isnan(index)
                channel_mat.Channel(L).Type = 'EEG';
                channel_mat.Channel(L).Group = [];
            elseif index >= 25
                channel_mat.Channel(L).Type = 'EEG';
                channel_mat.Channel(L).Group = [];
            else
                channel_mat.Channel(L).Type = 'SEEG';
                channel_mat.Channel(L).Group = group;
            end
        end
        save('channel.mat', '-struct', 'channel_mat');
    catch
        continue;
    end
end
%% modify the CT 
spm
%% export the channel location information
subj_list = [1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, ...
18, 19, 20, 21, 22, 23, 28, 30, 31, 33, 34, 36, 47, 54, 62, 63, ...
66, 70, 72, 77, 78, 81, 87, 93, 94, 96];
for n = 1:length(subj_list)
    subj_ID = ['sub-', num2str(subj_list(n), '%04d')];
    protocol_name = 'SEEGxuanwu';
    subj_chfp = [BrainstormDbDir, filesep, protocol_name, filesep, 'data', filesep, subj_ID];
    chp_dir = dir([subj_chfp, filesep, '@raw*', filesep, 'channel.mat']);
    ChannelFile = [chp_dir.folder, filesep, chp_dir.name]; 
    Modality='SEEG';
    TsvFile=[subj_ID, '_3mm.tsv'];
    Radius=3;
    TsvFile = export_channel_atlas(ChannelFile, Modality, TsvFile, Radius, 1, 1);
end
