function B = expand(A,name,values)

B = table2struct(oo.help.combine_tables(struct2table(A),table(values','VariableNames',{name})));

end