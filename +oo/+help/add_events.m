function A = add_events(A,B,varargin)

C = oo.help.parse_input(varargin);

if ~isfield(C,'new_event')
    C.new_event = C.event;
end

C.event = char(C.event);
C.new_event = char(C.new_event);

for i = 1:numel(A)
    
    EEGa = load_if_path(A(i).EEG);
    EEGb = load_if_path(B(i).EEG);
    
    % Add missing fields
    fields_a = fieldnames(EEGa.event);
    fields_b = fieldnames(EEGb.event);
    
    for j = 1:numel(fields_a)
        if ~ismember(fields_a(j),fields_b)
            EEGb.event(1).(fields_a{j}) = [];
        end
    end
    
    for j = 1:numel(fields_b)
        if ~ismember(fields_b(j),fields_a)
            EEGa.event(1).(fields_b{j}) = [];
        end
    end
    
    % Make events vertical
    EEGa.event = EEGa.event(:);
    EEGb.event = EEGb.event(:);
    
    events_to_add = EEGb.event(strcmp({EEGb.event(:).type},C.event));
    
    for j = 1:numel(events_to_add)
        events_to_add(j).type = C.new_event;
        
    end
    
    EEGa.event = [EEGa.event; events_to_add];
    [~,I] = sort([EEGa.event(:).latency]);
    EEGa.event = EEGa.event(I);
    for j = 1:size(EEGa.event,1)
        EEGa.event(j).urevent = j;
    end
    
    EEGa.event = EEGa.event';  % Make events horizontal again!
    A(i).EEG = EEGa;
    
end
end