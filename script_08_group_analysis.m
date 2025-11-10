% Wakeman & Henson Data analysis: Group analysis.
%
% Authors: Arnaud Delorme, Ramon Martinez-Cancino, Johanna Wagner, Romain Grandchamp

%%
% Clearing all is recommended to avoid variable not being erased between calls 
clear;

studyfullname       = fullfile(pwd, 'ds002718/derivatives', 'Face_detection.study');
[root,std_name,ext] = fileparts(studyfullname); cd(root);       
EEG                 = eeglab;
[STUDY, ALLEEG]     = pop_loadstudy('filename', [std_name ext], 'filepath', root);
STUDY               = std_checkset(STUDY, ALLEEG);
[STUDY, ALLEEG]     = std_precomp(STUDY, ALLEEG, {}, 'savetrials','on','interp','on','recompute','on',...
    'erp','on','erpparams', {'rmbase' [-200 0]}, 'spec','off', 'ersp','off','itc','off');
eeglab redraw

%%                                     
% Generate design 1
% Here the statistical design is implemented. In this case, the three type
% of presentations for each typ of stimulus were concantenated, so we can
% deal with the marginalized version of the stimulus: Familiar(famous),
% unfamiliar and scrambled faces. 
STUDY       = std_makedesign(STUDY, ALLEEG, 1, 'name','STUDY.design 1',...
                                               'delfiles','off',...
                                               'defaultdesign','off',...
                                               'variable1','type',...
                                               'values1',{{'famous_new' 'famous_second_early' 'famous_second_late'}...
                                                          {'scrambled_new' 'scrambled_second_early' 'scrambled_second_late'}...
                                                          {'unfamiliar_new' 'unfamiliar_second_early' 'unfamiliar_second_late'}},...
                                               'vartype1','categorical');
                                            
[STUDY EEG] = pop_savestudy( STUDY, ALLEEG, 'savemode','resave'); % Saving the STUDY

%% Plot grand average at 170 ms
[STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG, {},'savetrials','on','interp','on','recompute','on','erp','on');
STUDY = pop_erpparams(STUDY, 'plotconditions','together');
chanList = eeg_mergelocs(ALLEEG.chanlocs);
STUDY = std_erpplot(STUDY,ALLEEG,'channels', {chanList.labels}, 'design', 1);
STUDY = pop_erpparams(STUDY, 'topotime',170 );
STUDY = std_erpplot(STUDY,ALLEEG,'channels',{chanList.labels}, 'design', 1);

%% Generating measures for clusters
[STUDY, ALLEEG]  = std_precomp(STUDY, ALLEEG, 'components','savetrials','on','recompute','on','erp','on','scalp','on','erpparams',{'rmbase' [-100 0]});
[STUDY, ALLEEG]  = std_preclust(STUDY, ALLEEG, 1,{'erp' 'npca' 10 'weight' 1 'timewindow' [100 800]  'erpfilter' '25'},...
    {'scalp' 'npca' 10 'weight' 1 'abso' 1},...
    {'dipoles' 'weight' 10});

%% Clustering
nclusters = 15;
[STUDY]         = pop_clust(STUDY, ALLEEG, 'algorithm','kmeans','clus_num',  nclusters , 'outliers',  2.8 );
[STUDY, ALLEEG]     = pop_savestudy( STUDY, ALLEEG, 'savemode','resave');

%% Figures STUDY
% All clusters ERPs
STUDY = pop_erpparams(STUDY, 'filter',15,'timerange',[-100 400] );
STUDY = std_erpplot(STUDY,ALLEEG,'clusters',[2:nclusters+2], 'design', 1);

% All clusters topos
STUDY = std_topoplot(STUDY,ALLEEG,'clusters',[2:nclusters+2], 'design', 1);

% All clusters dipoles
STUDY = std_dipplot(STUDY,ALLEEG,'clusters',[2:nclusters+2], 'design', 1);

%% One cluster figure
ClusterOfInterest = 14;
STUDY = pop_erpparams(STUDY, 'plotconditions','together');
STUDY = std_erpplot(STUDY,ALLEEG,'clusters',ClusterOfInterest, 'design', 1);
STUDY = std_dipplot(STUDY,ALLEEG,'clusters',ClusterOfInterest, 'design', 1);
STUDY = std_topoplot(STUDY,ALLEEG,'clusters',ClusterOfInterest, 'design', 1, 'plotsubjects', 'on' );
