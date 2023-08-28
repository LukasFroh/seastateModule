%% Test seastateMasterFnc in Matlab Application

clear,clc,close all
restoredefaultpath

% dataPath            = char("{'C:\Users\LuFI_LF\OneDrive\LuFI\04_Projekte\03_OpenRAVE\30_Daten\00_NewStructure\'}");
dataPath            = char("{'C:\Users\LuFI_LF\OneDrive\LuFI\04_Projekte\03_OpenRAVE\30_Daten\01_dataTest\'}");
headerPath          = char("{'C:\Users\LuFI_LF\seadrive_root\froehlin\Meine Bibliotheken\GitLab\seegangsmodul\10_inputFiles\10_headerFiles\'}");
coastlinePath       = char("{'C:\Users\LuFI_LF\seadrive_root\froehlin\Meine Bibliotheken\GitLab\seegangsmodul\10_inputFiles\20_coastlineFiles\'}");
wamDataPath         = char("{'D:\OpenRAVE_DWD_WAM_Forecast\'}");
siteOverviewPath    = char("{'C:\Users\LuFI_LF\seadrive_root\froehlin\Meine Bibliotheken\GitLab\Seegangsmodul\10_inputFiles\30_siteOverview\'}");
logPath             = char("{'C:\Users\LuFI_LF\seadrive_root\froehlin\Meine Bibliotheken\output_Seegangsmodul\10_logs'}");
figPath             = char("{'C:\Users\LuFI_LF\seadrive_root\froehlin\Meine Bibliotheken\output_Seegangsmodul\20_figures'}");
expDataPath         = char("{'C:\Users\LuFI_LF\seadrive_root\froehlin\Meine Bibliotheken\output_Seegangsmodul\30_data'}");
cmPath              = char("{'C:\Users\LuFI_LF\seadrive_root\froehlin\Meine Bibliotheken\GitLab\Seegangsmodul\10_inputFiles\40_colormaps'}");
seastateVars2Eval   = char("{'VHM0'}");
minQF               = "1";
wamModel2Eval       = 'cwam';
wamVars             = char("{'sign_whight'}");
% site2Imp            = char("{'AV0', 'DBU','BUD', 'ELB', 'FN1', 'FN3', 'HEL', 'HEO', 'LTH', 'NO1', 'WES', 'NOR', 'NOO','BO1'}");

if strcmp(wamModel2Eval,'cwam')
    site2Imp        = char("{'AV0', 'BUD', 'ELB', 'FN1', 'FN3', 'HEL', 'HEO', 'LTH', 'NO1', 'NOR', 'NOO'}");
    latLimMin       = "53.2541695";
    latLimMax       = "55.2458344";
    lonLimMin       = "6.1736112";
    lonLimMax       = "8.9930553";
    rasterSizeLat   = "204";
    rasterSizeLon   = "240";
elseif strcmp(wamModel2Eval,'ewam')
    site2Imp        = char("{'AV0', 'DBU','BUD', 'ELB', 'FN1', 'FN3', 'HEL', 'HEO', 'LTH', 'NO1', 'NOR', 'NOO','BO1'}");
    latLimMin       = "53.25";
    latLimMax       = "55.25";
    lonLimMin       = "5.5";
    lonLimMax       = "9";
    rasterSizeLat   = "41";
    rasterSizeLon   = "36";
end

gshhgInputFile      = char("{'GSHHG.mat'}");
var2ScaleInsitu     = char("{'VHM0'}");
var2ScaleWam        = char("{'sign_whight'}");
interpLineLength    = "1";
cbType              = 'fixed';
pltType             = 'adjInfo';
figRes              = "150";
figType             = '.png';
cmName              = char("{'lipari'}");
cmFlip              = 'flip';
gridType            = 'on';
fsAxis              = "20";                  % Font size axes object
fsSites             = "14";                  % Font size site text
fsTitle             = "40";                  % Font size title
timeShift           = "24";

%% execution
% Add path to functions
addpath(genpath('C:\Users\LuFI_LF\seadrive_root\froehlin\Meine Bibliotheken\GitLab\Seegangsmodul\20_matlab'))

% Execution of master function
seastateMasterFnc(dataPath, headerPath, coastlinePath, wamDataPath, siteOverviewPath, logPath, figPath, expDataPath, cmPath, ... % Path input
    site2Imp, seastateVars2Eval, minQF,...                                                      % Seastate input
    wamModel2Eval, wamVars, ...                                                                 % WAM input
    latLimMin, latLimMax, lonLimMin, lonLimMax, rasterSizeLat, rasterSizeLon, ...               % Spatial settings
    gshhgInputFile, ...                                                                         % Coastline settings
    var2ScaleInsitu, var2ScaleWam, interpLineLength, ...                                        % Scale settings
    cbType, pltType, figRes, figType, gridType, cmName, cmFlip, fsAxis, fsSites, fsTitle, ...   % Plot settings
    timeShift )                                                                                 % Manual time shift in hours as double (only for LuFI testing purposes)
