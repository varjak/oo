function A = parse_input(varargin)

% % Save varargin cell to struct
% inputs = varargin{1};
% for i = 1:2:numel(inputs)
%     value = inputs{i+1};
%     if ischar(value) || iscellstr(value)  % Convert char or cell of char to string
%        value = string(value); 
%     end
%     A.(inputs{i}) = value;
% end

% Save varargin cell to struct
inputs = varargin{1};
A = struct(inputs{:});

% Convert char values to string values
fields = fieldnames(A);
for i = 1:numel(fields)
    for j = 1:numel(A)
        value = A(j).(fields{i});
        if ischar(value)
            A(j).(fields{i}) = string(value);
        end
    end
end

% Fill struct with defaults
fields = fieldnames(A);
default_names = varargin(2:end);
for i = 1:2:numel(default_names)
    if ~ismember(default_names{i},fields)
        A.(default_names{i}) = default_names{i+1};
    end
end
end