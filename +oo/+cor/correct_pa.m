function A = correct_pa(A)


for i = 1:numel(A)
    
    EEG = load_if_path(A(i).EEG);
    
    EEG.data = double(EEG.data);
    [EEG, ~] = pop_fmrib_pas(EEG, 'QRSi', 'mean');
    
    A(i).EEG = EEG;
    A(i).cor = 'paAAS';

end
end