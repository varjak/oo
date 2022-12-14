function array = squeeze(A,varargin)

% keys = [d.(B.unique)];
% [~,~,ic] = unique(keys); % unique_keys = unique(keys);

B = oo.help.parse_input(varargin);


t1 = struct2table(A);
t2 = t1(:,B.unique);
% t2.(B.unique) = cellstr(t2.(B.unique));  % Unique on cell just works on cell of chars, not strings. cellstr converts to chars

for i = 1:numel(B.unique)
    column = t2.(B.unique(i));
    if isstring(column)
        t2.(B.unique(i)) = cellstr(column);
    end
end
[~,~,ic] = unique(t2);

fields = fieldnames(A);

if ~isfield(B,'dim')
    B.dim = 1;
end

array = A([]);
for i = 1:max(ic)
    key_ids = find(ic==i);
    for j = 1:numel(key_ids)
        key_id = key_ids(j);
        if j == 1
            array = [array; A(key_id)];
        else
            for k = 1:numel(fields)
                if ~isequal(array(i).(fields{k}), A(key_id).(fields{k}))
                    
                    if strcmp(fields(k),'EEG') && isfield(B,'EEGfields') && B.('EEGfields') == 1
                        aEEG = array(i).('EEG');
                        dEEG = A(key_id).('EEG');
                        % EEGfields = intersect(fieldnames(dEEG),fieldnames(aEEG));
                        common_chans = intersect({aEEG.chanlocs.labels},{dEEG.chanlocs.labels});
                        aEEG = pop_select(aEEG, 'channel', common_chans);
                        dEEG = pop_select(dEEG, 'channel', common_chans);
                        array(i).('EEG') = pop_mergeset(aEEG,dEEG,0);  % Takes care of merging either unepoched ror epoched datasets
                    else
                        array(i).(fields{k}) = cat(B.dim,array(i).(fields{k}),A(key_id).(fields{k}));
                    end
                    
                end
            end
        end
    end
end
end


%                         if isfield(EEGdim, 'data') && EEGdim.('data') == 3
%                             common_chans = intersect({aEEG.chanlocs.labels},{dEEG.chanlocs.labels});
%                             aEEG = pop_select(aEEG, 'channel', common_chans);
%                             dEEG = pop_select(dEEG, 'channel', common_chans);
%                             array(i).('EEG') = pop_mergeset(aEEG,dEEG,0);
%                         end
                        
                        
                        
% array(i).(fields{k}) = [array(i).(fields{k}); d(key_id).(fields{k})];


                            %                                 for m = 1:numel(EEGfields)
                            %                                     switch EEGfields{m}
                            %                                         case 'data', aEEG.data = cat(3,aEEG.data(ismember(achans,common_chans),:,:),dEEG.data(ismember(dchans,common_chans),:,:));
                            %                                         case 'trials', aEEG.trials = aEEG.trials + dEEG.trials;
                            %
                            %
                            %                                 end

%
% if ~isequal(aEEG.(EEGfields{m}), dEEG.(EEGfields{m}))
%
%     if isfield(EEGdim,EEGfields{m})
%         eegdim = EEGdim.(EEGfields{m});
%     else
%         eegdim = ndims(dEEG.(EEGfields{m})) + 1;
%     end
%
%     m
%     EEGfields{m}
%     if m == 9
%         lala = 0;
%     end
%
%     aEEG.(EEGfields{m}) = cat(eegdim,aEEG.(EEGfields{m}),dEEG.(EEGfields{m}));
%
%
% end