function A = trim_to_acquisition(A,varargin)

B = oo.help.parse_input(varargin);

disp('--->>>---> 3 - Cutting the signal to match fMRI acquisition...');
TR = 1.26;
etype = B.vol_marker;

for i = 1:numel(A)
    EEG = load_if_path(A(i).EEG);

    event_types = {EEG.event(:).type};
    vol_index = find(strcmp(etype, event_types));
    first_vol = EEG.event(vol_index(1)).latency;
    last_vol = EEG.event(vol_index(end)).latency;

    EEGCUT = pop_select(EEG, 'point', [first_vol last_vol+TR*EEG.srate-1]);
    
    for ev = 1:length(EEGCUT.event)
        EEGCUT.event(ev).latency = round(EEGCUT.event(ev).latency);
    end

    A(i).EEG = EEGCUT;
end
end