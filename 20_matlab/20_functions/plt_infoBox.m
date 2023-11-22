function a = plt_infoBox(ax,input)

% Position: left, bottom, width, height
unit        = 'normalized';
ax.Units    = unit;
figPosX     = ax.Position(1);
figPosY     = ax.Position(2);
figWidth    = ax.Position(3);
figHeight   = ax.Position(4);

startWidth  = figWidth*0.51;
finWidth    = figWidth - startWidth;
wamModel    = upper(input.wamModel2Eval);
timeCreated = input.timeNow;
legFS       = input.fsAxis - 2;
str2Plot    = {['Insitu-data-adjusted ' wamModel ' Forecast'], ['Generated at ' datestr(timeCreated,'yyyy-mm-dd HH:MM') ' (UTC)']};
% Get actual position of axes with plotboxpos function
pos         = arrayfun(@plotboxpos, ax, 'uni', 0);
dim         = cellfun(@(x) x.*[1 1 1 0.5], pos, 'uni',0);
% Plot annotation
% a           = annotation('textbox',[figPosX + startWidth figPosY finWidth figHeight/20],'String', str2Plot,'FitBoxToText','on','BackgroundColor',[0.25,0.25,0.25],'EdgeColor',[.1,.1,.1],'Color',[1,1,1],'FontSize',legFS);
a           = annotation('textbox',dim{1},'String', str2Plot,'FitBoxToText','on','BackgroundColor',[0.25,0.25,0.25],'EdgeColor',[.1,.1,.1],'Color',[1,1,1],'FontSize',legFS,'VerticalAlignment','bottom','HorizontalAlignment','right');

% Set textbox position to bottom left corner
% Pause mandatory, since axes need update due to heatmap plots
% pause(0.5)
% a.Units       = unit;
% a.Position(2) = pos(2);
% a.Position(1) = pos(1) + pos(3) - a.Position(3);

end