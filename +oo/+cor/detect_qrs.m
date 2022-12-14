function A = detect_qrs(A,varargin)

B = oo.help.parse_input(varargin);

for i = 1:numel(A)
    EEGunmarked = A(i).EEG;
    ecg_chn = find(ismember(upper({EEGunmarked.chanlocs(:).labels}),{'ECG','EKG'}));
    
    % CUIDADO: (comentei para usar em data que já tinha sido filtered online!)
    % Filter ECG
    EEGECG = pop_select(EEGunmarked, 'channel', ecg_chn);
    EEGECG = pop_eegfiltnew(EEGECG, 'locutoff',0.5, 'plotfreqz',0);
    EEGECG = pop_eegfiltnew(EEGECG, 'hicutoff',30, 'plotfreqz',0);
    EEGunmarked.data(ecg_chn, :) = EEGECG.data(1, :);
    
    % Load starter markers from second EEGunmarked
    if isstruct(B.starters)
        EEGQRS = B.starters(i).EEGunmarked;
        starter = [EEGQRS.event(strcmp('QRSi', {EEGQRS.event(:).type})).latency];
    % Set starter as heart-rate
    elseif isscalar(B.starters) && isnumeric(B.starters)
        starter = B.starters;
    elseif isstring(B.starters)
        % Calculate starters automatically
        if strcmp(B.starters,'auto')
            freq_band = [4 45]; % [4 45 Hz] to increase QRS detection accuracy (Abreu et al., 201
            reverse = 1;
            [~, ~, lats, ~] = ecgPeakDetection_v4(EEGunmarked.data(ecg_chn, :), EEGunmarked.srate, freq_band, reverse);
            starter = lats;
        elseif strcmp(B.starters,'deep')
            W = load('C:/Users/guta_/Desktop/Data Analysis/Libraries/Functions/Detect/deepQRS/model/weights.mat');
            lats = double(deepQRS(EEGunmarked.data(ecg_chn, :),W));
            starter = lats;
        % Find starters in EEGunmarked by event name
        else
            starter = [EEGunmarked.event(strcmp(B.starters, {EEGunmarked.event(:).type})).latency];
        end
    end
    
    % Detect
    mark = true;
    while mark
        EEG = interactiveQRS(EEGunmarked,starter);
        mark = ~input('Save interactively QRS-detected EEG? (1/0) ');
        starter = 'QRSi';
    end
    
    % Save
    A(i).cor = 'qrs';
    A(i).EEG = EEG;
end
end