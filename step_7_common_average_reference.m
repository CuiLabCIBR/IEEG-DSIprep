%% common average reference
% set the environment
start_fieldtrip;
addpath E:\IEEG_DSI_connectome\IEEGprep\function;
% set the workpath
workpath = 'E:\IEEG_DSI_connectome/IEEGprep/';
cd(workpath);
subj_list = dir(fullfile(workpath, 'IEEGprep', 'ieegdata_awake', 'sub*'));
for s_num = 1:length(subj_list)
     subj_ID = subj_list(s_num).name;
     disp(subj_ID);
     state_ID = 'awake';
     task_ID = 'task-rest';
     subj_ieegdata_folder = fullfile(subj_list(s_num).folder, subj_list(s_num).name, 'awake', 'deartifact');
     data_dir = dir(fullfile(subj_ieegdata_folder, '*mat')); % read the file name of IEEG signals   
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
            % common average reference
            cfg = [];
            cfg.channel = 'all';
            cfg.reref = 'yes';
            cfg.refchannel = 'all';
            cfg.refmethod = 'avg';
            dataRFDDD_caref = ft_preprocessing(cfg, dataRFDD_deartifact);
            % save the file
            savefilepath = fullfile(workpath, 'IEEGprep', 'ieegdata_awake', subj_ID, 'awake', 'common_avg_ref');
            mkdir(savefilepath);
            savefilename = [subj_ID, '_', state_ID, '_', ses_ID, '_', task_ID, '_', run_ID, '_eeg.mat'];
            save(fullfile(savefilepath, savefilename), 'dataRFDDD_caref', '-v7.3');
      end
end
