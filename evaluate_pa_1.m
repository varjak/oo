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
nset = 'C:/Users/guta_/Desktop/Data Analysis/Data/NeurAugVR/';

%% Format
oo.form.format('set',nset,'lfol','Unformatted\ReV\','lfil',["eyesbefore"],'sfol','Corrected\'); 
% oo.form.format('set',nset,'lfol','Unformatted\ReV\','lfil',["sub-14_ses-inside2_task-eyesbefore_run-01_cor-paReV"],'sfol','Corrected\'); 

%% Correct offline
%% Detect QRS
unc = oo.io.load('set',nset,'fol','Acquired/','sub',[14],'task','eyes');
ds = oo.proc.downsample(unc,'ds',250);
for i = 1:numel(ds)
    qr = oo.cor.detect_qrs(ds(i),'starters',60);  % 'starters',60 | 'starters',"deep"
    oo.io.save(qr,'set',nset,'fol','Corrected/');
end
%% Correct PA
qr = oo.io.load('set',nset,'fol','Corrected/','sub',[14,16,17],'task','eyes','cor','qrs');
pa = oo.cor.correct_pa(qr);
oo.io.save(pa,'set',nset,'fol','Corrected/');

%% Analyze PA: Power drop of PA-corrected vs. PA-uncorrected (GA-clean)
%% Load
paU = oo.io.load('set',nset,'fol','Corrected/','sub',{[1,2,3,4,5,14,17],16},'ses',{2,1},'task','eyes','cor','qrs','load',0);
paR = oo.io.load('set',nset,'fol','Corrected/','sub',{[1,2,3,4,5,14,17],16},'ses',{2,1},'task','eyes','cor','paReV','load',0);
paA = oo.io.load('set',nset,'fol','Corrected/','sub',{[1,2,3,4,5,14,17],16},'ses',{2,1},'task','eyes','cor','paAAS','load',0);
paL = oo.io.load('set',nset,'fol','Corrected/','sub',{[1,2,3,4,5,14,17],16},'ses',{2,1},'task','eyes','cor','hpPa30Las','load',1);
paL = oo.proc.update_chanlocs(paL,struct('path',strcat(nset,'chanlocsMR32.mat')));  % online_cor should already store the correct chanlocs. but while it doesn't...

%% Calculate ratio
paLr = oo.proc.power_ratio(paU,paL,struct('include',"pa",'pa_event',"QRSi",'lims_type_a',"markers",'lims_a',["Open eyes","Closed eyes"],'lims_type_b',"markers",'lims_b',["Open eyes","Closed eyes"]));
paAr = oo.proc.power_ratio(paU,paA,struct('include',"pa",'pa_event',"QRSi",'lims_type_a',"markers",'lims_a',["Open eyes","Closed eyes"],'lims_type_b',"markers",'lims_b',["Open eyes","Closed eyes"]));
% paRr = oo.proc.power_ratio(paU,paR,struct('include',"pa",'pa_event',"QRSi",'resamp',250,'lims_type_a',"markers",'lims_a',["Open eyes","Closed eyes"],'lims_type_b',"idx",'lims_b',[1,+Inf]));
paRr = oo.proc.power_ratio(paU,paR,struct('include',"pa",'pa_event',"QRSi",'resamp',250,'lims_type_a',"markers",'lims_a',["Open eyes","Closed eyes"],'lims_type_b',"markers",'lims_b',["Open eyes","Closed eyes"]));
pi = oo.help.pile(paLr,paAr,paRr);  % ([1,3,4,5])

%% Plot topographies
tp = oo.help.squeeze(pi,'unique',"cor",'dim',2);
tp = oo.help.apply_fun(tp,'fun',@mean_power_subjects);
tp = oo.help.spread(tp,'old_field',["power_ratio_art_all","power_ratio_bkg_all"], 'new_field1',"power_ratio",'new_field2',"band",'new_field2_val',["art","bkg"]);
tp = oo.help.order(tp,'target',["band","cor"],'order',{{["art","bkg"],["hpPa30Las","paReV","paAAS"]}});  % paLas
oo.plot.topoplot(tp, 'var',"power_ratio",'x',"cor",'y',"band",'tit',"cor",'clim',[-100,-50]);

%% Plot boxplots
bp = oo.help.apply_fun(pi,'fun',@mean_power_channels);
bp = oo.help.spread(bp,'old_field',["power_ratio_art_all","power_ratio_bkg_all"], 'new_field1',"power_ratio",'new_field2',"band",'new_field2_val',["art","bkg"]);
bp = oo.help.order(bp,'target',["band","cor"],'order',{{["art","bkg"],["hpPa30Las","paReV","paAAS"]}});  % paLas
oo.plot.boxplot(bp, 'var',"power_ratio",'x',"cor",'y',"band",'ybox',"sub",'clims',[-15,0],'ylab',"Power % change");

%% Auxiliary functions
function A = mean_power_subjects(A)
fields = ["power_ratio_art_all","power_ratio_bkg_all"];
dim = 2;
for i = 1:numel(A)
    for j = 1:numel(fields)
        a = A(i).(fields(j));
        b = mean(a,dim,'omitnan');
        A(i).(fields(j)) = b;
    end
end
end
function A = mean_power_channels(A)
fields = ["power_ratio_art_all","power_ratio_bkg_all"];
dim = 1;
for i = 1:numel(A)
    for j = 1:numel(fields)
        a = A(i).(fields(j));
        b = mean(a,dim,'omitnan');
        A(i).(fields(j)) = b;
    end
end
end