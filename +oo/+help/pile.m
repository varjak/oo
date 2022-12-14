function struct_array = pile(varargin)
% Pile structure arrays, setting uncommon fields' values to ''
N = nargin;

% Get total fields
total_fields = {};
for n = 1:N
    total_fields = [total_fields; fieldnames(varargin{n})];
end

% Keep unique fields (in hope next loop is faster)
total_fields = unique(total_fields,'stable');
M = numel(total_fields);

struct_array = struct([]);
for n = 1:N
    % Add missing fields (with '' value)
    for m = 1:M
        if ~isfield(varargin{n},total_fields{m})
%             varargin{n}(1).(total_fields{m}) = '';
            for k = 1:numel(varargin{n})
                varargin{n}(k).(total_fields{m}) = '';
            end
        end
    end
    % Concatenate
    struct_array = [struct_array; varargin{n}(:)];
end
end
