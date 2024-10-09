%% ###########################################################################################################################
%   repository: seastate module
%   author: ©Lukas Froehling (froehling@lufi.uni-hannover.de)
%   Compile master function into standalone .exe
%  ###########################################################################################################################

clear
clc
close all

%% :::::::::| \/\/\/ Mandatory input below \/\/\/ |:::::::::::::::::::::::::::::::::::::::::::::::::::::::
% Base path
basePath    = '...';
% File name of output-file (*.exe)
outputName  = 'seastateModule_v1_6';
%  :::::::::| /\/\/\ Mandatory input above /\/\/\ |:::::::::::::::::::::::::::::::::::::::::::::::::::::::

%% :::::::::| Compilation (no input needed) |:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

% Script path
scriptPath  = fullfile(basePath,'20_matlab\10_scripts');
% Function path
fnctPath    = fullfile(basePath,'20_matlab\20_functions');
scriptName  = 'seastateMasterFnc.m';
% Output path for .exe
outputFolder    = fullfile(basePath,'30_execution');
% String formatting char("' ... '") mandatory due to blanks in path...
outputFolderStr = eval(['char("' char("'") outputFolder char("'") '")']);

% Change directory to script folder
cd(scriptPath)

% Restore search path to factory-installed state
restoredefaultpath
% % Add current paths
addpath(fnctPath)

% Execute concatenated compilation command
eval(['mcc -mv ' scriptName ' -o ' outputName ' -d ' outputFolderStr])

% Delete generated textfile (*.txt) output (includedSupportPackages, mccExcludedFiles, readme, requiredMCRProducts, unresolvedSymbols)?
if 1
    delete(fullfile(outputFolder,'*.txt'))
    delete(fullfile(outputFolder,'*.log'))
end

