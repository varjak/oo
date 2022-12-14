function E = load(varargin)
% Inputs
%   ('set',...):    dataset folder
%   ('fol',...):    data folder
%   ('...',...):    any (name,value) in the file name
%   ('runof',...):  name in the file name to which the input 'run' refers to
%   ('load',0|1):   whether to load the data (1) or the path to the file (0) (e.g. for when the data is heavy) 
% Outputs
%   E:              struct array with the data for each specified file
% Examples
%   unc = oo.io.load('set',nset,'fol','Acquired/','sub',1:5,'ses',2,'task',"grazMI",'load',0);
%   unc = oo.io.load('set',nset,'fol','Preprocessed/','sub',{1:5,6},'ses',{1,2},'task',["grazMI","rest"],'pre',4);

A = oo.help.parse_input(varargin,'load',1);
B = rmfield(A,{'load'});
C = oo.help.combine(B);
D = rmfield(C,{'set','fol'});

fields = fieldnames(B);
names = fieldnames(D);

E = struct;
c = 0;  % Number of match
for i = 1:numel(C)
    % List folder files
    fol = strcat(C(i).set,C(i).fol);
    found = dir(fol);
    found = found([found.isdir] == 0);
    
    c_before_match = c;
    for j = 1:numel(found)
        % List folder filename pairs
        found_pairs = regexp(found(j).name,'([a-zA-Z]+)-([a-zA-Z0-9]+)','tokens');
        for m = 1:numel(found_pairs)
            value = found_pairs{m}{2};
            if all(ismember(value, '0123456789'))
                found_pairs{m}{2} = str2num(value);
            else
                found_pairs{m}{2} = string(value);
            end
        end
        
        % Match requested and folder filename pairs
        match_vol = zeros(numel(names),numel(found_pairs),2);
        for k = 1:numel(names)
            for m = 1:numel(found_pairs)
                name = found_pairs{m}{1};
                value = found_pairs{m}{2};
                match_vol(k,m,1) = strcmp(names{k}, name);

                if k == 4
                   lala = 0; 
                end
                
                if ((ischar(C(i).(names{k}))||isstring(C(i).(names{k}))) && (ischar(value)||isstring(value))) || (isnumeric(C(i).(names{k})) && isnumeric(value))
                    match_vol(k,m,2) = all(C(i).(names{k}) == value);
                end
            end
        end
        
        match_mat = match_vol(:,:,1) & match_vol(:,:,2);  % Find matched requested and found pairs
        match_col = any(match_mat,2);
        match = all(match_col);  % All requested pairs must be matched
        % Load
        if match
            c = c + 1;
%             for k = 1:numel(fields)
%                 E(c).(fields{k}) = C(i).(fields{k});
%             end
            E(c).set = C(i).set;
            E(c).fol = C(i).fol;
            for k = 1:numel(found_pairs)
                E(c).(found_pairs{k}{1}) = found_pairs{k}{2};
            end
            fpath = strcat(found(j).folder,'\',found(j).name);
            % Load files
            if A(1).load
                cargo = load(fpath);
                cargofields = fieldnames(cargo);
                for k = 1:numel(cargofields)
                    if strcmp(cargofields{k},'EEG')
                        EEG = cargo.EEG;
                        EEG = check_EEG(EEG, fpath);
                        E(c).('EEG') = EEG;
                    else
                        E(c).(cargofields{k}) = cargo.(cargofields{k});
                    end
                end
            % Load paths
            else
                info = whos('-file',fpath);
                for k = 1:numel(info)
                    E(c).(info(k).name) = string(fpath);
                end
            end
        end
    end
    % If for a input entry there was no file match, thow error
    if c_before_match == c
        msg = 'No file was found with the following inputs:';
        for j = 1:numel(fields)
            msg = [msg, sprintf('\n%s: %s', fields{j},string(C(i).(fields{j})))];
        end
        error(msg)
    end
end
