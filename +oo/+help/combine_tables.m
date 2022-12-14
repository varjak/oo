function jtab = combine_tables(tab1, tab2)
tab1.key = ones(size(tab1,1),1);
tab2.key = ones(size(tab2,1),1);
jtab = innerjoin(tab1,tab2);
jtab.key = [];
end