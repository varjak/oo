function A = update_chanlocs(A,varargin)

B = oo.help.parse_input(varargin);

for i = 1:numel(A)
    EEG = A(i).EEG;
    
    %% Chanlocs
    [~, ~, ext] = fileparts(B.path);
    switch ext
        case '.mat', load(B.path,'chanlocs');
        case '.bvef', chanlocs = loadbvef(B.path);
        otherwise, fprintf('Channel location file has %s extension and could not be opened! (TODO: write code to open it)\n',ext)
    end
    % load(s.path,'chanlocs');
    chanlocs_temp = [];
    for chi = 1:numel(EEG.chanlocs)
        chanlocs_temp = [chanlocs_temp, chanlocs(ismember({chanlocs(:).labels}, EEG.chanlocs(chi).labels))];
    end
    
    EEG.chanlocs = chanlocs_temp;
    %% Check
    EEG = eeg_checkset( EEG );
    
    A(i).EEG = EEG;
end
end