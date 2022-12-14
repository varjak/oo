function subS = select_substruct(S,subfields)

fields = fieldnames(S);
mask = ~ismember(fields,subfields);
subS = rmfield(S,fields(mask));

end