function format(varargin)
%% Inputs
% 'set'         : dataset
% ('lfol')      : folder to load data from
% ('lfil')      : part of the name of the files to load 
% ('sfol')      : folder to save data to

A = oo.help.parse_input(varargin,'lfol',"Unformatted/",'lfil',"",'sfol',"Acquired/");

files = dir(strcat(A.set,A.lfol));
files = files(contains({files.name}, A.lfil) & endsWith({files.name},{'.vhdr','.xdf','.gdf','.mat'}));

for i = 1:numel(files)
    B = struct();
    
    % Ask for pairs
    in = input(sprintf('Format %s into pairs:',files(i).name),'s');
    pairs = split(in);
    
    if isempty(in)
        continue
    end
    
    % Save pairs
    B.set = A.set;
    B.fol = A.sfol;
    for j = 1:2:numel(pairs)
        name = pairs{j};
        value = pairs{j+1};
        if all(ismember(value, '0123456789'))
            value = str2num(value);
        end
        B.(name) = value;
    end
    
    % Load EEG
    [~,~,ext] = fileparts(files(i).name);
    switch ext
        case '.vhdr'
            EEG = pop_loadbv(strcat(files(i).folder,'\'), files(i).name, [], []);
            EEG = remove_auxiliary_chans(EEG);
            EEG = load_impedances(EEG, strcat(files(i).folder,'\',files(i).name));
            if isempty(EEG.chanlocs) || sum(~structfun(@isempty, EEG.chanlocs(1))) < 3
                if isfield(d,'chanlocs')
                    disp('All or most of channel locations are empty. Using specified chan locations.')
                    chanlocs = d.chanlocs;
                else
                    input('All or most of channel locations are empty. Press enter to select a files(i) to load channel locations from.');
                    [files(i),path] = uigetfile('*','Select a files(i)', 'C:\Users\guta_\Desktop\Data Analysis\References\Caps\actiCap 32 Channel\CLA-32.bvef');
                    chanlocs = strcat(path,files(i));
                end
                out_struct = update_chanlocs(struct('EEG',EEG),struct('path', chanlocs));
                EEG = out_struct.EEG;
            end
        case '.xdf'
            % Inside pop_loadxdf > eeg_load_xdf, I disbled Clock Sync with these lines!:
            % % GUSTAVO: CUIDADO:
            % streams = load_xdf(filename, 'HandleClockSynchronization', 0);
            
            EEG = pop_loadxdf(strcat(files(i).folder,'\',files(i).name), 'streamtype', 'EEG', 'exclude_markerstreams', {});
            
            % cargo = load_xdf_new(path_labr_out, 'HandleClockSynchronization', 0);
            
            disp('TODO: .xdf format code')
        case '.gdf'
            disp('TODO: .gdf format code')
        case '.mat'
            load(strcat(files(i).folder,'\',files(i).name),'EEG');
    end
    % Save file
    fpath = strcat(B.set,B.fol,pairs_to_filename(B));
    save(fpath, 'EEG');
end
end
