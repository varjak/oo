function topoplot(A,varargin)

B = oo.help.parse_input(varargin);

[t, xn, yn] = get_plot_dimensions(A,B);
figure
th = tiledlayout(yn, xn);
th.TileSpacing = 'none';

% plot_options = struct('label',{'c3','c4'},'show_label',{1,1},'marker',{'.','.'},'marker_col',{[0,0,0], [0,0,0]});
plot_options = struct('label',{'c3','c4'},'show_label',{0,0},'marker',{'.','.'},'marker_col',{[0,0,0], [0,0,0]});
% tits = {'Unc.', 'Online-LaS', 'Offline-AAS'};


for i = 1:numel(A)
    
    [co,ro] = ind2sub([xn,yn],i);
    
    chanstruct = set_topo_options(A(i).chanloc, plot_options);
    % topovec = s(i).erd_val;
    topovec = A(i).(B.var)(:);
    
    % CUIDADO:
    topovec = topovec(:,:,end);
    
    % CUIDADO
    chanstruct(ismember(upper({chanstruct(:).labels}),{'ECG','EKG'})) = [];
    % chanstruct = chanstruct(1:31);
    
    nh = nexttile;
    topoplot_custom_chans(nh, topovec, chanstruct, 'electrodes', 'labelpoint');
    
    
    % Color option 1
    % Use half of the colormap
    % c = c(1:128,:);
%     c = jet(256);
    % c = c(1:128,:);
%     colormap(nh,c)
    
    % clims = [-100,100];
    % clims = [-50,50];
    
%     if isfield(p, 'clim')
%         clims = p.clim;
%     else
%         clims = [-100,100]; % clims = [-80,80];
%     end

    % Define range for half of the colormap
    if ro == 1
        clims = [-100,-39]; % GA
        % clims = [-50,50];
        % clims = [-80,80];
%         clims = [-100,0];  % PA: clean vs. after
%         clims = [-75,-25];
    elseif ro == yn
        clims = [-15,0];  % GA
        % clims = [-50,50];
%         clims = [-80,80];
%         clims = [-100,0];  % PA: clean vs. after
%         clims = [-75,-25];
    end
% 
%     if ro == 1
%         clims = [-1,1];
%     elseif ro == yn
%         clims = [-0.025,0.025];
%     end
    
    c = jet(256);
    if ~any(clims>0)
        c = c(1:128,:);
    end
    colormap(nh,c)
    

    caxis(clims)
    
    % Define range for half of the colormap
    %     if ro == 1
    %         clims = [-0.4,0.4];
    %     elseif ro == yn
    %         clims = [-0.4,0.4];
    %     end
    %     caxis(clims)
    
    % Plot colorbar
    if co == xn
        cbh = colorbar;
        
        
        if ro == 1
%             AxesH = axes('CLim', [-40, -100]);
%             cbh = colorbar('peer', AxesH, 'h', 'XTickLabel',{'-40','-60','-80','-100'}, 'XTick',[-40,-60,-80,-100]);
            
%             cbh.Title.String = "Power % change";
            cbh.Title.String = "Power % change";
            
            % GA:
%             cbh.XTick = [-100,-80,-60,-40];
%             cbh.XTickLabel = {'-100','-80','-60','-40'};

            %cbh.XTick = [-40,-60,-80,-100];
        else
            cbh = colorbar;
        end
    end
    
%     if i == numel(s)
%         cbh = colorbar;
%         cbh.Title.String = "ERSP%";
%     end
    
%         cbh = colorbar;
%         cbh.Title.String = "Power difference";
    
    if ro == 1
        tit = '';
        switch A(i).(B.tit)
            case {'ga30Las','hpFitPa30Las','hpPa30Las'}, tit = 'NeuXus';
            case {'gaAAS','paAAS'}, tit = 'EEGLAB';
            case {'gaReV','paReV'}, tit = 'RecView';
        end
        title(tit)
    end
    
    
    %     if ro == 1
    %         clims = [-100,-50];
    %     elseif ro == yn
    %     end
    %
    %     colormap(nh,c)
    %     caxis(clims)
    %
    %
    %
    %     lele = 1;
    %
    %     %     if isfield(p,'clims')
    %     %         clims = p.clims;
    %     %     else
    %     %         clims = [-100,100];
    %     %     end
    %
    %     %     if isequal(t(i,p.y),t(1,p.y))
    %     %         c1 = c;
    %     %         colormap(nh,c1);
    %     %         clims = [-100,100];
    %     %         caxis(clims)
    %     %     elseif isequal(t(i,p.y),t(end,p.y))
    %     %         c2 = c;
    %     %         colormap(nh,c2);
    %     %         clims = [-100, 100];
    %     %         caxis(clims)
    %     %     end
    %
    %
    %     %     if isequal(t(i,p.y),t(1,p.y))
    %     %         c1 = c(1:64,:);
    %     %         % c1 = c(1:128,:);
    %     % %         c1 = c;
    %     %         colormap(nh,c1);
    %     %         % clims = [-100,0];
    %     %         clims = [-100,-50];
    %     %         caxis(clims)
    %     %     elseif isequal(t(i,p.y),t(end,p.y))
    %     % %         c2 = c(1:128,:);
    %     % %         c2 = c;
    %     %         c2 = c(109:128,:);
    %     %         colormap(nh,c2);
    %     %         clims = [-15, 0];
    %     %         caxis(clims)
    %     %     end
    %
    %     if isequal(t(i,p.y),t(1,p.y))
    %         c1 = c(1:64,:);
    %         % c1 = c(1:128,:);
    %         %         c1 = c;
    %         colormap(nh,c1);
    %         % clims = [-100,0];
    %         clims = [-100,-50];
    %         caxis(clims)
    %     elseif isequal(t(i,p.y),t(end,p.y))
    %         %         c2 = c(1:128,:);
    %         %         c2 = c;
    %         c2 = c(109:128,:);
    %         colormap(nh,c2);
    %         clims = [-15, 0];
    %         caxis(clims)
    %     end
    %
    %     %
    %     if isequal(t(i,p.x),t(end,p.x))
    %         cbh = colorbar;
    %         if isequal(t(i,p.y),t(1,p.y))
    %             cbh.Title.String = "Power % change";
    %         end
    %     end
    %
    %
    %
    %     %     if isequal(t(i,p.y),t(1,p.y)) && isequal(t(i,p.x),t(end,p.x))
    %     %         colorbar;
    %     %     end
    %     %
    %     %     caxis(clims)
    %     %     if i == numel(s)
    %     %         colorbar;
    %     %     end
    %
    %
    %     % if isequal(t(1,p.y),t1(:,p.y)), title(sprintf(tlab,t1{1,p.x}{:})); end
    %
    %     if isequal(t(i,p.y),t(1,p.y)), title(s(i).(p.x)); end
    %
%             if strcmp(s(i).dir,s(1).dir)
%                 words = get_words("task", s(i));
%                 title(task_colors(words{:}));
%             end
    %
    %     %     if i == 1
    %     %         title('LEFT')
    %     %     elseif i == 2
    %     %         title('RIGHT')
    %     %     end
        %     % title(tits{i})
end
end

% Check plot_erd_topo.m for further info, and my (in github) use of
% topoplot_custom_chans

function ylab = task_colors(a)
a = char(a);
a = strcat(a(1),a(isstrprop(a,'upper')));
switch a(end-1:end)
    case 'HP', ylab = sprintf("\\bf{%s}\\color{red}\\bf{%s}",a(1:end-2),a(end-1:end));
    case 'NF', ylab = sprintf("\\bf{%s}\\color{blue}\\bf{%s}",a(1:end-2),a(end-1:end));
    otherwise, ylab = sprintf("\\bf{%s}",a);
end
end

function words = get_words(keys,struct_scalar)
words = cell(1,numel(keys));
for j = 1:numel(keys)
    words{j} = struct_scalar.(keys(j));
end
end

function loc_array = set_topo_options(chanloc, plot_options)
loc_array = [];
for j = 1:numel(chanloc)
    % Get channel location
    loc_struct = chanloc(j);
    
    % Set default plot options
    loc_struct.show_label = 0;
    loc_struct.marker = '.';
    loc_struct.marker_col = [0,0,0];
    
    % Set specified plot options
    for opt = 1:numel(plot_options)
        if strcmpi(strtrim(loc_struct.labels),plot_options(opt).label)
            loc_struct.show_label = plot_options(opt).show_label;
            loc_struct.marker = plot_options(opt).marker;
            loc_struct.marker_col = plot_options(opt).marker_col;
        end
    end
    % Store
    loc_array = [loc_array; loc_struct];
end
end
