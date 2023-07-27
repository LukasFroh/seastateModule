function [ax2,ax3,ax4] = plt_insitu_wam_Statistics(coastColor,fsAxis,maxVarLim,maxDeltaLim,siteData,maxScaleLim,validSitesIdx  )

%% Site Overview with paramater values as bar plot
nexttile

% Axes settings
ax2 = gca;
hold on
ax2.Color                                   = coastColor;
ax2.FontSize                                = fsAxis;
ax2.YGrid                                   = 'on';
ax2.YLim                                    = [0 maxVarLim];
ax2.YTick                                   = [0:1:maxVarLim];
ax2.GridColor                               = [1 1 1];
ax2.XLabel.Interpreter                      = 'latex';
ax2.XAxis.TickLabelInterpreter              = 'latex';
ax2.YLabel.Interpreter                      = 'latex';
ax2.YAxis.TickLabelInterpreter              = 'latex';
%% Site Overview with absolute deltas
nexttile
ax3 = gca;
hold on
ax3.Color                                   = coastColor;
ax3.FontSize                                = fsAxis;
ax3.YGrid                                   = 'on';
ax3.GridColor                               = [1 1 1];
ax3.YLim                                    = [-maxDeltaLim, maxDeltaLim];
ax3.YTick                                   = round(linspace(-maxDeltaLim, maxDeltaLim,5),2);
ax3.XLabel.Interpreter                      = 'latex';
ax3.XAxis.TickLabelInterpreter              = 'latex';
ax3.YLabel.Interpreter                      = 'latex';
ax3.YAxis.TickLabelInterpreter              = 'latex';
%% Site Overview with scale factors
nexttile
ax4 = gca;
hold on
ax4.Color                                   = coastColor;
ax4.FontSize                                = fsAxis;
ax4.YGrid                                   = 'on';
ax4.YLabel.String                           = ['$\frac{Hs_{insitu}}{Hs_{WAM}}$ [ ]'];
ax4.GridColor                               = [1 1 1];
ax4.YLim                                    = [0, maxScaleLim];
ax4.YTick                                   = 0:0.5:maxScaleLim;
ax4.XLabel.Interpreter                      = 'latex';
ax4.XAxis.TickLabelInterpreter              = 'latex';
ax4.YLabel.Interpreter                      = 'latex';
ax4.YAxis.TickLabelInterpreter              = 'latex';
% Loop over all valid Sites
for j = validSitesIdx
    currSite                                = siteData(j).name;
    currLat                                 = siteData(j).lat;
    currLon                                 = siteData(j).lon;
    currLiveVar                             = siteData(j).scaleData.liveVar;
    currWamVar                              = siteData(j).scaleData.wamVar;
    currLive                                = siteData(j).finalLiveData.(currLiveVar);
    currWam                                 = siteData(j).extractedWAMData.(currWamVar);
    currScale                               = siteData(j).scaleData.scale;
    currDelta                               = siteData(j).scaleData.delta;

    bp                                      = bar(ax2,categorical(currSite),[currLive,currWam]);
    % Barplot settings
    bp(1).FaceColor                         = [222,235,247]/255;
    bp(1).LineWidth                         = 1;
    bp(1).EdgeColor                         = [1 1 1];
    % Barplot wamdata settings
    bp(2).FaceColor                         = [49,130,189]/255;
    bp(2).LineWidth                         = 1;
    bp(2).EdgeColor                         = [1 1 1];

    if currDelta > 0
        deltaColor                          = [0.8902, 0.2902, 0.2000];
    elseif currDelta < 0
        deltaColor                          = [0.5686, 0.8118, 0.3765];
    else
        deltaColor                          = [0 0 0];
    end

    delta                                   = bar(ax3,categorical(currSite),currDelta);
    delta.EdgeColor                         = [1 1 1];
    %             delta.FaceColor                         = PlottingOpts.siteTextColor;
    delta.FaceColor                         = deltaColor;

    sc                                      = bar(ax4,categorical(currSite),currScale);
    sc.EdgeColor                            = [1 1 1];
    %             sc.FaceColor                            = PlottingOpts.siteTextColor;
    sc.FaceColor                            = deltaColor;
end

% Change Rotation to 90° if 0° does not fit
if ax2.XTickLabelRotation > 0
    ax2.XTickLabelRotation                  = 90;
end
if ax3.XTickLabelRotation > 0
    ax3.XTickLabelRotation                  = 90;
end
if ax4.XTickLabelRotation > 0
    ax4.XTickLabelRotation                  = 90;
end
ax2.YLabel.String                           = ['Hs [m]'];
ax2.YLabel.Interpreter                      = 'latex';
ax3.YLabel.String                           = ['$\Delta$Hs [m]'];

% Legend settings
leg1                                         = legend(ax2,bp(1:2),{'Insitu','WAM'});
leg1.TextColor                               = [1 1 1];
leg1.Color                                   = coastColor;
leg1.LineWidth                               = 1;
leg1.Location                                = 'eastoutside';

% Round all yticklabels to 2 digits after decimal point
ax2.YTickLabel                               = arrayfun(@(x) sprintf('%.2f',ax2.YTick(x)),1:numel(ax2.YTick),'UniformOutput',false);
ax3.YTickLabel                               = arrayfun(@(x) sprintf('%.2f',ax3.YTick(x)),1:numel(ax3.YTick),'UniformOutput',false);
ax4.YTickLabel                               = arrayfun(@(x) sprintf('%.2f',ax4.YTick(x)),1:numel(ax4.YTick),'UniformOutput',false);

% Plot zero line for delta plot
yline(ax3,0,'Color',ax3.GridColor)


end