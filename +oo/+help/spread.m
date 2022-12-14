function A = spread(A,varargin)

B = oo.help.parse_input(varargin);

nfield = numel(B.old_field);

if nfield == 1  % When you want to spread a vector inside the field
    
    dnew = [];
    for i = 1:numel(A)
        nel= numel(A(i).(B.old_field));
        for j = 1:nel
            A(i).("field_temp") = A(i).(B.old_field)(j);
            dnew = [dnew; A(i)];
        end
    end
    A = dnew;
    for i = 1:numel(A)
        A(i).(B.old_field) = A(i).("field_temp");
    end
    A = rmfield(A,("field_temp"));
 
elseif nfield > 1  % When you want to spread multiple fields
    
    dnew = [];
    for i = 1:numel(A)
        for j = 1:nfield
            dnew = [dnew; A(i)];
        end
    end
    A = dnew;
    
    for i = 1:numel(A)
        A(i).(B.new_field1) = A(i).(B.old_field(rem(i-1,nfield)+1));
        A(i).(B.new_field2) = B.new_field2_val(rem(i-1,nfield)+1);
    end
    
    for i = 1:nfield
        A = rmfield(A,B.old_field(i));
    end
    
end
end