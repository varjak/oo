function A = preprocess(A,varargin)
% Inputs:
% 'hp',1
% 'lp',40
% 'resamp',250,
% 'event',["S  7","S  8"]
% 'elims',[-5.5,5.5]
% 'no_interp_chans'
% 'no_discard_chans'

B = oo.help.parse_input(varargin,'resamp',250,'hp',1,'lp',40,'event',["S  7","S  8"],'elims',[-5.5,5.5],'ereject',1,'no_interp_chans',["C3","C4"],'no_discard_chans',["C3","C4"]);

for i = 1:numel(A)
    fprintf('Preprocessing entry %d / %d\n', i, numel(A))
    EEG = A(i).EEG;
    switch B.pr
        case 1
            EEG = prep1(EEG,B.resamp,B.hp,B.lp);
        case 2
            EEG = prep2(EEG,B.resamp,B.hp,B.lp);
        case 3
            EEG = prep3(EEG,B.resamp,B.hp,B.lp,B.no_interp_chans);
        case 4
            EEG = prep4(EEG,B.resamp,B.hp,B.lp,B.no_interp_chans,B.no_discard_chans);
        case 5
            EEG = prep5(EEG,B.resamp,B.hp,B.lp,B.event,B.elims,B.ereject,B.no_interp_chans,B.no_discard_chans);
        case 6
            EEG = prep6(EEG,B.resamp,B.hp,B.lp,B.event,B.elims,B.ereject,B.no_interp_chans,B.no_discard_chans);
        case 7
            EEG = prep7(EEG,B.resamp,B.hp,B.lp,B.event,B.elims,B.ereject,B.no_interp_chans,B.no_discard_chans);
        case 8
            EEG = prep8(EEG,B.resamp,B.hp,B.lp,B.no_interp_chans,B.no_discard_chans);
        otherwise
            disp('No preprocessing selected!')
            break
    end
    A(i).EEG = EEG;
    A(i).pre = B.pr;
end
end