%% read the data and detect the artifact
% set the environment
start_fieldtrip;
% set the workpath
workpath = 'E:\IEEG_DSI_connectome/IEEGprep/';
cd(workpath);
subj_list = dir(fullfile(workpath, 'IEEGprep', 'ieegdata_awake', 'sub*'));
for s_num = 1:length(subj_list)
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
           data = dataRFD_debadchanel;
            %% identify the artifact segment       
            % ==================reject the jump========================
            cfg = [];
            cfg.continuous = 'yes';
            % channel selection, cutoff and padding
            cfg.artfctdef.zvalue.channel = 'all';
            cfg.artfctdef.zvalue.cutoff = 40;
            cfg.artfctdef.zvalue.trlpadding = 0;
            cfg.artfctdef.zvalue.artpadding = 0;
            cfg.artfctdef.zvalue.fltpadding = 0;
            % algorithmic parameters
            cfg.artfctdef.zvalue.cumulative = 'yes';
            cfg.artfctdef.zvalue.medianfilter = 'yes';
            cfg.artfctdef.zvalue.medianfiltord = 9;
            cfg.artfctdef.zvalue.absdiff = 'yes';
            % make the process interactive
            %cfg.artfctdef.zvalue.interactive = 'yes';
            [cfg_jump, artifact_jump] = ft_artifact_zvalue(cfg, data);
            % save the artifact information
            artifact_filefolder = fullfile(workpath, 'IEEGprep', 'ieegdata_awake', subj_ID, 'awake');
            save(fullfile( artifact_filefolder, [subj_ID, '_', run_ID, '_jump.mat']), 'cfg', 'artifact_jump', 'cfg_jump');
            % ================== reject the muscle ======================
            cfg = [];
            cfg.continuous = 'yes';
            % channel selection, cutoff and padding
            cfg.artfctdef.zvalue.channel = 'all';
            cfg.artfctdef.zvalue.cutoff = 20;
            cfg.artfctdef.zvalue.trlpadding = 0;
            cfg.artfctdef.zvalue.fltpadding = 0;
            cfg.artfctdef.zvalue.artpadding = 0.1;
            % algorithmic parameters
            cfg.artfctdef.zvalue.bpfilter = 'yes';
            cfg.artfctdef.zvalue.bpfreq = [110 140];
            cfg.artfctdef.zvalue.bpfiltord = 3;
            cfg.artfctdef.zvalue.bpfilttype = 'but';
            cfg.artfctdef.zvalue.hilbert = 'yes';
            cfg.artfctdef.zvalue.boxcar = 0.2;
            % make the process interactive
            %cfg.artfctdef.zvalue.interactive = 'yes';
            [cfg_muscle, artifact_muscle] = ft_artifact_zvalue(cfg, data);
            % save the artifact information
            artifact_filefolder = fullfile(workpath, 'IEEGprep', 'ieegdata_awake', subj_ID, 'awake');
            save(fullfile( artifact_filefolder, [subj_ID, '_', run_ID, '_muscle.mat']), 'cfg', 'artifact_muscle', 'cfg_muscle');
            % ===================reject the EOG=======================
            cfg = [];
            cfg.continuous = 'yes';
            % channel selection, cutoff and padding
            cfg.artfctdef.zvalue.channel  = 'all';
            cfg.artfctdef.zvalue.cutoff = 30;
            cfg.artfctdef.zvalue.trlpadding = 0;
            cfg.artfctdef.zvalue.artpadding = 0.1;
            cfg.artfctdef.zvalue.fltpadding = 0;
            % algorithmic parameters
            cfg.artfctdef.zvalue.bpfilter = 'yes';
            cfg.artfctdef.zvalue.bpfilttype = 'but';
            cfg.artfctdef.zvalue.bpfreq  = [2 15];
            cfg.artfctdef.zvalue.bpfiltord  = 3;
            cfg.artfctdef.zvalue.hilbert  = 'yes';
            % feedback
            %cfg.artfctdef.zvalue.interactive = 'yes';
            [cfg_EOG,  artifact_EOG] = ft_artifact_zvalue(cfg, data);
            % save the artifact information
            artifact_filefolder = fullfile(workpath, 'IEEGprep', 'ieegdata_awake', subj_ID, 'awake');
            save(fullfile( artifact_filefolder, [subj_ID, '_', run_ID, '_EOG.mat']), 'cfg', 'artifact_EOG', 'cfg_EOG');
            %% clean the artifact data
            cfg = [];
            cfg.artfctdef.reject = 'partial'; % this rejects complete trials, use 'partial' if you want to do partial artifact rejection
            cfg.artfctdef.eog.artifact = artifact_EOG; %
            cfg.artfctdef.jump.artifact = artifact_jump;
            cfg.artfctdef.muscle.artifact = artifact_muscle;
            dataRFDD_deartifact = ft_rejectartifact(cfg, data);
%             % view the clean data
%             cfg = [];  
%             cfg.ylim = [-40, 40];
%             cfg.viewmode = 'vertical';
%             cfg.preproc.demean  = 'yes';
%             cfg.preproc.detrend  = 'yes';
%             cfg.blocksize = 10;%duration in seconds for cutting continuous data in segments
%             cfg = ft_databrowser(cfg, dataRFDD_deartifact); % view the clean signals
            % save the file
            savefilepath = fullfile(workpath, 'IEEGprep', 'ieegdata_awake', subj_ID, 'awake', 'deartifact');
            mkdir(savefilepath);
            savefilename = [subj_ID, '_', state_ID, '_', ses_ID, '_', task_ID, '_', run_ID, '_eeg.mat'];
            save(fullfile(savefilepath, savefilename), 'dataRFDD_deartifact', '-v7.3');
      end
end
