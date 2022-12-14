function A = ersp(A,varargin)

B = oo.help.parse_input(varargin);

% Set
baseline = nan; % Indiferent actually
scale = 'abs';
cycles = 0;

for i = 1:numel(A)
    % Get
    EEG = A(i).EEG;
    tubmat = double(EEG.data);
    times = EEG.times;
    fs = EEG.srate;
    
    % TF
    [~, ~, ~, time_vec, freq_vec, ~, ~, amp_tf_vol] = newtimef_trueamp(tubmat, size(tubmat,2), [times(1) times(end)], fs, cycles,'plotitc','off', 'baseline', baseline, 'scale', scale, 'plotersp', 'off');
    time_vec = time_vec/1000;
    tf_vol = double(amp_tf_vol);

    % Amplitude/power
    switch B.tfout
        case 'amp' 
        case 'pow', tf_vol = tf_vol.^2;
    end

    % Trial average
    switch B.avgs{1} 
        case 'mean', tf_mat = mean(tf_vol,3);
        case 'median', tf_mat = median(tf_vol,3);
        case 'madmean', mad_mat = mad(tf_vol,1,3); med_mat = median(tf_vol,3); tf_vol(tf_vol>med_mat+mad_mat*3) = nan; tf_mat = mean(tf_vol,3,'omitnan');
    end

    % Normalization by baseline average
    switch B.avgs{2}
        case 'mean', erd_tf_mat = (tf_mat./mean(tf_mat(:,time_vec > B.blims(1) & time_vec < B.blims(2)),2) - 1)*100;
        case 'median', erd_tf_mat = (tf_mat./median(tf_mat(:,time_vec > B.blims(1) & time_vec < B.blims(2)),2) - 1)*100;
    end

    % Frequency average
    switch B.avgs{3}
        case 'mean', erd_vec = mean(erd_tf_mat(freq_vec > B.flims(1) & freq_vec < B.flims(2),:),1);
        case 'median', erd_vec = median(erd_tf_mat(freq_vec > B.flims(1) & freq_vec < B.flims(2),:),1);
    end

    % Time average
    switch B.avgs{4}
        case 'mean', erd_task = mean(erd_vec( time_vec > B.tlims(1) & time_vec < B.tlims(2)));
        case 'median', erd_task =  median(erd_vec( time_vec > B.tlims(1) & time_vec < B.tlims(2)));
    end
    
    A(i).chanloc = EEG.chanlocs(ismember(upper({EEG.chanlocs(:).labels}),upper(A(i).chan)));
    A(i).time_vec = time_vec;
    A(i).freq_vec = freq_vec;
    A(i).erd_mat = erd_tf_mat;
    A(i).erd_val = erd_task;
    A(i).tf_vol = tf_vol;
    
end
A = rmfield(A,'EEG');
end
