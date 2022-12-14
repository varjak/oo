function boxplot(A,varargin)

B = oo.help.parse_input(varargin);

t = struct2table(A,'AsArray',true);
% Quick fix: To know the size of the plot, I check the unique table-rows of
% s (unique on key p.x), but unique does not work on tables of strings!!,
% (only chars)
for i = 1:size(t(:, B.x),1)
    if iscell(t{i, B.x})
        if isstring(t{i, B.x}{1})
            t{i, B.x}{1} = char(t{i, B.x}{1});
        end
    end
end

figure
xn = 1;
if isnumeric(B.y), yn = B.y; else; yn = size(unique(t(:, B.y), 'rows'),1); end
th = tiledlayout(yn, xn);

yboxfield = [A(:).(B.ybox)];
unique_ybox = unique(yboxfield,'stable');

yfield = [A(:).(B.y)];
unique_y = unique(yfield,'stable');

% Quick fix: convert p.x field to string
for i = 1:numel(A)
    if ischar(A(i).(B.x))
        A(i).(B.x) = string(A(i).(B.x));
    end
end

for i = 1:yn
    d = A(yfield == unique_y(i));
    xfield = [d(:).(B.x)];
    unique_x = unique(xfield,'stable');
    boxmat = nan(numel(unique_ybox),numel(unique_x));
    for j = 1:numel(unique_x)
        d2 = d(xfield == unique_x(j));
        for k = 1:numel(d2)
            boxmat(k,j) = d2(k).(B.var);
            % CUIDADO:
%             boxmat(k,j) = d2(k).(p.var)(:,20);  % For Eyes boxplots, chn 20 = Oz
        end
    end
    
    for j = 1:numel(unique_x)
       switch unique_x{j}
           case {'ga30Las','hpFitPa30Las','paLas','hpPa30Las'}, unique_x{j} = 'NeuXus';
           case {'gaAAS','paAAS'}, unique_x{j} = 'EEGLAB';
           case {'gaReV','paReV','paReV2'}, unique_x{j} = 'RecView';
       end
    end
    
    nexttile
    boxplot(boxmat,'Colors',[0.5,0.5,0.5],'Labels',unique_x)
    hold on
    colors = jet(numel(unique_ybox));
    for j = 1:numel(unique_x)
        shs = gobjects(1,numel(unique_ybox));
        leg = {};
        for k = 1:numel(unique_ybox)
            sh = scatter(j, boxmat(k,j),[],colors(k,:),'filled');
            sh.MarkerFaceAlpha = 0.7;
            hold on
            shs(k) = sh;
            leg = [leg, sprintf('sub-%02d',unique_ybox(k))];
        end
    end
    
%     if i == yn
%         lh = legend(shs,leg,'AutoUpdate','off');
%         lh.Location = 'bestoutside';
%     end
    
    % Remove xlabel from all but bottom plot
    if i ~= yn
        set(gca,'Xticklabel',[])
    end
    
    if isfield(B,"ylab")
        ylabel(B.ylab)
    end
%     if isfield(p,"title")
%         title(p.title)
%     else
%         title(unique_y(i))
%     end
    
    ylabel('Power % change')
%     ylabel('ERSP%')
%     if isfield(p,"ylim")
%         ylim(p.ylim)
%     end
    
    if i == 1
        % ylim([0,1])
%         ylim([-100,-46])
        % ylim([-100,0])  % PA
        % ylim([-50,+50])
%         ylim([-80,80]);
%         ylim([-100,0])  % PA boxplot
% ylim([-100,-50])
ylim([-100,-40])  % GA boxplot
yticks([-100,-80,-60,-40])  % GA

%     ylim([-100,100])  % MI
    elseif i == 2
%         ylim([-15,1])
        % ylim([-50,+50])
        % ylim([-100,100]);
%         ylim([-100,0])  % PA boxplot
        
        ylim([-15,0])  % GA boxplot
    end

    
    %     if i == 1
    %         ylim([-40,80])
    %     elseif i == 2
    %        ylim([-40,40])
    %     end
    
    %     if i == 1
    %         ylim([-100,100])
    %     elseif i == 2
    %        ylim([-100,100])
    %     end
    
end












end