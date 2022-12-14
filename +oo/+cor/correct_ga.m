function A = correct_ga(A,varargin)

B = oo.help.parse_input(varargin);

% Set
Win = 30;
lpf = [];               % Low pass filter cutoff (default: [ ]=70).
L_interp = 4;           % Interpolation folds (default: [ ]=10).
strig = 1;              % 1 for slice triggers (default) 0 for volume/section triggers
anc_chk = 0;            % 1 to perform ANC 0 No ANC
trig_correct = 0;       % 1 to correct for missing triggers; 0 to NOT correct.
Volumes = [];           % FMRI Volumes.  Needed if trig_correct=1; otherwise use [ ];
Slices = [];            % FMRI Slices/Vol. usage like Volumes.
pre_frac = [];          % Relative location of slice triggers to actual start of slice (slice artifact). default [] = 0.03
exc_chan = 32;
% NPC = 'auto';           % Number of principal components to fit to residuals. 0 to skip OBS fitting and subtraction. 'auto' for automatic order selection (default)
NPC = 0;           % Number of principal components to fit to residuals. 0 to skip OBS fitting and subtraction. 'auto' for automatic order selection (default)
etype = B.marker;    % 'Scan Start', 'R128'. Name of FMRI slice (slice timing) event.  Unlike fmrib_fastr.m, this is the name of the event.  fmrib_fastr.m takes a vector with slice locations.

% ds = 250;

if strcmp(etype,'Scan Start')
    thr = B.thr;
    grad_thr = B.grad_thr;
end

TR = B.TR;
expected_vols = B.expected_vols;
correctly_marked = false(numel(A),1);
tolerance = 10;
 
for i = 1:numel(A)
    EEG = load_if_path(A(i).EEG);
    
    if strcmp(etype,'Scan Start')
        % Mark
        for j = 1:numel(thr)
            for k = 1:numel(grad_thr)
                [~, EEGMARK, vols] = volume_markers(EEG, TR, thr(j), grad_thr(k)); % sets a Scan Start marker for each volume
                EEGMARK.volmarkers = vols;  % vol latencies (vec)
                if abs(expected_vols - numel(vols)) < tolerance
                    break
                end
            end
        end
    else
        EEGMARK = EEG;
        vols = [EEGMARK.event(strcmp({EEGMARK.event(:).type},etype)).latency];
    end
    
    % Warn about and remove incorrectly marked
    if abs(expected_vols - numel(vols)) > tolerance
        fil = sprintf('sub-%d_ses-%d_run-%d',A(i).sub,A(i).ses,A(i).run);
        fprintf('Found %d vols but expected %d in %s! Removing...\n',numel(vols),expected_vols,fil)
        continue
    end
    
    % Find volume markers
    % [~, EEGMARK, lats] = volume_markers(EEG, TR, thr); % sets a Scan Start marker for each volume
    % EEGMARK.data = double(EEGMARK.data);
    scan_lats = [EEGMARK.event(strcmp({EEGMARK.event(:).type},etype)).latency];
    if strcmp(etype,'Scan Start')
        if any(scan_lats-vols)
            fprintf('Latencies differ!\n')
            continue
        end
    end
    
    correctly_marked(i) = 1;
    
    % Plot, to confirm
    figure
    chn = 5;
    plot(EEGMARK.times(1:scan_lats(1))/1000, EEGMARK.data(chn,1:scan_lats(1)), 'Color', [0.5 0.5 0.5]);
    hold on
    plot(EEGMARK.times(scan_lats(1):scan_lats(end))/1000, EEGMARK.data(chn,scan_lats(1):scan_lats(end)));
    hold on
    plot(EEGMARK.times(scan_lats(end):end)/1000, EEGMARK.data(chn,scan_lats(end):end), 'Color', [0.5 0.5 0.5]);
    hold on
    plot_markers(EEGMARK, {etype}, chn,  [])
    hold on
    % - Plot all markers -
    markers = unique({EEGMARK.event(:).type},'stable');
    
    markers = markers(ismember(markers,{'boundary','Sync On','R128','S  1','S  2','S 11','S 12','Scan Start'}));
    cols = jet(numel(markers));
    phs = gobjects(1,numel(markers));
    for m = 1:numel(markers)
        lats = [EEGMARK.event(strcmp({EEGMARK.event(:).type},markers{m})).latency];
        for n = 1:numel(lats)
            ph = plot(EEGMARK.times(lats(n))/1000*[1,1], ylim, 'Color', cols(m,:));
            hold on
        end
        phs(m) = ph;
    end
    legend(phs, markers,'AutoUpdate','off')
    % plot_markers(EEGMARK, {'S  1','S  2','S  5','S  7','S  8','S 10','S 11','S 12'}, [], [])
    xlabel('Time [s]')
    ylabel('Amplitude [uV]')
    title(sprintf('sub-%02d_ses-%02d_run-%02d | Number of volumes: %d',A(i).sub,A(i).ses,A(i).run,numel(scan_lats)), 'Interpreter', 'none')
    pause(1)
    
    % Correct
    EEGMARK.data = double(EEGMARK.data);
    [EEGGA, ~] = pop_fmrib_fastr(EEGMARK,lpf,L_interp,Win,etype,strig,anc_chk,trig_correct,Volumes,Slices,pre_frac,exc_chan,NPC);
    EEGGA.GAcorrection.win = Win;
    EEGGA.GAcorrection.ANC = anc_chk;
    EEGGA.GAcorrection.interp = L_interp;
    
    % Trim
    EEGGA = Trim(EEGGA, [scan_lats(1), scan_lats(end) + TR * EEGGA.srate - 1 ], 'idx');
    EEGGA = Tare(EEGGA);
    
%     % Downsample
%     EEGDWS = pop_resample(EEGGA, ds);
%     for m = 1:size(EEGDWS.event,2) 
%         EEGDWS.event(m).latency = round(EEGDWS.event(m).latency); 
%     end
%     d(i).EEG = EEGDWS;
%     d(i).cor = 'dsAAS';

    A(i).EEG = EEGGA;
    A(i).cor = 'gaAAS';
end
A = A(correctly_marked);
end