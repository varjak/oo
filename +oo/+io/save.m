function save(A, varargin)

B = oo.help.parse_input(varargin);

field_names_ori = fieldnames(A);
field_names_added = fieldnames(B);

for i = 1:numel(field_names_added)
    if ~ismember(field_names_added{i},field_names_ori)
        for j = 1:numel(A)
            A(j).(field_names_added{i}) = B.(field_names_added{i});
        end
    end
end

field_names = fieldnames(A);

for i = 1:numel(A)
    
    % File name
    kw_ids = find(~ismember(field_names, {'set','fol','EEG'}));  % {'set','fol','task','EEG'} | {'set','fol','EEG'}
    file_name = '';
    for j = 1:numel(kw_ids)
        id = kw_ids(j);
        word = A(i).(field_names{id});
        if isnumeric(word)
            
            if numel(word) > 1
               continue % case is vector, like 'run',[1,2,3] (I decided to not concatenate numbers) 
            end
            % word = num2str(word);
            word = sprintf('%02d', word);
        end
        file_name = strcat(file_name, field_names{id},'-',word);
        if j ~= numel(kw_ids)
            file_name = strcat(file_name,'_');
        end
    end
    
    % Data
    EEG = A(i).EEG;
    
    % Set name
    if isfield(B,'set')
        pset = B.set;
    else
        pset = A(i).set;
    end
    
    % Folder name
    if isfield(B,'fol')
        pfol = B.fol;
        
        if contains(pfol,'%')
            [sub,ses,~,~,~] = get_words_from_bids(dname);
            list(i).fol = sprintf(list(i).fol,sub,ses);
        end
        
    else
        pfol = A(i).fol;
    end
    
    % Check if file already exists, and if so ask to overwrite
    file_full_name = strcat(pset,pfol,file_name,'.mat');
    if isfile(file_full_name)
        if ~input(sprintf('%s already exists. Overwrite? (1/0) ',file_full_name))
            continue
        end
    end
    save(file_full_name,'EEG');
end
