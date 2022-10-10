% if the freesurfer encounter error in talairach_afd 
clc; clear; close all;
workpath = 'E:\IEEG_DSI_connectome\MRIprep'; cd(workpath);
sub_list = [111];
for ss = 1:length(sub_list)
    % change the directory
    sub = sub_list(ss); subj_ID = ['sub-', num2str(sub,'%04d')];
    cd(fullfile(workpath, 'DATA_anatprep_qsiprep', 'qsiprep', subj_ID, 'anat'));
    % import the anatomical MRI into MATLAB workspace
    T1fname = [subj_ID, '_desc-preproc_T1w.nii.gz'];
    T1raw = ft_read_mri(T1fname);
    % determine the nativ orientation of the anatomical MRI's left-right axis 
    ft_determine_coordsys(T1raw);
    % align the anatomical MRI to the ACPC coordinate system
    % https://static-content.springer.com/esm/art%3A10.1038%2Fs41596-018-0009-6/MediaObjects/41596_2018_9_MOESM7_ESM.mp4
    % the origin is at the anterior commissure (AC)
    % the y axis runs along the line between the AC and the posterior commissure(PC)
    % the z axis lies in the midline dividing the two cerebral hemishperes 
        % specify the AC and PC, 
        % specify the interhemishphere location along the midline at the top of the bran
        % specify a location in the brains's right hemisphere
    % 1. select points in each of the two hemispheres and note the change in
    % X-coordinates int the command window
    % 2. Hitting "R" on the keyboard assigns the current crosshair positions to
    % a point in the right hemisphere
    % 3. identify the anterior commissure, a small white matter tract that
    % connects the two hemispheres. It is located slightly posterior to the
    % genu of the corpus callosum.
    % 4. Hitting "A" on the keyboard assigns the current crosshair position to
    % the anterior commissure
    cfg = [];
    cfg.method = 'interactive'; 
    cfg.coordsys = 'acpc'; 
    T1_acpc = ft_volumerealign(cfg, T1raw);
    % write the preprocessed anatomical MRI out to a file
    mkdir(fullfile(workpath, 'DATA_T1acpc'));
    mkdir(fullfile(workpath, 'DATA_T1acpc', 'fieldtrip'));
    mkdir(fullfile(workpath, 'DATA_T1acpc', 'fieldtrip', subj_ID));
    cd(fullfile(workpath, 'DATA_T1acpc', 'fieldtrip', subj_ID));
    cfg = [];
    cfg.filename = [subj_ID, '_acpc_T1w'];
    cfg.filetype = 'nifti';
    cfg.parameter = 'anatomy';
    ft_volumewrite(cfg, T1_acpc);
end