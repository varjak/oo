function C = combine_(A,B,C,fi)

fields = fieldnames(A);
field = fields{fi};

if ischar(A.(field))
    A.(field) = {A.(field)};
end

for i = 1:numel(A.(field))
    value = A.(field)(i);
    if iscell(value) 
        value = value{:};
    end
    B(1).(field) = value;
    if fi < numel(fields)
        C = oo.help.combine_(A,B,C,fi+1);
    else
        C = [C; B];
    end
end
end