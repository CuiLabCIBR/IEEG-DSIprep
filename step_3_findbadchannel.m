%% read the data and visualize
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
           cfg = [];  
           cfg.ylim = [-30, 30];
           cfg.viewmode = 'vertical';
           cfg.preproc.demean  = 'yes';
           cfg.preproc.detrend  = 'yes';
           cfg.blocksize = 10;%duration in seconds for cutting continuous data in segments
           cfg = ft_databrowser(cfg, dataRF_downsample); % view the signals
           % exclude bad channels
           badchannels_label.channel = {'all', '-oh14', '-oh15', '-f4', ...
               '-C30', '-C31',  '-C32',  '-C33',  '-C34',  '-C35',  '-C36', '-C37', '-C38', '-C39', ... 
               '-C40', '-C41',  '-C42',  '-C43',  '-C44',  '-C45',  '-C46', '-C47', '-C48', '-C49', ... 
               '-C50', '-C51',  '-C52',  '-C53',  '-C54',  '-C55',  '-C56', '-C57', '-C58', '-C59', ... 
               '-C60', '-C61',  '-C62',  '-C63',  '-C64',  '-C65',  '-C66', '-C67', '-C68', '-C69', ... 
               '-C70', '-C71',  '-C72',  '-C73',  '-C74',  '-C75',  '-C76', '-C77', '-C78', '-C79', ... 
               '-C80', '-C81',  '-C82',  '-C83',  '-C84',  '-C85',  '-C86', '-C87', '-C88', '-C89', ... 
               '-C90', '-C91',  '-C92',  '-C93',  '-C94',  '-C95',  '-C96', '-C97', '-C98', '-C99', ... 
               '-C10*', '-C11*', '-C12*', '-C13*', '-C14*', '-C15*', '-C16*', '-C17*', '-C18*', '-C19*', ...
               '-C20*', '-C21*', '-C22*', '-C23*', '-C24*', '-C25*', '-C26*', '-C27*', '-C28*', '-C29*', ...
               '-DC*', '-Ch*', '-null*', '-ecg*', '-EKG*', '-ECG*', ...
               '-Trigger Event', '-Event', '-HEART*', ...
               '-TRIG', '-OSAT', '-PR', '-Pleth', ...
               '-EOG*', '-sampleindex'};
           cfg = [];
           cfg.channel = badchannels_label.channel;
           dataRFD_debadchanel = ft_preprocessing(cfg, dataRF_downsample); 
           % save bad channel info
           badchannel_filefolder = fullfile(workpath, 'IEEGprep', 'ieegdata_awake', subj_ID, 'awake');
           mkdir(badchannel_filefolder);
           save(fullfile(badchannel_filefolder,[subj_ID,'_badchannel.mat']), "badchannels_label");
           cfg = [];  
           cfg.ylim = [-30, 30];
           cfg.viewmode = 'vertical';
           cfg.preproc.demean  = 'yes';
           cfg.preproc.detrend  = 'yes';
           cfg.blocksize = 10;%duration in seconds for cutting continuous data in segments
           cfg = ft_databrowser(cfg, dataRFDDD_bipref); % view the clean signals
     end



