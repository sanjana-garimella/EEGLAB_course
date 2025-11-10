% Wakeman & Henson Data analysis: Connectivity analysis.
%
% Authors: Arnaud Delorme, Ramon Martinez-Cancino, Johanna Wagner, Romain Grandchamp

clear;                                      

% Path to data below. Using relative paths so no need to update.
eeglab_path = fileparts(which('eeglab'));
path2data = fullfile(pwd,'ds000117_pruned', 'derivatives', 'meg_derivatives', 'sub-01', 'ses-meg/', 'meg/'); % Path to data 
filename = 'wh_S01_run_01_preprocessing_data_session_1_out.set';

% Start EEGLAB
[ALLEEG, EEG, CURRENTSET] = eeglab; 

% Loading data
EEG = pop_loadset('filename', filename,'filepath',path2data);

% Compute connectivity
EEG = pop_dipfit_settings( EEG, 'model', 'standardBEM', 'coord_transform', 'warpfiducials');
%EEG = pop_leadfield(EEG, 'sourcemodel', fullfile(eeglab_path, 'plugins','dipfit','LORETA-Talairach-BAs.mat'),'sourcemodel2mni',[],'downsample',1);
EEG = pop_leadfield(EEG, 'sourcemodel','/Users/arno/GitHub/core_eeg/eeglab/functions/supportfiles/head_modelColin27_5003_Standard-10-5-Cap339.mat', ...
    'sourcemodel2mni',[0 -24 -45 0 0 -1.5708 1000 1000 1000] ,'downsample',1);
EEG = pop_roi_activity(EEG, 'leadfield',EEG.dipfit.sourcemodel,'model','LCMV','modelparams',{0.05},'atlas','LORETA-Talairach-BAs','nPCA',3);
EEG = pop_roi_connect(EEG, 'morder',20,'naccu',[],'methods',{'CS', 'MIM'});
pop_roi_connectplot(EEG, 'measure','MIM','freqrange',[],'plotcortex','on','plotcortexparams',{},'plotcortexseedregion',0,'plotmatrix','on', ...
     'plotpsd','off','plot3d','off','plot3dparams',{'thresholdper',0.2},'region','all','hemisphere','all');
