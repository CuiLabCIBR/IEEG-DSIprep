clc; clear; close all;
%% start the brainstrom
toolpath = 'E:\IEEG_DSI_connectome\z_tool';
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
    sProtocol.Comment = 'SEEGxuanwu';
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
for n = 98:112
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
protocol_mat = load('protocol.mat');
for n = 1:112
    cd([BrainstormDbDir, '\SEEGxuanwu\anat\sub-', num2str(n, '%04d')]);
    CT_dir = dir('subjectimage_sub-*CT*mat');
    for m = 1:length(CT_dir)
         delete(fullfile(CT_dir(m).folder, CT_dir(m).name));
    end
    cd([BrainstormDbDir, '\SEEGxuanwu\data']);
    Anatomy = protocol_mat.ProtocolSubjects.Subject(n).Anatomy;
    m = 0;
    Anatomy_new = [];
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
list = 1:112;
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
        isReslice = 1;
        isAtlas = 0;
        [MriFileReg, errMsg, fileTag, sMriReg] = mri_coregister(sMri, sMriRef, Method, isReslice, isAtlas);
        % 3. save the coregistration ct image
        save(fullfile(CT_path, ['subjectimage_', sMriReg.Comment, '.mat']), '-struct', 'sMriReg');
        % 4. import the coregistration ct image
        MriFile = fullfile(CT_path, ['subjectimage_', sMriReg.Comment, '.mat']);
        FileFormat = 'ALL';
        isInteractive = 0;
        isAutoAdjust = 0;
        Comment = sMriReg.Comment;
        Labels = [];
        [BstMriFile, sMri, Messages] = import_mri(iSubject, MriFile, FileFormat, isInteractive, isAutoAdjust, Comment, Labels);
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

    
