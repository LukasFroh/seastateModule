function a = plt_infoBox(ax,input)

% Position: left, bottom, width, height
figPosX     = ax.Position(1);
figPosY     = ax.Position(2);
figWidth    = ax.Position(3);
figHeight   = ax.Position(4);

startWidth  = figWidth*0.51;
finWidth    = figWidth - startWidth;
wamModel    = upper(input.wamModel2Eval);
timeCreated = input.timeNow;
legFS       = input.fsSites;
str2Plot    = {['Insitu data adjusted ' wamModel ' Forecast'], ['Generated at ' datestr(timeCreated,'yyyy-mm-dd HH:MM') ' (UTC)']};
a           = annotation('textbox',[figPosX + startWidth figPosY finWidth figHeight/20],'String', str2Plot,'FitBoxToText','on','BackgroundColor',[0.25,0.25,0.25],'EdgeColor',[.1,.1,.1],'Color',[1,1,1],'FontSize',legFS);
% Set textbox position to bottom left corner
% Pause mandatory, since axes need update due to heatmap plots
pause(0.5)
a.Position(1) = ax.Position(1) + ax.Position(3) - a.Position(3);
a.Position(2) = ax.Position(2);

end