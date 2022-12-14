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

%% Fix missing protocol
% unc = oo.io.load('set',nset,'fol','Acquired/old/','sub',10,'ses',1,'run',8,'mri','vary','task','neurowMIMO','load',1);
% ap = oo.help.add_protocol(unc);
% oo.io.save(ap,'set',nset,'fol','Acquired/');

%% Format Recview-corrected
oo.form.format('set',nset,'lfol','Unformatted\ReV\','lfil',[""],'sfol','Corrected\');

%% Correct GA (AAS)
sub = 10;  % 10 | [1,2,3,4,5,6,7,8,9,11,12,13,14,16]
ses = 1;
unc = oo.io.load('set',nset,'fol','Acquired/','sub',sub,'ses',ses,'run',8,'mri','vary','task','neurowMIMO','load',0);
for i = 1:numel(unc)
    gaA = oo.cor.correct_ga(unc(i),'TR',1.26,'marker','R128','expected_vols',268);  % 'marker','R128' | 'marker','Scan Start','thr',[0.02,0.018],'grad_thr',[100,200]; 268 | 473
    oo.io.save(gaA,'set',nset,'fol','Corrected/AAS/');
end

%% Trim to acquisition and downsample
gaA = oo.io.load('set',nset,'fol','Corrected/AAS/','sub',sub,'ses',ses,'mri','vary','task','neurowMIMO','load',0);
for i = 1:numel(gaA)
    tr = oo.cor.trim_to_acquisition(gaA(i),'vol_marker','R128');
    ds = oo.proc.downsample(tr,'ds',250);
    oo.io.save(ds,'set',nset,'fol','Corrected/AAS/');
end

%% Format offline-corrected (till qrs) files to transfer QRSi from
% oo.form.format('set',nset,'lfol','Unformatted\offQRS\','lfil',[""],'sfol','Corrected\offQRS\');

%% Detect QRS
ds = oo.io.load('set',nset,'fol','Corrected/AAS/','sub',sub,'ses',ses,'mri','vary','task','neurowMIMO','cor','dsMAT','load',0);
qrs0 = oo.io.load('set',nset,'fol','Corrected/AAS/','sub',sub,'ses',ses,'mri','vary','task','neurowMIMO','cor','obsQRS','load',0);
qrs = oo.help.add_events(ds, qrs0, struct('event',"QRSi",'new_event','QRSoff'));
for i = 1:numel(qrs)
    qr = oo.cor.detect_qrs(qrs(i),'starters',"QRSoff");
    oo.io.save(qr,'set',nset,'fol','Corrected/AAS/');
end

%% Correct offline
qr = oo.io.load('set',nset,'fol','Corrected/AAS/','sub',sub,'ses',ses,'mri','vary','task','neurowMIMO','cor','qrs','load',0);
pa = oo.cor.correct_pa(qr);
oo.io.save(pa,'set',nset,'fol','Corrected/');

%% Fix Las FS: It was saved incorrectly as 5000
paL = oo.io.load('set',nset,'fol','Corrected/','sub',sub,'ses',ses,'mri','vary','task','neurowMIMO','cor','paLas','load',1);
for i = 1:numel(paL)
   paL(i).EEG.srate = 250; 
end

%% Evaluate
%% Load
sub = [1,2,3,4,5,6,7,8,9,11,12,14,16];
ses = 2;
paA = oo.io.load('set',nset,'fol','Corrected/','sub',sub,'ses',ses,'mri','vary','task','neurowMIMO','cor','paAAS','load',1);
paL = oo.io.load('set',nset,'fol','Corrected/','sub',sub,'ses',ses,'mri','vary','task','neurowMIMO','cor','paLas','load',1);
paR = oo.io.load('set',nset,'fol','Corrected/','sub',sub,'ses',ses,'mri','vary','task','neurowMIMO','cor','paReV','load',1);

paL = oo.help.update_chanlocs(paL,'path',strcat(nset,'chanlocsMR32.mat'));
paR = oo.help.update_chanlocs(paR,'path',strcat(nset,'chanlocsMR32.mat'));
% paR = oo.help.update_events(paR,'lfol','Acquired/','match',["sub","ses","run","mri","task"]);
paR = oo.cor.trim_to_acquisition(paR,'vol_marker','R128');

%% Concatenate
caA = oo.help.squeeze(paA,'unique',"sub",'dim',2,'EEGfields',1);
caR = oo.help.squeeze(paR,'unique',"sub",'dim',2,'EEGfields',1);
caL = oo.help.squeeze(paL,'unique',"sub",'dim',2,'EEGfields',1);

pi = oo.help.pile(caA,caR,caL);

%% Preprocess
pr = oo.prep.preprocess(pi, 'pr',3,'resamp',250,'hp',1,'lp',40);

%% Plot boxplots
ep = oo.proc.epoch(pr,'event',["S  7"],'elims',[-5.5,5.5]);
se = oo.proc.select(ep,'chan',["C4"]);
er = oo.proc.ersp(se,'tfout','pow','avgs',["mean","mean","mean","mean"],'flims',[8,12],'blims',[-4,0],'tlims',[0.5,4]);
er = oo.help.order(er,'target',["cor"],'order',{{["paLas","paReV","paAAS"]}});  % paLas
oo.plot.boxplot(er, struct('x',"cor",'y',"ses",'ybox',"sub",'var',"erd_val",'clims',[-100,100]))

%% Plot TF plots
ep = oo.proc.epoch(pr,'event',["S  7","S  8"],'elims',[-5.5,5.5]);
se = oo.proc.select(ep,'chan',["C3","C4"]);
er = oo.proc.ersp(se,'tfout','pow','avgs',["mean","mean","mean","mean"],'flims',[8,12],'blims',[-4,0],'tlims',[0.5,4]);
oo.plot.imgplot(er(ismember([er.cor],"paAAS")), 'x',["pre","event","chan"],'y','sub','ylim',[0,30],'clims',[-100,100],'tit','cor');
oo.plot.imgplot(er(ismember([er.cor],"paReV")), 'x',["pre","event","chan"],'y','sub','ylim',[0,30],'clims',[-100,100],'tit','cor');
oo.plot.imgplot(er(ismember([er.cor],"paLas")), 'x',["pre","event","chan"],'y','sub','ylim',[0,30],'clims',[-100,100],'tit','cor');

%% Plot TF example plot
erplot = er([er.sub]==12 & ismember([er.event],"S  7") & ismember([er.chan],"C4"));
erplot = oo.help.order(erplot,'target',["cor"],'order',{{["paLas","paReV","paAAS"]}});  % paLas
oo.plot.imgplot(erplot, 'x',["cor"],'y','sub','ylim',[0,30],'clims',[-100,100],'tit','cor');

%% Auxiliar functions
function A = add_pro(A)
for i = 1:numel(A)
    A(i).pro = "cat";
end
end