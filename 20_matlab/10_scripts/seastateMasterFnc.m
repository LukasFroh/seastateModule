%% ###########################################################################################################################
%   repository: seastate module
%   author: ©Lukas Froehling (froehling@lufi.uni-hannover.de)
%   Master script
%  ###########################################################################################################################

function seastateMasterFnc(dataPath, headerPath, coastlinePath, wamDataPath, siteOverviewPath, logPath, figPath, expDataPath, cmPath, ... % Path input
    site2Imp, seastateVars2Eval, minQF,...                                                      % Seastate input
    wamModel2Eval, wamVars, ...                                                                 % WAM input
    latLimMin, latLimMax, lonLimMin, lonLimMax, rasterSizeLat, rasterSizeLon, ...               % Spatial settings
    gshhgInputFile, ...                                                                         % Coastline settings
    var2ScaleInsitu, var2ScaleWam, interpLineLength, ...                                        % Scale settings
    cbType, pltType, statType, figRes, figType, gridType, cmName, cmStatsName, cmFlip, fsAxis, fsSites, fsTitle, siteMarkerSize, ...   % Plot settings
    timeShift )                                                                                 % Manual time shift in hours as double (only for LuFI testing purposes)

tic

%% :::::::::| Structuring input vars in structs |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% Paths
eval(['paths.dataPath = char(' dataPath ');'])                  % Path to insitu data directory
eval(['paths.headerPath = char(' headerPath ');'])              % Path to header files
eval(['paths.coastlinePath = char(' coastlinePath ');'])        % Path to coastline data (GSHHG)
eval(['paths.wamDataPath = char(' wamDataPath ');'])            % Path to WAM raw data
eval(['paths.siteOverviewPath = char(' siteOverviewPath ');'])  % Path to siteOverview excel
eval(['paths.logPath = char(' logPath ');'])                    % Path to log files
eval(['paths.figPath = char(' figPath ');'])                    % Path to figure folder
eval(['paths.expDataPath = char(' expDataPath ');'])            % Path to export folder
eval(['paths.cmPath = char(' cmPath ');'])                      % Path to colormap folder
% Input
eval(['input.site2imp   =' site2Imp ';'])                       % Which insitu sites should be considered?
eval(['input.seastateVars2Eval =' seastateVars2Eval ';'])       % Which insitu seaste variable should be imported (as Cellstring, default: 'VHM0')
input.minQF             = str2double(minQF);                    % Minimum final quality flag for insitu seastate data (Default: 1)
input.wamModel2Eval     = wamModel2Eval;                        % Specify WAM dataset. Choose between <'cwam'> and <'ewam'>
eval(['input.wamVars    =' wamVars ';'])                        % Set wam variables that should be imported (Cellstring). Choose between {'energy_per','mean_wave_dir','sea_dir','sea_mean_per','sea_peak_per','sea_whight','sign_whight','swell_dir','swell_mean_per','swell_peak_per','swell_whight','wind_dir','wind_speed'}
input.latLim            = [str2double(latLimMin), str2double(latLimMax)]; % Set latitude boundaries as min/max vector
input.lonLim            = [str2double(lonLimMin), str2double(lonLimMax)]; % Set longitude boundaries as min/max vector
input.rasterSize        = [str2double(rasterSizeLon),str2double(rasterSizeLat)]; % Set latitude/longitude resolution

% GSHHG Coastline dataset. Choose between <'gshhs_c.b'> (crude), <'gshhs_l.b'> (low), <'gshhs_i.b'> (intermediate), <'gshhs_h.b'> (high), <'gshhs_f.b'> (full, default option)
% Wessel, P., & Smith, W. H. F. (1996). A global, self-consistent, hierarchical, high-resolution shoreline database. In Journal of Geophysical Research: Solid Earth (Vol. 101, Issue B4, pp. 8741–8743). American Geophysical Union (AGU). https://doi.org/10.1029/96jb00104
eval(['var2ScaleInsitu  =' var2ScaleInsitu ';'])
eval(['var2ScaleWam  =' var2ScaleWam ';'])
% eval(['interpLineLength =' interpLineLength ';'])
interpLineLength        = str2double(interpLineLength);
eval(['GSHHG.filename = char(' gshhgInputFile ');'])
figRes                  = str2double(figRes);
timeShift               = str2double(timeShift);
eval(['cmName = char(' cmName ');'])
eval(['cmStatsName = char(' cmStatsName ');'])
input.fsAxis            = str2double(fsAxis);                   % Font size axes object
input.fsSites           = str2double(fsSites);                  % Font size site text
input.fsTitle           = str2double(fsTitle);                  % Font size title
input.siteMarkerSize    = str2double(siteMarkerSize);           % Marker size for site indication

% Which insitu data should be imported and considered? Choose between <true> and <false>
bools.boolDwrHIS        = true;
bools.boolDwrHIW        = false;
bools.boolDwrGPS        = false;
bools.boolRadac         = true;
bools.boolRadacSingle   = true;

% Current date and time
tNow                    = datetime('now','TimeZone','UTC');
% Manual adjustment (newest files only up to 23:59 of day before)
tNowAdjusted            = tNow - hours(timeShift);
% Round time to nearest half hour at XX:15 or XX:45, whichever is closer
tNowShifted             = dateshift(tNowAdjusted,'start','hour');
% Evaluate at mid of measurement time window. DWR meas. duration 30min --> Either XX:15 or XX:45 (Radac is available every 1 min and can be chosen for this time as well)
if minute(tNowAdjusted) < 15
    tNowShifted         = tNowShifted - minutes(15);
elseif minute(tNowAdjusted) >= 15 && minute(tNowAdjusted) < 45
    tNowShifted         = tNowShifted + minutes(15);
elseif minute(tNowAdjusted) >= 45
    tNowShifted         = tNowShifted + minutes(45);
end

% Set times in input struct
input.dateIn            = datenum(tNowShifted);
input.dateOut           = datenum(tNowShifted);
input.timestep          = minutes(120);
input.time2Eval         = tNowShifted;
input.timeThresh        = 120;
input.interpMethod      = 'linear';
input.timeNow           = tNow;
% Set time threshold, from which warning for too high relative deviations are shown (in [%]);
input.warningThresh     = 150;

%% :::::::::| Initialize log file |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
logFileName             = strcat(datestr(tNowShifted,'yyyy_mm_dd_HH_MM_SS'),'_log.out');
cd(paths.logPath)
diary(logFileName)

%% :::::::::| Import insitu data |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% Import siteOverview csv
input.siteOverviewInit  = readtable(fullfile(paths.siteOverviewPath,'siteOverview.xlsx'));
input.validSiteIdx      = ismember(input.siteOverviewInit.name,input.site2imp);
input.siteOverview      = input.siteOverviewInit(input.validSiteIdx,:);

siteData                = imp_importMasterFunc(paths,input,bools);

% Check most recent file times
fileTimesMR             = [siteData(:).timeMostRecent];
mostRecentTime          = max(fileTimesMR);
disp(['Current time (UTC): ' datestr(tNow,'yyyy-mm-dd HH:MM:SS')])
disp(['Seastate map creation for UTC time: ',datestr(tNowShifted,'yyyy-mm-dd HH:MM:SS')])
% Display which WAM model is used
disp(['Chosen numerical forecast model: ' upper(input.wamModel2Eval) ])
timeGap                 = mostRecentTime - tNowShifted;

% Display which insitu sites are considered
disp([newline 'Following insitu sites are considered:'])
disp(input.site2imp)
notValidIdx = isnat(fileTimesMR) | fileTimesMR < tNowShifted;
if any(notValidIdx)
    disp('No valid data available for sites:')
    disp(input.site2imp(notValidIdx))
    disp('')
else
    disp('Valid data for all sites available.')
    disp('')
end

% Display most recent times for each site
disp(['Time to most recent insitu files: '])

for mri = 1:numel(siteData)
    currSite    = siteData(mri).name;
    currSensor  = siteData(mri).chosenSensor;
    currMRT     = siteData(mri).timeMostRecent;

    if isnat(currMRT)
        disp([currSite{:} ' (' currSensor '): No data available.'])
    else
        disp([currSite{:} ' (' currSensor '): ' datestr(currMRT,'yyyy-mm-dd HH:MM:SS') ' --> Diff. to time2Eval: ' num2str( minutes(currMRT-tNowShifted) ) ' Minutes.'])
    end

end

% Stop script and give error message in case now seastate data is available for the last 30 minutes
if timeGap < -duration(minutes(30))
    error(['Execution stopped. No insitu seastate data for the last 30 minutes available. Time to most recent insitu files: ' num2str(hours(timeGap)) 'h.' ])
end

%% :::::::::| Import GSHHG data |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% Load already imported GSHHG struct:
s                   = load(fullfile(paths.coastlinePath,GSHHG.filename));
% Name of imported struct;
sFN                 = fieldnames(s);
% Set GSHHG as struct name
GSHHG               = s.(sFN{1});

%% :::::::::| Import wam data |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% Create lon/lat vector and grid
input.evalLonVec    = linspace(input.lonLim(1),input.lonLim(end),input.rasterSize(1));
input.evalLatVec    = linspace(input.latLim(1),input.latLim(end),input.rasterSize(2));
[input.evalLonGrid,input.evalLatGrid]  = meshgrid(input.evalLonVec,input.evalLatVec);
% Import wam files
[spatialData.wamfileList,spatialData.gridData,spatialData.wamRawParameters,spatialData.wamInterpParameters] = wamImport(input,paths);

%% :::::::::| Extract site data from spatial dataset |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
for i = 1:numel(input.site2imp)
    siteData        = OR_extractSiteDataFromWAM(siteData,spatialData,i);
end

%% :::::::::| Calculate scale data |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% Calculate scale data for each site and connection lines with interpolated scale values
siteData            = OR_CalculateScaleData(siteData,interpLineLength,var2ScaleInsitu,var2ScaleWam);
% Calculate scale matrix for whole area
spatialData         = OR_CalculateScaleMatrix(spatialData,siteData,GSHHG);
% Create scaled griddata for chosen variable
spatialData         = OR_ScaleWAMdata(spatialData,var2ScaleWam);

%% :::::::::| Plot Seastate |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% Display plotting settings
disp([newline 'Chosen plotting settings:'])
disp(['Plot type: <', pltType, '>'])
disp(['Statistic type: <', statType '>'])
disp(['Parameter range: <', cbType, '>'])


% Plot Seastate map. Output based on plot type <pltType> and colorbar scaling <cbType> 
[lonGrid,latGrid,adjVarGrid,~] = plt_seastateModule(input,GSHHG,spatialData,siteData,pltType,statType,cbType,gridType,paths.cmPath,cmName,cmStatsName,cmFlip);

% Save figure
figName = [datestr(input.time2Eval,'yyyymmdd_HHMM'), '_seastate_', pltType, figType];
exportgraphics(gcf,fullfile(paths.figPath,figName),'Resolution',figRes)

%% :::::::::| Save output |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% Export adjusted spatial data
expData.date        = input.time2Eval;
expData.lonGrid     = lonGrid;
expData.latGrid     = latGrid;
expData.adjVarGrid  = adjVarGrid;
% Filename for export .mat file
expFileName         = [datestr(input.time2Eval,'yyyymmdd_HHMM'),'_data.mat'];
save(fullfile(paths.expDataPath,expFileName),"expData")

disp([newline 'File <', expFileName, '> exported.'])

close all

% Stop time tracking
disp(['Execution time: ' num2str(round(toc,2)) 's.'])

diary off

