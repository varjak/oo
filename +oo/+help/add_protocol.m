function d = add_protocol(d,s)

for i = 1:numel(d)
    fprintf('Protocol addition entry %d / %d\n', i, numel(d))
    EEG = d(i).EEG;
    fs = EEG.srate;
    nevents = numel(EEG.event);
    
    protocol = create_protocol(fs);
    
    % Choose start
    start_thres = 0.5;  % s
    scan_start_id = find(ismember({EEG.event.type},'Scan Start'),1);
    r128_id = find(ismember({EEG.event.type},'R128'),1);
    % CUIDADO: (for corrected files:)
%     if EEG.event(r128_id).latency < start_thres*fs
%         start_lat = EEG.event(r128_id).latency;
%     else
%         start_lat = EEG.event(scan_start_id).latency;
%     end
    % (for formatted files:)
    start_lat = EEG.event(r128_id).latency;
    
    % Add events
    for k = 1:numel(protocol)
        EEG.event(nevents+k).type = protocol(k).type;
        EEG.event(nevents+k).latency = protocol(k).latency + start_lat;
    end
    
    % Sort events
    [~,I] = sort([EEG.event.latency]);
    EEG.event=EEG.event(I);
    for k = 1:numel(EEG.event)
        EEG.event(k).urevent = k;
    end
    
    d(i).EEG = EEG;
    d(i).pro = 'addedprotocol';
end
end
