%% Compile master function into standalone .exe
% Script path
scriptPath  = '...';
% Function path
scriptName  = 'getMonitorPosition.m';
% String formatting char("' ... '") mandatory due to blanks in path...
outputFolder = char("'...'");
outputName = 'MonitorPosition';

% Change directory to script folder
cd(scriptPath)
% Restore search path to factory-installed state
restoredefaultpath

eval(['mcc -mv ' scriptName ' -o ' outputName ' -d ' outputFolder])


