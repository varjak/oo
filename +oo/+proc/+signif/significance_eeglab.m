function A = significance_eeglab(A,varargin)

B = oo.help.parse_input(varargin);
base_lims = B.blims;
timesi_lims = B.tlims;
freqsi_lims = B.flims;
N_reps = B.reps;

for i = 1:numel(A)
    vol = A(i).(B.vol);
    time_vec = A(i).time_vec;
    freq_vec = A(i).freq_vec;
    
    % TF logic masks
    base_logic = time_vec > base_lims(1) & time_vec < base_lims(2);
    timesi_logic = time_vec > timesi_lims(1) & time_vec < timesi_lims(2);
    freqsi_logic = freq_vec > freqsi_lims(1) & freq_vec < freqsi_lims(2);
    
    % TF index masks
    freqsi_idxs = find(freqsi_logic);
    timesi_idxs = find(timesi_logic);
    
    L_tubbase = sum(base_logic)*size(vol,3);
    L_tub = size(vol,3);
    
    pval_mat = nan(size(vol,1),size(vol,2));
    
    for fi = freqsi_idxs
        for ti = timesi_idxs
            % EEGLAB test, directly (for speed)
            [~, ~, pval] = statcond({reshape(vol(fi,base_logic,:),[1,1,L_tubbase]), reshape(vol(fi,ti,:),[1,1,L_tub])},'paired','off','method','bootstrap','naccu',N_reps,'verbose','off','tail','lower');
            pval_mat(fi,ti) = pval;
        end
    end
    
    A(i).pval_mat = pval_mat;
    
end
end