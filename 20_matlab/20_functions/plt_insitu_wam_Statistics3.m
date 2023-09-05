function [ax2,ax3,ax4] = plt_insitu_wam_Statistics3(backGroundColor,fsAxis,validSiteNames,insituVars,wamVars,siteDeltas,siteDeltasProz,wamColors,insituColors,textColorInsitu)


% What to do?
% BackGround: White (or gray?)
% Bars Hs in black/grey for insitu/wam
% Implement 4 scales: [0,2], [0,4], [0,6], [0,8], [0,10]
% Absolute and prozentuale Abweichungen
% Abs/Proz als Bar Plot oder Heatmap

% set(gcf,'Visible','on')


%% ------ Identify Hs limits for y-axis -----
maxVar  = max([insituVars,wamVars]);
nTicks  = 5;

if maxVar < 2
    varYTicks = linspace(0,2,nTicks);
elseif maxVar >= 2 & maxVar < 4
    varYTicks = linspace(0,4,nTicks);
elseif maxVar >= 4 & maxVar < 6
    varYTicks = linspace(0,6,nTicks);
elseif maxVar >= 6 & maxVar < 8
    varYTicks = linspace(0,8,nTicks);
elseif maxVar >= 8
    varYTicks = linspace(0,10,nTicks);
end


gridColor = [0,0,0];


%% ------ Axes settings Hs barplot insitu/wam -----
nexttile
ax2                                         = gca;
hold on
ax2.Color                                   = backGroundColor;
ax2.FontSize                                = fsAxis;
ax2.YGrid                                   = 'on';
ax2.YLim                                    = [varYTicks(1),varYTicks(end)];
ax2.YTick                                   = varYTicks;
ax2.GridColor                               = gridColor;
ax2.XLabel.Interpreter                      = 'latex';
ax2.XAxis.TickLabelInterpreter              = 'latex';
ax2.YLabel.Interpreter                      = 'latex';
ax2.YAxis.TickLabelInterpreter              = 'latex';

%% ------ Axes settings Absolute Hs differences -----
nexttile
ax3                                         = gca;
hold on
ax3.Color                                   = backgroundColor;
ax3.FontSize                                = fsAxis;
ax3.YGrid                                   = 'on';
ax3.GridColor                               = gridColor;
ax3.YLim                                    = [-maxDeltaLim, maxDeltaLim];
ax3.YTick                                   = round(linspace(-maxDeltaLim, maxDeltaLim,5),2);
ax3.XLabel.Interpreter                      = 'latex';
ax3.XAxis.TickLabelInterpreter              = 'latex';
ax3.YLabel.Interpreter                      = 'latex';
ax3.YAxis.TickLabelInterpreter              = 'latex';























%% -.-.-.-.-.-.-.-.-.-.-.-.-. Old Version -.-.-.-.-.-.-.-.-.--.-.-.-..-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.

% Fixed Limits for absolute and relative delta plots
% Y-axis limit for absolute delta:
absLim      = [-0.5, 0.5];
% Y-axis limit for relative delta:
relLim      = [-0.5, 0.5];
% Y-Limit for barplot of insitu/wam
measLim     = [0,10];
measTicks   = linspace(0,10,5);
% Line width for bars
lwBar       = 2;
% EdgeColors
edgeInsitu  = textColorInsitu(1,:);
edgeWam     = [1,1,1];

% Load colormap
load("vik.mat")
cm = vik;
% absCBIdx    = linspace(absLim(1),absLim(2),size(cm,1))';
% [~,idx] = min( abs( absCBIdx - 0.3 ) )


%% Site Overview with paramater values as bar plot
nexttile

% Axes settings
ax2 = gca;
hold on
ax2.Color                                   = backGroundColor;
ax2.FontSize                                = fsAxis;
ax2.YGrid                                   = 'on';
ax2.YLim                                    = measLim;
ax2.YTick                                   = measTicks;
ax2.GridColor                               = [1 1 1];
ax2.XLabel.Interpreter                      = 'latex';
ax2.XAxis.TickLabelInterpreter              = 'latex';
ax2.YLabel.Interpreter                      = 'latex';
ax2.YAxis.TickLabelInterpreter              = 'latex';
%% Site Overview with absolute deltas
nexttile
ax3 = gca;
hold on
ax3.Colormap                                = cm;
ax3.Color                                   = backGroundColor;
ax3.FontSize                                = fsAxis;
ax3.YGrid                                   = 'on';
ax3.GridColor                               = [1 1 1];
ax3.YLim                                    = absLim;
ax3.YTick                                   = round(linspace(absLim(1), absLim(2),5),2);
ax3.XLabel.Interpreter                      = 'latex';
ax3.XAxis.TickLabelInterpreter              = 'latex';
ax3.YLabel.Interpreter                      = 'latex';
ax3.YAxis.TickLabelInterpreter              = 'latex';
%% Site Overview with scale factors
nexttile
ax4 = gca;
hold on
ax4.Color                                   = backGroundColor;
ax4.FontSize                                = fsAxis;
ax4.YGrid                                   = 'on';
ax4.YLabel.String                           = ['$\frac{Hs_{insitu}}{Hs_{WAM}}$ [ ]'];
ax4.GridColor                               = [1 1 1];
ax4.YLim                                    = relLim;
ax4.YTick                                   = round(linspace(relLim(1), relLim(2),5),2);
ax4.XLabel.Interpreter                      = 'latex';
ax4.XAxis.TickLabelInterpreter              = 'latex';
ax4.YLabel.Interpreter                      = 'latex';
ax4.YAxis.TickLabelInterpreter              = 'latex';

% Loop over all valid Sites
for j = 1:numel(validSiteNames)
    currSite                                = validSiteNames(j);
    currLive                                = insituVars(j);
    currWam                                 = wamVars(j);
    currRel                                 = siteDeltasProz(j);
    currDelta                               = siteDeltas(j);

    bp                                      = bar(ax2,categorical(currSite),[currLive,currWam]);
    % Barplot settings
    % bp(1).FaceColor                         = [222,235,247]/255;
    bp(1).FaceColor                         = insituColors(j,:);
    bp(1).LineWidth                         = lwBar;
    bp(1).EdgeColor                         = edgeInsitu;
    % Barplot wamdata settings
    % bp(2).FaceColor                         = [49,130,189]/255;
    bp(2).FaceColor                         = wamColors(j,:);
    bp(2).LineWidth                         = lwBar;
    bp(2).EdgeColor                         = edgeWam;

    if currDelta > 0
        deltaColor                          = [0.8902, 0.2902, 0.2000];
    elseif currDelta < 0
        deltaColor                          = [0.5686, 0.8118, 0.3765];
    else
        deltaColor                          = [0 0 0];
    end

    delta                                   = bar(ax3,categorical(currSite),currDelta);
    delta.EdgeColor                         = [1 1 1];
    % delta.FaceColor                         = PlottingOpts.siteTextColor;
    delta.FaceColor                         = deltaColor;

    sc                                      = bar(ax4,categorical(currSite),currRel);
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
bpLeg                                       = bar(ax2, categorical(validSiteNames(1)), [0,0] ,'Visible','on');
bpLeg(1).FaceColor                          = 'none';
bpLeg(1).EdgeColor                          = edgeInsitu;
bpLeg(1).LineWidth                          = lwBar;
bpLeg(2).FaceColor                          = 'none';
bpLeg(2).EdgeColor                          = edgeWam;
bpLeg(2).LineWidth                          = lwBar;
leg1                                         = legend(ax2,bpLeg(1:2),{'Insitu','WAM'});
leg1.TextColor                               = [1 1 1];
leg1.Color                                   = backGroundColor;
leg1.LineWidth                               = 1;
leg1.Location                                = 'eastoutside';

% Round all yticklabels to 2 digits after decimal point
ax2.YTickLabel                               = arrayfun(@(x) sprintf('%.2f',ax2.YTick(x)),1:numel(ax2.YTick),'UniformOutput',false);
ax3.YTickLabel                               = arrayfun(@(x) sprintf('%.2f',ax3.YTick(x)),1:numel(ax3.YTick),'UniformOutput',false);
ax4.YTickLabel                               = arrayfun(@(x) sprintf('%.2f',ax4.YTick(x)),1:numel(ax4.YTick),'UniformOutput',false);

% Plot zero line for delta plot
yline(ax3,0,'Color',ax3.GridColor)


end