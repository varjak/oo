function imgplot(A,varargin)

B = oo.help.parse_input(varargin,'tit','','mat','erd_mat');

figure
t = struct2table(A,'AsArray',true);
xn = size(unique(t(:, B.x), 'rows'),1);
yn = size(unique(t(:, B.y), 'rows'),1);
tiledlayout(yn, xn)

for i = 1:numel(A)
    
    mat = A(i).(B.mat);
    
    nexttile
    imagesc('XData',A(i).time_vec,'YData',A(i).freq_vec,'CData',mat,B.clims)
    hold on
    colormap jet
    caxis(B.clims)
    plot([A(i).time_vec(1),A(i).time_vec(end)],8*[1,1],'Color',[0,0,0])
    hold on
    plot([A(i).time_vec(1),A(i).time_vec(end)],12*[1,1],'Color',[0,0,0])
    hold on
    plot([0,0],ylim,'Color',[0,0,0],'LineStyle','--')
    hold on
    if isfield(B,'xlim'), xlim(B.xlim); else, xlim([A(i).time_vec(1), A(i).time_vec(end)]); end
    if isfield(B,'ylim'), ylim(B.ylim); else, ylim([A(i).freq_vec(1), A(i).freq_vec(end)]); end
    
    t1 = struct2table(A(i),'AsArray',true);

%     if isequal(t(1,p.x),t1(:,p.x))
% %         ylabel('Frequency [Hz]')
%         words = get_words(p.y, s(i));
%         ylabel(task_colors(words{:})); 
% %         yticks(p.ylim)
% % ylabel('Run 4')
%     else
%         set(gca,'yticklabel',[])
%     end
%     
    if isequal(t(1,B.y),t1(:,B.y))
        words = get_words(B.x, A(i));
        % title(prep_dir_chan(words{:})); 
% %         title('LEFT C4')
    end

    switch A(i).(B.tit)
        case 'paLas', tit = 'NeuXus';
        case 'paReV', tit = 'RecView';
        case 'paAAS', tit = 'EEGLAB';
        otherwise, tit = '';
    end
    
    if isequal(t(1,B.y),t1(:,B.y))
        title(tit)
    end
    if i == 1
       ylabel('Frequency [Hz]') 
    end
    
    if ~isequal(t(end,B.y),t1(:,B.y))
        % xlabel('Time [s]')
%         set(gca,'xticklabel',[])
    else
        xlabel('Time [s]')
    end
    
    ylab = 'Sub %d';
    % if isequal(t(1,B.x),t1(:,B.x)), ylabel(sprintf(ylab,A(i).(B.y))); end
    
    if isequal(t(end,B.x),t1(:,B.x)) && isequal(t(end,B.y),t1(:,B.y))
        cbh = colorbar;
        cbh.Title.String = "ERSP%";
    end
end
end

function words = get_words(keys,struct_scalar)
        words = cell(1,numel(keys));
        for j = 1:numel(keys)
            words{j} = struct_scalar.(keys(j));
        end
end

function ylab = task_colors(a)
a = char(a);
a = strcat(a(1),a(isstrprop(a,'upper')));
switch a(end-1:end)
    case 'HP', ylab = sprintf("\\bf{%s}\\color{red}\\bf{%s}",a(1:end-2),a(end-1:end));
    case 'NF', ylab = sprintf("\\bf{%s}\\color{blue}\\bf{%s}",a(1:end-2),a(end-1:end));
    otherwise, ylab = sprintf("\\bf{%s}",a);  
end
end

function ylab = prep_dir_chan(a,b,c)
switch b
    case 'S  7', b = 'L';
    case 'S  8', b = 'R';
end
    ylab = sprintf("\\bf{Pre %d} \\rm{%s-%s}",a,b,c);
end

        
%         words = cell(1,numel(p.x));
%         for j = 1:numel(p.x)
%             words{j} = s(i).(p.x(j));
%         end


    % ylab = strcat(upper(p.y(1)), p.y(2:end), ' %d');
%     ylab = strcat(upper(p.y{1}(1)), p.y{1}(2:end), ' %d');
%     tlab = '%s %s';
%     if isequal(t(1,p.x),t1(:,p.x)), ylabel(sprintf(ylab,s(i).(p.y))); end
%     if isequal(t(1,p.y),t1(:,p.y)), title(sprintf(tlab,t1{1,p.x}{:})); end