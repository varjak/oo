function C = order(A, varargin)

B = oo.help.parse_input(varargin);

for i = 1:numel(A)
    for j = 1:numel(B.target)
        
        if ischar(B.order{j}) && strcmp(B.order{j},'asc')
            unique_sort_vals = unique([A.(B.target(j))]);
        elseif ischar(B.order{j}) && strcmp(B.order{j},'desc')
            unique_sort_vals = sort(unique([A.(B.target(j))],'stable'),'descend');
        else
            unique_sort_vals = B.order{j};
        end
        
        for k = 1:numel(unique_sort_vals)
            if A(i).(B.target(j)) == unique_sort_vals(k)
                A(i).(strcat(B.target(j),'_helper')) = k;
            end
        end
    end
end
for i = 1:numel(B.target)
    B.target(i) = strcat(B.target(i),'_helper');
end
    
% % CUIDADO:
% if isfield(B,'order')
%     for i = 1:numel(d)
%         for j = 1:numel(B.target)
%             for k = 1:numel(B.order{j})
%                 if d(i).(B.target(j)) == B.order{j}(k)
%                     d(i).(strcat(B.target(j),'_helper')) = k;
%                 end
%             end
%         end
%     end
%     for i = 1:numel(B.target)
%         B.target(i) = strcat(B.target(i),'_helper');
%     end
% end

if ~isfield(B,'dir')
    B.dir = [];
    for i = 1:numel(B.target)
        B.dir = [B.dir, "ascend"];
    end
end

% Remove not-to-sort-fields
d2sort = A;
if isfield(B, 'target')  % if not, B has to have a field ignore!
    d2sort = oo.help.select_substruct(A,B.target);
elseif isfield(B, 'ignore')
    for i = 1:numel(B.ignore)
        d2sort = rmfield(d2sort,B.ignore(i));
    end
end


% if isfield(B, 'ignore')
%    for i = 1:numel(B.ignore)
%        d2sort = rmfield(d2sort,B.ignore(i));
%    end
% end

% Sort table to get sort indices
    
    
%    for i = 1:numel(B.ord)
%        for j = 1:numel(d)
%            if d(j)
%                
%            end
%           d(j).(strcat(B.ord,'_helper')) = ; 
%        end
%        mask = {B.band} == B.ord(i);
%    end
% end

t2sort = struct2table(d2sort);
[t, index] = sortrows(t2sort,1:size(t2sort,2),cellstr(B.dir));

% Sort struct
A = A(index);

% CAREFUL:
fields = fieldnames(A);
remove_helpers = false(1,numel(fields));
for i = 1:numel(fields)
    for j = 1:numel(B.target)
        if strcmp(fields{i}, B.target(j))
            remove_helpers(i) = 1;
        end
    end
end
C = rmfield(A,fields(remove_helpers));


end


%%
%             [~,~,ic] = unique([d.(B.target(j))],'stable');
%             [~,I] = sort(ic,'descend');
%             clear order_ids
%             order_ids(I) = 1:numel(I);