function B = combine(A)

B = [];
for i = 1:numel(A)
    B = [B; oo.help.combine_(A(i),A([]),A([]),1)];  % Recursive
end

end