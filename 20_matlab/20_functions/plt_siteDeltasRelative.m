function ax = plt_siteDeltasRelative(backGroundColor,cm,fsAxis,fsTitle,validSiteNames,sitePercentages,yLims,plotType)

%% ------ Colormap settings -----
nColors                                         = 11;
% fsTitle                                         = fsAxis + 5;
cmAdj                                           = cm(round(linspace(1,size(cm,1),nColors)),:);
% Grid color barplot
gridColor                                       = [0,0,0];
% Linewidt barplot
lwBar                                           = 1;
% Edgecolor barplot
edgeColor                                       = [0,0,0];

if strcmpi(plotType,'heatmap')
    %% ------ Heatmap ------
    h                                               = heatmap(round(sitePercentages,2));
    h.Colormap                                      = cmAdj;
    h.FontSize                                      = fsAxis;
    h.XDisplayLabels                                = validSiteNames;
    h.YDisplayLabels                                = {''};
    % Interpreter property available since Matlab 2023b
    if ~verLessThan('matlab', '9.15')
        h.Interpreter                               = 'latex';
    end
    % CellLabel Format with width of 6 signs
    h.CellLabelFormat                               = '%.2f';
    % h.Title                                         = 'Relative Deviation $\Delta$Hs = $Hs_{insitu}$ - $Hs_{wam}$ [m]';
    h.Title                                         =  ['Relative Deviation: $(1-\frac{Hs_{WAM}}{Hs_{insitu}})*100$ [$\%$]'];
    warning off
    set(struct(h).Axes.Title,'FontSize',fsTitle)

    %% ------ Axes settings ------
    axs                                             = struct(gca);
    warning on
    axs.Colorbar.Limits                             = yLims;
    axs.Colorbar.Ticks                              = [linspace(yLims(1),yLims(2),5)];
    axs.NodeChildren(3).XAxis.TickLabelInterpreter  = 'latex';
    axs.NodeChildren(3).YAxis.TickLabelInterpreter  = 'latex';
    axs.NodeChildren(3).Title.Interpreter           = 'latex';
    axs.NodeChildren(2).TickLabelInterpreter        = 'latex';
    axs.NodeChildren(1).TickLabelInterpreter        = 'latex';
    axs.Axes.Title.FontSize                         = fsTitle;
    clim(yLims)

    pause(0.01)

    if axs.XAxis.TickLabelRotation > 0
        axs.XAxis.TickLabelRotation                   = 90;
    end

elseif strcmpi(plotType,'barplot')
    ax                                          = gca;
    hold on
    ax.Color                                    = backGroundColor;
    ax.FontSize                                 = fsAxis;
    ax.YGrid                                    = 'on';
    ax.XGrid                                    = 'off';
    ax.YLim                                     = [yLims(1),yLims(end)];
    ax.YTick                                    = linspace(yLims(1),yLims(end),5);
    ax.GridColor                                = gridColor;
    ax.XLabel.Interpreter                       = 'latex';
    ax.XAxis.TickLabelInterpreter               = 'latex';
    ax.YLabel.Interpreter                       = 'latex';
    ax.YAxis.TickLabelInterpreter               = 'latex';
    ax.TickDir                                  = 'none';
    ax.Title.String                             = ['Relative Deviation: $(1-\frac{Hs_{WAM}}{Hs_{insitu}})*100$ [$\%$]'];
    ax.Title.FontSize                           = fsTitle;
    % Array CM <-> deltaLims
    cmDelta                                     = linspace(yLims(1),yLims(end),size(cmAdj,1))';
    cmDeltaLength                               = numel(cmDelta);


    %% ------ Barplot: Loop over every site  -----
    for j = 1:numel(validSiteNames)
        currSite                                = validSiteNames(j);
        currDelta                               = sitePercentages(j);

        % Identify current face color 
        if currDelta < 0
            [~,currClosesIdx]                   = min( abs(currDelta-cmDelta(1:round(cmDeltaLength/2))) );
        elseif currDelta >= 0
            [~,currClosesIdx]                   = min( abs(currDelta-cmDelta(round(cmDeltaLength/2)+1:end)) );
            currClosesIdx                       = round(cmDeltaLength/2) + currClosesIdx;
        end

        currColor                               = cmAdj(currClosesIdx,:);

        bp                                      = bar(ax,categorical(currSite),currDelta);

        % Barplot settings
        bp(1).FaceColor                         = currColor;
        bp(1).LineWidth                         = lwBar;
        bp(1).EdgeColor                         = edgeColor;
    end

    % Show 2 decimals for each yTick
    ax.YTickLabel                               = arrayfun(@(x) sprintf('%.2f',ax.YTick(x)),1:numel(ax.YTick),'UniformOutput',false);

    ax.Colormap                                 = cmAdj;
    colorbar(ax,'Limits',yLims)
    clim(yLims)

    if ax.XTickLabelRotation > 0
    ax.XTickLabelRotation                       = 90;
    end
end


end