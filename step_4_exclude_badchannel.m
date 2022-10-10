%% exclude the bad channels
% set the environment
start_fieldtrip;
% set the workpath
workpath = 'E:\IEEG_DSI_connectome/IEEGprep/';
cd(workpath);
subj_list = dir(fullfile(workpath, 'IEEGprep', 'ieegdata_awake', 'sub*'));
s_num = 23;
     subj_ID = subj_list(s_num).name;
     disp(subj_ID);
     state_ID = 'awake';
     task_ID = 'task-rest';
     subj_ieegdata_folder = fullfile(subj_list(s_num).folder, subj_list(s_num).name, 'awake', 'filtering');
     data_dir = dir(fullfile(subj_ieegdata_folder, '*mat')); % read the file name of IEEG signals
     badchannel_filefolder = fullfile(workpath, 'IEEGprep', 'ieegdata_awake', subj_ID, 'awake');
     load(fullfile(workpath, 'IEEGprep', 'ieegdata_awake', subj_ID, 'awake', [subj_ID, '_badchannel.mat']));
     for ddn = 1:length(data_dir)
            data_path = fullfile(data_dir(ddn).folder, data_dir(ddn).name);
            load(data_path);
            cell_str = strsplit(data_dir(ddn).name, '_'); % read the session number and run number
            for csn = 1:length(cell_str)
                    if contains(cell_str{csn}, 'ses') == 1
                                ses_ID = cell_str{csn};
                    end
                     if contains(cell_str{csn}, 'run') == 1
                                run_ID = cell_str{csn};
                    end
            end
           % exclude bad channels
           cfg = [];
           cfg.channel = badchannels_label.channel;
           dataRFD_debadchanel = ft_preprocessing(cfg, dataRF_downsample); 
           % save file
           savefilepath = fullfile(workpath, 'IEEGprep', 'ieegdata_awake', subj_ID, 'awake',  'debadchannels');
           mkdir(savefilepath);
           savefilename = [subj_ID, '_', state_ID, '_', ses_ID, '_', task_ID, '_', run_ID, '_eeg.mat'];
           save(fullfile(savefilepath, savefilename), 'dataRFD_debadchanel', '-v7.3');
end




