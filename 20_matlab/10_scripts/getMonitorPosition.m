function getMonitorPosition(outPath)

% Convert input parameter
eval(['outPath = char(' outPath ');']);

%% Identify monitor output settings
fig = figure('Visible','off');
% Maximize figure
set(fig,'units','normalized','outerposition',[0 0 1 1])

% Start diary function
logFileName = 'MonitorPosition.out';
cd(outPath)
diary(logFileName)

% Identify normalized/pixels/centimeters position 
fig.Units = 'normalized';
posNorm = fig.Position;
disp(['Figure position in <' fig.Units '>'])
disp(num2str(posNorm))

fig.Units = 'pixels';
posPix = fig.Position;
disp(['Figure position in <' fig.Units '>'])
disp(num2str(posPix))

fig.Units = 'centimeters';
posCM = fig.Position;
disp(['Figure position in <' fig.Units '>'])
disp(num2str(posCM))

diary off
close all

end
