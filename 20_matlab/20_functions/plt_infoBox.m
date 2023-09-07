function plt_infoBox(ax,input)

% Position: left, bottom, width, height
figPosX     = ax.Position(1);
figPosY     = ax.Position(2);
figWidth    = ax.Position(3);
figHeight   = ax.Position(4);

startWidth  = figWidth*0.51;
finWidth    = figWidth - startWidth;
wamModel    = upper(input.wamModel2Eval);
timeCreated = input.timeNow;
% legFS       = fsSites;
str2Plot    = {['Insitu data adjusted DWD ' wamModel ' Forecast.'], ['Plot created at ' datestr(timeCreated,'yyyy-mm-dd HH:MM') ' (UTC)']};
annotation('textbox',[figPosX + startWidth figPosY finWidth figHeight/20],'String', str2Plot,'FitBoxToText','on','BackgroundColor',[0.25,0.25,0.25],'EdgeColor',[.1,.1,.1],'Color',[1,1,1])


end