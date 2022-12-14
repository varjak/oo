function A = downsample(A,varargin)

B = oo.help.parse_input(varargin);

for i = 1:numel(A)
    
    EEG = load_if_path(A(i).EEG);
    
    % Downsample
    EEGDWS = pop_resample(EEG, B.ds);
    for m = 1:size(EEGDWS.event,2)
        EEGDWS.event(m).latency = round(EEGDWS.event(m).latency);
    end
    A(i).EEG = EEGDWS;
    A(i).cor = 'dsMAT';
end