function ax = plt_insituWam_barPlot(backGroundColor,fsAxis,validSiteNames,insituVars,wamVars)

%% ------ Identify Hs limits for y-axis -----
maxVar  = max([insituVars,wamVars]);
nTicks  = 5;
fsTitle = fsAxis + 5;


if maxVar < 2
    varYTicks = linspace(0,2,nTicks);
elseif maxVar >= 2 && maxVar < 4
    varYTicks = linspace(0,4,nTicks);
elseif maxVar >= 4 && maxVar < 6
    varYTicks = linspace(0,6,nTicks);
elseif maxVar >= 6 && maxVar < 8
    varYTicks = linspace(0,8,nTicks);
elseif maxVar >= 8
    varYTicks = linspace(0,10,nTicks);
end


gridColor   = [0,0,0];

% FaceColor insitu
fcInsitu    = [0,0,0];
fcWam       = [0.5,0.5,0.5];
% Linewidth bars
lwBar       = 1;


%% ------ Axes settings Hs barplot insitu/wam -----
ax                                          = gca;
hold on
ax.Color                                    = backGroundColor;
ax.FontSize                                 = fsAxis;
ax.YGrid                                    = 'on';
ax.XGrid                                    = 'off';
ax.YLim                                     = [varYTicks(1),varYTicks(end)];
ax.YTick                                    = varYTicks;
ax.GridColor                                = gridColor;
ax.XLabel.Interpreter                       = 'latex';
ax.XAxis.TickLabelInterpreter               = 'latex';
ax.YLabel.Interpreter                       = 'latex';
ax.YAxis.TickLabelInterpreter               = 'latex';
ax.TickDir                                  = 'none';
ax.Title.String                             = 'Measured / Forecasted wave height Hs [m]';
ax.Title.FontSize                           = fsTitle;

%% ------ Barplot: Loop over every site  -----
for j = 1:numel(validSiteNames)
    currSite                                = validSiteNames(j);
    currLive                                = insituVars(j);
    currWam                                 = wamVars(j);

    bp                                      = bar(ax,categorical(currSite),[currLive,currWam]);
    % Barplot settings
    bp(1).FaceColor                         = fcInsitu;
    bp(1).LineWidth                         = lwBar;
    bp(2).EdgeColor                         = fcInsitu;

    % Barplot wamdata settings
    bp(2).FaceColor                         = fcWam;
    bp(2).LineWidth                         = lwBar;
    bp(2).EdgeColor                         = fcInsitu;

end

%% ------ Legend and further axes settings  -----

% Show 2 decimals for each yTick
ax.YTickLabel                               = arrayfun(@(x) sprintf('%.2f',ax.YTick(x)),1:numel(ax.YTick),'UniformOutput',false);

% Legend settings
bpLeg                                       = bar(ax, categorical(validSiteNames(1)), [0,0] ,'Visible','on');
bpLeg(1).FaceColor                          = bp(1).FaceColor;
bpLeg(1).EdgeColor                          = bp(1).EdgeColor;
bpLeg(1).LineWidth                          = lwBar;
bpLeg(2).FaceColor                          = bp(2).FaceColor;
bpLeg(2).EdgeColor                          = bp(2).EdgeColor;
bpLeg(2).LineWidth                          = lwBar;
leg1                                        = legend(ax,bpLeg(1:2),{'Insitu','WAM'});
leg1.TextColor                              = gridColor;
leg1.Color                                  = backGroundColor;
leg1.LineWidth                              = 1;
leg1.Location                               = 'eastoutside';

if ax.XTickLabelRotation > 0
    ax.XTickLabelRotation                   = 90;
end


end