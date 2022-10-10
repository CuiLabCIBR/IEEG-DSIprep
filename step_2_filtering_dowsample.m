%% filtering the ieeg signal
% set the environment
start_fieldtrip;
% set the workpath
workpath = 'E:\IEEG_DSI_connectome\IEEGprep';
cd(workpath);
sub_list = 1:82;
for s_num = 82 : 1 : length(sub_list)
        subj_ID = ['sub-', num2str(sub_list(s_num), '%04d')];
        disp(subj_ID);
        state_ID = 'awake';
        subj_ieeg_folder = fullfile(workpath,  'IEEG',  subj_ID, 'ieeg', state_ID);
        task_ID = 'task-rest';
        rawdata_dir = dir(fullfile(subj_ieeg_folder, '*')); % read the file name of IEEG raw data file
        for ddn = 1:length(rawdata_dir)
                if rawdata_dir(ddn).bytes > 10*1024*1024 && rawdata_dir(ddn).isdir == 0
                        data_path = fullfile(rawdata_dir(ddn).folder, rawdata_dir(ddn).name);
                        cell_str = strsplit(rawdata_dir(ddn).name, '_'); % read the session number and run number
                        for csn = 1:length(cell_str)
                            if contains(cell_str{csn}, 'ses') == 1
                                ses_ID = cell_str{csn};
                            end
                            if contains(cell_str{csn}, 'run') == 1
                                run_ID = cell_str{csn};
                            end
                        end
                        cfg = [];% read the signals file
                        cfg.dataset = data_path;
                        data_raw = [];
                        data_raw = ft_preprocessing(cfg); 
                        % bandpass and linenoise filtering
                        cfg = [];
                        cfg.detrend = 'yes';
                        cfg.demean = 'yes';
                        cfg.baselinewindow = 'all';
                        cfg.bpfilter = 'yes';% highpass filter 
                        cfg.bpfreq = [0.5, 300]; % highpass frequency in Hz
                        cfg.bpfiltord = 3; %bandpass filter order (default set in low-level function)
                        dataR_filtering1 = ft_preprocessing(cfg, data_raw);
                        cfg = [];
                        cfg.detrend = 'yes';
                        cfg.demean = 'yes';
                        cfg.baselinewindow = 'all';
                        cfg.bsfilter = 'yes';
                        cfg.bsfiltord = 3;
                        cfg.bsfreq = [49 51; 99 101; 149 151; 199 201; 249 251; 299 300]; % line frequency
                        dataR_filtering2 = ft_preprocessing(cfg, dataR_filtering1);
                        % downsample
                        cfg = [];
                        cfg.resamplefs = 1000; %frequency at which the data will be resampled (default = 256 Hz)
                        cfg.detrend  = 'yes'; % detrend the data prior to resampling (no default specified, see below)
                        cfg.demean  = 'yes'; % whether to apply baseline correction (default = 'no')
                        cfg.baselinewindow  = 'all'; % in seconds, the default is the complete trial (default = 'all')
                        cfg.sampleindex  = 'yes'; % add a channel with the original sample indices (default = 'no')
                        [dataRF_downsample] = ft_resampledata(cfg, dataR_filtering2);
                        % save file
                        savefilepath = fullfile(workpath, 'IEEGprep', 'ieegdata', subj_ID, 'awake',  'filtering');
                        mkdir(savefilepath);
                        savefilename = [subj_ID, '_', state_ID, '_', ses_ID, '_', task_ID, '_', run_ID, '_eeg.mat'];
                        save(fullfile(savefilepath, savefilename), 'dataRF_downsample', '-v7.3');
                end
        end
end

                    
                    
