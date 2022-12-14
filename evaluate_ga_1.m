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
oo.form.format('set',nset,'lfol','Unformatted\ReV\','lfil',["rest"],'sfol','Corrected\'); 

%% Analyze GA: Power drop of GA-corrected vs. GA-PA-uncorrected
%% Load
unc = oo.io.load('set',nset,'fol','Acquired/','sub',{[1,2,3,4,5,14,17],16},'ses',{2,1},'task','rest','load',0);
gaR = oo.io.load('set',nset,'fol','Corrected/','sub',{[1,2,3,4,5,14,17],16},'ses',{2,1},'task','rest','cor','gaReV','load',0);
gaA = oo.io.load('set',nset,'fol','Corrected/','sub',{[1,2,3,4,5,14,17],16},'ses',{2,1},'task','rest','cor','gaAAS','load',0);
gaL = oo.io.load('set',nset,'fol','Corrected/','sub',{[1,2,3,4,5,14,17],16},'ses',{2,1},'task','rest','cor','ga30Las','load',1);
gaL = oo.proc.update_chanlocs(gaL,struct('path',strcat(nset,'chanlocsMR32.mat')));  % online_cor should already store the correct chanlocs. but while it doesn't...

%% Calculate ratio
gaLr = oo.proc.power_ratio(unc,gaL,'include',"ga",'lims_type_a',"markers",'lims_a',["R128","R128"],'lims_type_b',"markers",'lims_b',["R128","R128"]);
gaAr = oo.proc.power_ratio(unc,gaA,'include',"ga",'lims_type_a',"markers",'lims_a',["R128","R128"],'lims_type_b',"markers",'lims_b',["R128","R128"]);
gaRr = oo.proc.power_ratio(unc,gaR,'include',"ga",'resamp',250,'lims_type_a',"markers",'lims_a',["R128","R128"],'lims_type_b',"idx",'lims_b',[1,+Inf]);
gaRr = oo.proc.power_ratio(unc,gaR,'include',"ga",'resamp',250,'lims_type_a',"markers",'lims_a',["R128","R128"],'lims_type_b',"markers",'lims_b',["R128","R128"]);
pi = oo.help.pile(gaLr,gaAr,gaRr);

%% Plot topographies
tp = oo.help.squeeze(pi,'unique',"cor",'dim',2);
tp = oo.help.apply_fun(tp,'fun',@mean_power_subjects);
tp = oo.help.spread(tp,'old_field',["power_ratio_art_all","power_ratio_bkg_all"], 'new_field1',"power_ratio",'new_field2',"band",'new_field2_val',["art","bkg"]);
tp = oo.help.order(tp,'target',["band","cor"],'order',{{["art","bkg"],["ga30Las","gaReV","gaAAS"]}});  % paLas
oo.plot.topoplot(tp, 'var',"power_ratio",'x',"cor",'y',"band",'tit',"cor",'clim',[-100,-50]);

%% Plot boxplots
bp = oo.help.apply_fun(pi,'fun',@mean_power_channels);
bp = oo.help.spread(bp,'old_field',["power_ratio_art_all","power_ratio_bkg_all"], 'new_field1',"power_ratio",'new_field2',"band",'new_field2_val',["art","bkg"]);
bp = oo.help.order(bp,'target',["band","cor"],'order',{{["art","bkg"],["ga30Las","gaReV","gaAAS"]}});  % paLas
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
