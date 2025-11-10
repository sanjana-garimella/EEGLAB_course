% Wakeman & Henson Data analysis: Preprocess data.
%
% Authors: Arnaud Delorme, Ramon Martinez-Cancino, Johanna Wagner, Romain Grandchamp

% Clearing all is recommended to avoid variable not being erased between calls 
clear;                                      

% Path to data below. Using relative paths so no need to update.
path2data = fullfile(pwd,'ds000117_pruned', 'derivatives', 'meg_derivatives', 'sub-01', 'ses-meg/', 'meg/'); % Path to data 
filename = 'wh_S01_run_01.set';

% Start EEGLAB
[ALLEEG, EEG, CURRENTSET] = eeglab; 

%% Loading data 
% use menu item File > Load existing dataset
% and select file ds000117_pruned/derivatives/meg_derivatives/sub-01/ses-meg/meg/wh_S01_run_01.set
EEG = pop_loadset('filename', filename,'filepath',path2data);

%% Re-Reference
% use menu item Tools > Re-reference the data
% Apply Common Average Reference
EEG = pop_reref(EEG,[]); % menu item Tools > Rereference (eegh)

%% Resampling
% use menu item Tools > Change sampling rate
% Downsampling to 100 Hz for speed (for real analysis prefer 250 or 500 Hz)
EEG = pop_resample(EEG, 100);

%% Filter
% use menu item Tools > Filter the data > Basic FIR filter
% Filter the data Highpass at 1 Hz Lowpass at 40Hz (to avoid line noise at 100Hz)
EEG = pop_eegfiltnew(EEG, 1, 0);   % High pass at 1Hz
EEG = pop_eegfiltnew(EEG, 0, 40);  % Low pass below 40

%% Automatic rejection of bad channels
% use menu item Tools > Reject data using Clean_rawdata and ASR
% Apply clean_artifacts() to reject bad channels
if contains(EEG.chanlocs(1).type, 'meg')
    minChanCorr = 0.4;
else
    minChanCorr = 0.9;
end
EEG = clean_artifacts(EEG, 'Highpass', 'off',...
                           'ChannelCriterion', minChanCorr,...
                           'ChannelCriterionMaxBadTime', 0.4,... % not in GUI
                           'LineNoiseCriterion', 4,... % line noise
                           'BurstCriterion', 'off',...
                           'WindowCriterion','off' );

%% Re-Reference
EEG = pop_reref(EEG,[]);

% %% Repair bursts and reject bad portions of data
EEG = clean_artifacts( EEG, 'Highpass', 'off',...
                            'ChannelCriterion', 'off',...
                            'LineNoiseCriterion', 'off',...
                            'BurstCriterion', 30,...
                            'WindowCriterion',0.3); % not in gui

%% run ICA
% use menu item Tools > Decompose by ICA
% Use first line for speed (but you must install the Picard plugin)
% The -1 for the number of channel is to account for matrix rank 
% decrease due to average reference
if exist('picard') % faster
    EEG = pop_runica( EEG , 'picard', 'maxiter', 500, 'pca', -1);% Do not forget to add 'pca',-1 in command line options to account for average reference
else
    EEG = pop_runica( EEG , 'runica', 'extended',1, 'pca', -1);
end

%% automatically classify Independent Components using IC Label
% use menu item Tools > Classify components using ICLabel > Label components
% EEG only, MEG would be possible if ICLabel is retrained with MEG
% components instead of EEG components. Here we remove the component, but
% when doing group analysis, it is better to do that at the STUDY level
if ~contains(EEG.chanlocs(1).type, 'meg')
    EEG  = iclabel(EEG);
    EEG = pop_icflag( EEG,[NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
    EEG = pop_subcomp(EEG, [], 0); % remove pre-flagged bad components
end

%% Save dataset
% use menu item File > Save current dataset as
EEG = pop_saveset( EEG,'filename', 'wh_S01_run_01_preprocessing_data_session_1_out.set','filepath',path2data);
