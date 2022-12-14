clear, clc, close all
%% Add Paths
rfol = 'C:/Users/guta_/Desktop/Data Analysis/';             % Root folder
cfol = fileparts(matlab.desktop.editor.getActiveFilename);  % Current file folder
restoredefaultpath; clear RESTOREDEFAULTPATH_EXECUTED;      % Remove any added paths
cd(cfol);   
addpath(genpath(strcat(rfol,'Libraries/Functions/')))       % Add libraries
addpath(strcat(rfol,'Libraries/'))
clear rfol cfol
addpath('C:/Users/guta_/Desktop/Data Analysis/Libraries/eeglab2021.0'); 
varsbefore = who; eeglab; close; varsnew = []; varsnew = setdiff(who, varsbefore); clear(varsnew{:})

%% Set dataset
mset = 'C:/Users/guta_/Desktop/Data Analysis/Data/Migraine/';

%% Evaluate GA+PA: Power drop of EO/EC
sub = [9,13,19,29,25,26,27,29,30,31,33,38];
out = oo.io.load('set',mset,'fol','Formatted/','sub',sub,'ses',1,'run',1,'load',0);
paA = oo.io.load('set',mset,'fol','Corrected/','sub',sub,'ses',1,'run',2,'cor','paAAS');
paR = oo.io.load('set',mset,'fol','Corrected/','sub',sub,'ses',1,'run',2,'cor','paReV2');
paL = oo.io.load('set',mset,'fol','Corrected/','sub',sub,'ses',1,'run',2,'cor','paLas');

%% Upload stored events to EEG structs
paL = update_event_duration_and_label(paL,oo.io.load('set',mset,'fol','Processed/Event info/','sub',sub,'ses',1,'run',2,'pro','event'));
paR = update_event_duration_and_label(paR,oo.io.load('set',mset,'fol','Processed/Event info/','sub',sub,'ses',1,'run',2,'pro','event'));
paL = update_chanlocs(paL,struct('path',strcat(nset,'chanlocsMR32.mat')));

%% Calculate curves
paLs = eyes_spectrum(paL,struct);
paRs = eyes_spectrum(paR,struct);
paAs = eyes_spectrum(paA,struct);
pi = pile(paLs(1),paRs(1),paAs(1),outs(1));

%% Plot curves
eyesplt(pi(1:end-1),struct('x',"cor",'y',"sub",'tit','cor'))

%% Plot boxplot
% pi = pile(paLs,paAs,outs,paRs);
pi = pile(paLs,paRs,paAs);
bp = ord(pi,struct('target',"cor",'order',{{["paLas", "paReV2","paAAS"]}}));
boxplt(bp, struct('var',"alpha_ratio",'x',"cor",'y',"ses",'ybox',"sub",'ylim',[-100,0],'ylab',"Power % change"));

%% Plot topoplot
pi = pile(paLs,paAs,outs,paRs);
tp = squee(pi,struct('unique',"cor",'dim',1));
tp = fun(tp,struct('fun','mean','dim',1,'var',["alpha_ratio"]));
tp = ord(tp,struct('ord',["fol","cor"],'dir',["descend","descend"]));
topoplt(tp, struct('var',"alpha_ratio",'x',"cor",'y',"ses",'clims',[-100,100]));

