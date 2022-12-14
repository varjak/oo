function B = power_ratio(A,B,varargin)

C = oo.help.parse_input(varargin);

%% Trim to same length
time_offset = 20; % was 0
% time_offset = 0; % was 0
durations = zeros(numel(A),2);
% marker = 'R128';
% markers_a = ["R128","R128"];
% markers_b = ["R128","R128"];
for i = 1:numel(A)
    EEGa = load_if_path(A(i).EEG);
    EEGb = load_if_path(B(i).EEG);
    
    % Resample
    if isfield(C,'resamp')
        if EEGa.srate ~= C.resamp
            EEGa = pop_resample(EEGa, C.resamp);
            for e = 1:numel(EEGa.event)
               EEGa.event(e).latency = round(EEGa.event(e).latency);
            end
        end
        if EEGb.srate ~= C.resamp
            EEGb = pop_resample(EEGb, C.resamp);
            for e = 1:numel(EEGb.event)
                EEGb.event(e).latency = round(EEGb.event(e).latency);
            end
        end
    end

    switch C.lims_type_a
        case 'markers', durations(i,1) = get_duration_between_markers(EEGa,C.lims_a);
        case 'idx', durations(i,1) = EEGa.times(C.lims_a(2)) - EEGa.times(C.lims_a(1));
    end
    switch C.lims_type_b
        case 'markers', durations(i,2) = get_duration_between_markers(EEGb,C.lims_b);
        case 'idx'
            time_b1 = EEGb.times(C.lims_b(1));
            time_b2 = EEGb.times(min([numel(EEGb.times),C.lims_b(2)]));  % I used min so the index can be +Inf
            durations(i,2) = time_b2 - time_b1;
    end
end
clear EEGa EEGb

min_duration = min(durations(:));
for i = 1:numel(A)
    EEGa = load_if_path(A(i).EEG);
    EEGb = load_if_path(B(i).EEG);
    
    % Resample
    if isfield(C,'resamp')
        if EEGa.srate ~= C.resamp
            EEGa = pop_resample(EEGa, C.resamp);
            for e = 1:numel(EEGa.event)
                EEGa.event(e).latency = round(EEGa.event(e).latency);
            end
        end
        if EEGb.srate ~= C.resamp
            EEGb = pop_resample(EEGb, C.resamp);
            for e = 1:numel(EEGb.event)
                EEGb.event(e).latency = round(EEGb.event(e).latency);
            end
        end
    end
            
    switch C.lims_type_a
        case 'markers', lat_a1 = EEGa.event(find(strcmp({EEGa.event(:).type},C.lims_a(1)),1,'first')).latency;
        case 'idx', lat_a1 = C.lims_a(1);
    end
    switch C.lims_type_b
        case 'markers', lat_b1 = EEGb.event(find(strcmp({EEGb.event(:).type},C.lims_b(1)),1,'first')).latency;
        case 'idx', lat_b1 = C.lims_b(1);
    end
    lat_a2 = lat_a1 + floor(EEGa.srate*min_duration/1000);
    lat_b2 = lat_b1 + floor(EEGb.srate*min_duration/1000);
    A(i).EEG = Trim(EEGa,[time_offset * EEGa.srate + lat_a1,lat_a2],'idx');
    B(i).EEG = Trim(EEGb,[time_offset * EEGb.srate + lat_b1,lat_b2],'idx');
end
clear EEGa EEGb

%% Set
TR = 1.26;
ga_width = 0.02;
ga_frequency = 1/TR;
band_lims = [1, 4; 4, 8; 8 12; 12, 30; 1, 30];
n_pa_frequencies = 10;
pa_width = 0.065;
% harm_thr = 0.25;
harm_thr = 0.10;

include_ga = any(strcmp(C.include,'ga'));
include_pa = any(strcmp(C.include,'pa'));
exclude_ga = isfield(C,'exclude') && any(strcmp(C.exclude,'ga'));

for i = 1:numel(A)
    EEGa = load_if_path(A(i).EEG);
    EEGb = load_if_path(B(i).EEG);
    fs = EEGa.srate;
    nchans = size(EEGa.data,1);
    
    %% Frequency spectrum
    La = size(EEGa.data,2);
    Lb = size(EEGb.data,2);
        if La ~= Lb
            fprintf('Signal to compare have not the same length. Skipping...')
            continue
        end
    L = La;
    NFFT = 2^nextpow2(L); % Next power of 2 from length of y
    f = fs/2 * linspace(0, 1, NFFT/2 + 1);
    end_id = sum(f<=30);
    f = f(1:end_id);
    
    %% Band masks
    band_masks = zeros(size(band_lims,1), numel(f));
    for j = 1:size(band_masks,1)
        band_masks(j, f >= band_lims(j,1) & f <= band_lims(j,2)) = 1;
    end
    
    %% GA masks and frequencies
    ga_mask = zeros(1, numel(f));
    ga_f = (1:floor(f(end) / ga_frequency) - 1) .* ga_frequency;
    for j = 1:numel(ga_f)
        ga_mask(f >= ga_f(j) - ga_width & f <= ga_f(j) + ga_width) = 1;
    end
    
    exclude_mask = zeros(1,numel(f));
    if include_ga
        art_f = ones(nchans,1) * ga_f;
        art_width = ga_width;
    elseif exclude_ga
        exclude_mask = ga_mask;
    end
    
    %% Debug plot
    if i == 1
        EEGplot = EEGa;
        chnplot = 5;
        Y = fft(EEGplot.data(chnplot,:), NFFT) / L; 
        FFTData = 2 * abs(Y(1:NFFT/2 + 1)); % compute the FFT for each EEG channel
        figure('Name', 'PSD')
        plot(f, FFTData(1:numel(f)))
        hold on
        for j = 1:numel(ga_f)
            plot((ga_f(j)-ga_width)*[1,1],ylim,'k')
            hold on
            plot((ga_f(j)+ga_width)*[1,1],ylim,'k')
            hold on
        end
    end
    
    %% PA masks and frequencies
    if include_pa
        qrs_label = C.pa_event;
        R = double([EEGa.event(strcmp(qrs_label, {EEGa.event(:).type})).latency]);  % assuming latencies
        pa_frequency = fs/(mean(diff(R)));
        PeakRadiusf = 0.1;
        LorentzRf = 0.3;
        LorentzSigma = 0.01;
        ecg = EEGa.data(ismember(upper({EEGa.chanlocs(:).labels}),{'ECG','EKG'}),:);
        fs = EEGa.srate;
        [max_conv, pa_f_id] = harmonics_Lorentz(ecg, EEGa.data, pa_frequency, fs, n_pa_frequencies, PeakRadiusf, LorentzRf, LorentzSigma, pa_width, 0);
        rel_conv = (max_conv ./ max(max(max_conv))) > harm_thr;
        art_f = f(pa_f_id);
        art_width = pa_width;
        art_filter = rel_conv;
    end
    
    %% Power
    [power_vol_art_a, power_vol_bkg_a] = power_chan_art_band(EEGa, art_f, band_masks, exclude_mask, art_width, f, NFFT, L, end_id);
    [power_vol_art_b, power_vol_bkg_b] = power_chan_art_band(EEGb, art_f, band_masks, exclude_mask, art_width, f, NFFT, L, end_id);
    
    if include_pa
        for j = 1:size(band_masks,1)
            power_vol_art_a = slice_assign(power_vol_art_a,j,art_filter,nan);
            power_vol_bkg_a = slice_assign(power_vol_bkg_a,j,art_filter,nan);
            power_vol_art_b = slice_assign(power_vol_art_b,j,art_filter,nan);
            power_vol_bkg_b = slice_assign(power_vol_bkg_b,j,art_filter,nan);
        end
    end
    
    %% Ratio
    power_vec_art_a = mean(power_vol_art_a, 2, 'omitnan');
    power_vec_art_b = mean(power_vol_art_b, 2, 'omitnan');
    power_vec_bkg_a = mean(power_vol_bkg_a, 2, 'omitnan');
    power_vec_bkg_b = mean(power_vol_bkg_b, 2, 'omitnan');
    
    power_ratio_art = (power_vec_art_b - power_vec_art_a) ./ power_vec_art_a * 100;
    power_ratio_bkg = (power_vec_bkg_b - power_vec_bkg_a) ./ power_vec_bkg_a * 100;
    
%     power_ratio_art = (power_vec_art_b - power_vec_art_a);
%     power_ratio_bkg = (power_vec_bkg_b - power_vec_bkg_a);
    
    ecg_chn = 32;
    B(i).power_ratio_art_delta = power_ratio_art(1:ecg_chn-1,:,1);
    B(i).power_ratio_art_theta = power_ratio_art(1:ecg_chn-1,:,2);
    B(i).power_ratio_art_alpha = power_ratio_art(1:ecg_chn-1,:,3);
    B(i).power_ratio_art_beta = power_ratio_art(1:ecg_chn-1,:,4);
    B(i).power_ratio_art_all = power_ratio_art(1:ecg_chn-1,:,5);
    B(i).power_ratio_bkg_delta = power_ratio_bkg(1:ecg_chn-1,:,1);
    B(i).power_ratio_bkg_theta = power_ratio_bkg(1:ecg_chn-1,:,2);
    B(i).power_ratio_bkg_alpha = power_ratio_bkg(1:ecg_chn-1,:,3);
    B(i).power_ratio_bkg_beta = power_ratio_bkg(1:ecg_chn-1,:,4);
    B(i).power_ratio_bkg_all = power_ratio_bkg(1:ecg_chn-1,:,5);
    B(i).chanloc = EEGa.chanlocs(1:ecg_chn-1);
    B(i).art_f = art_f;

end
    B = rmfield(B,'EEG');
end