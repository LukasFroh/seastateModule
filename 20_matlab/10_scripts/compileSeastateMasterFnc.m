%% Compile master function into standalone .exe
% Script path
scriptPath  = 'C:\Users\LuFI_LF\OneDrive\LuFI\04_Projekte\03_OpenRAVE\45_Github\seastateModule\20_matlab\10_scripts';
% Function path
fnctPath    = 'C:\Users\LuFI_LF\OneDrive\LuFI\04_Projekte\03_OpenRAVE\45_Github\seastateModule\20_matlab\20_functions';
scriptName  = 'seastateMasterFnc.m';
% String formatting char("' ... '") mandatory due to blanks in path...
outputFolder = char("'C:\Users\LuFI_LF\OneDrive\LuFI\04_Projekte\03_OpenRAVE\45_Github\seastateModule\30_execution'");
outputName = 'seastateModule_v1_3';

% Change directory to script folder
cd(scriptPath)

% Restore search path to factory-installed state
restoredefaultpath
% % Add current paths
addpath(fnctPath)

eval(['mcc -mv ' scriptName ' -o ' outputName ' -d ' outputFolder])


