function C = apply_fun(A,varargin)

B = oo.help.parse_input(varargin);
C = B.fun(A);
% 
% arguments
%     X1;
%     X2.fun;
%     X2.tab;
%     X2.old_fields;
%     X2.new_fields;
% end
% 
% if isfield(X2,'fun')
%     X1 = X2.fun(X1);
%     
% elseif isfield(X2,'tab')
%     map = table2struct(X2.tab);
%     
%     for i = 1:numel(X1)
%         fprintf('File %02d / %02d\n',i,numel(X1));
%         
%         mask = ones(size(map));
%         for j = 1:numel(X2.old_fields)
%             name = X2.old_fields(j);
%             mask = mask & (ismember([map.(name)], X1(i).(name)))';
%         end
%         
%         id = find(mask);
%         switch numel(id)
%             case 0, fprintf('Found no conversion! Skipping...\n');
%             case 1
%             otherwise, fprintf('Found more than one conversion. Choosing the first.\n'); id = id(1);
%         end
%         
%         for j = 1:numel(X2.new_fields)
%             name = X2.new_fields(j);
%             mapname = name;
%             if ismember(name,X2.old_fields)
%                mapname = strcat(name,'_1'); 
%             end
%             X1(i).(name) = map(id).(mapname);
%         end
%     end
% end
end