function A = update_events(A,varargin)

B = oo.help.parse_input(varargin);

for i = 1:numel(A)
    
    lfil = '';
    
    for j = 1:numel(B.match)
        name = char(B.match(j));
        value = A(i).(name);
        if isnumeric(value)
           value = sprintf('%02d',value); 
        end
        value = char(value);
        lfil = [lfil,name,'-',value,'_'];
    end
    lfil(end) = [];  % Remove last '_'
    
    load(strcat(A(i).set,B.lfol,lfil),'EEG');
    
    EEGa = A(i).EEG;    % To put events on
    EEGb = EEG;         % To get events from

    % Update latencies
    event_times = EEGb.times([EEGb.event(:).latency]);
    event_lats = dsearchn(EEGa.times',event_times');
    temp_array = EEGb.event;
    for j = 1:numel(event_lats)
        temp_array(j).latency = event_lats(j);
    end
    
    % Concatenate
    EEGa.event = [EEGa.event, temp_array];
    
    % Sort
    [~,I] = sort([EEGa.event(:).latency]);
    EEGa.event = EEGa.event(I);
    for j = 1:numel(EEGa.event)
        EEGa.event(j).urevent = i;
    end
    
    A(i).EEG = EEGa;

end
end
