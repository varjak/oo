function s = select(A, varargin)

B = oo.help.parse_input(varargin);

% p = struct_char_to_cell(p);

% Combine structures
efield = 'chan';

if strcmp(B.(efield), 'all')
    % p.(efield) = {d(1).EEG.chanlocs(:).labels};
    B.(efield) = string({A(1).EEG.chanlocs(:).labels});
end

s = table2struct(oo.help.combine_tables(struct2table(A),table(B.(efield)','VariableNames',{efield})));

rm = false(1,numel(s));
% Select channel
for i = 1:numel(s)
%     if strcmp(s(i).('chan'),'fp1')
%        lala = 0; 
%     end
    if i == 57
       lala = 0; 
    end
    
    if ~strcmpi({s(i).EEG.chanlocs(:).labels},s(i).('chan'))
        rm(i) = true;
        continue
    end
    % chn = find(ismember({EEG.chanlocs(:).labels}, chan));
    % s(i).EEGch = pop_select(s(i).EEG,'channel',{s(i).('chan')});
    s(i).EEGch = pop_select(s(i).EEG,'channel',cellstr(s(i).('chan')));
end

s(rm) = [];

% Rename field
s = rmfield(s,'EEG');
[s.EEG] = s.EEGch;
s = rmfield(s,'EEGch');

end
