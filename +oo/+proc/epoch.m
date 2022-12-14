function C = epoch(A, varargin)


B = oo.help.parse_input(varargin);
C = oo.help.expand(A,'event',B.event);

% Epoch
for i = 1:numel(C)
    fprintf('Epoching entry %d / %d\n', i, numel(C))
    
    if i == 26 || i == 27
       lala = 0; 
    end
    
    C(i).EEGep = pop_epoch(C(i).EEG, {C(i).event}, B.elims, 'epochinfo', 'yes');
end

% Rename field
C = rmfield(C,'EEG');
[C.EEG] = C.EEGep;
C = rmfield(C,'EEGep');
end
