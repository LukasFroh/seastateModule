%% ###########################################################################################################################
%   repository: seastate module
%   author: ©Lukas Froehling (froehling@lufi.uni-hannover.de)
%   log-file evaluation:
%   - Data availability evaluation based on log-file output from seastate module.
%   - Access to repository (functions, colormaps) and log-file folder must be given.
%   Possible Output:
%   - Figure 1: Data availability matrix: Shows data availability in [%] for sites (defined in batch script) based on multiple defined time thresholds (Duration between Execution time and lates timestep in insida data)
%   - Figure 2: Heatmap depicting the temporal evolvement of the Time differences to most recent timestep in insida data.
%   - Figure 3: Heatmap for specific time tresholds. Green for timesteps with available data within limits, red for no available data.
%   - Figure 4: Timeseries of Duration to mostRecentTime in one figure with subplot for each site, respectively. Define therefore Cellstring for all sites that should be investigated
%  ###########################################################################################################################

clear
clc
close all

%% :::::::::| Input |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

% ++++++++ Path definition ++++++++
% Path logfiles
% logPath = 'C:\Users\LuFI_LF\seadrive_root\froehlin\Meine Bibliotheken\output_Seegangsmodul\50_logEvaluation_2023-10-12/';
logPath     = 'C:\Users\LuFI_LF\seadrive_root\froehlin\Meine Bibliotheken\Evaluation_LogFiles\10_data\20231114_10_logs\';
% Path colormaps
cmPath      = 'C:\Users\LuFI_LF\seadrive_root\froehlin\Meine Bibliotheken\GitLab\Seegangsmodul\10_inputFiles\40_colormaps';
addpath(genpath(cmPath))
% Path figure output
figurePath  = 'C:\Users\LuFI_LF\seadrive_root\froehlin\Meine Bibliotheken\Evaluation_LogFiles\30_figures';
% Path matlab function
fncPath     = 'C:\Users\LuFI_LF\OneDrive\LuFI\04_Projekte\03_OpenRAVE\45_Github\seastateModule\20_matlab\20_functions';
addpath(genpath(fncPath))

% ++++++++ Figure Bools ++++++++
% Which plots should be created and saved? Choose between true/false or 1/0
boolFig1    = 1;   % Data availability matrix

boolFig2    = 1;   % Temporal evolvement heatmap
maxTimeDelta = 300; % Choose upper limit (in minutes) for time delta for heatmap visualization

boolFig3    = 1;   % Temporal evolvement with threshold

boolFig4    = 1;   % Time series for chosen sites

boolSaveFig = 1;   % Export figures?


% Choose sites that should be considered for Figure 4 (as cellstring)
fig4ChosenSites = {'ELB','FN1','FN3'};

% ++++++++ Figure Settings ++++++++
% Load colormaps
load vik.mat
load bilbao.mat
% Fontsize
FS = 24;
% Amount colors Colormap
nColors = 10;

%% :::::::::| Read and extract log-file information |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
warning off

% list all log files
logDateien = dir([logPath, '*.out']);
% Initialize table
timeDelta = table;

% Start loop over all log files
for i = 1:numel(logDateien)

    % file path to current file
    logDateiPfad    = fullfile(logPath, logDateien(i).name);
    % Open current file
    logDatei        = fopen(logDateiPfad, 'r');

    % read every line of current file
    while ~feof(logDatei)
        zeile       = fgetl(logDatei);

        % Extract Execution time (Current time) from file
        if contains(zeile, 'Current time (UTC):')
            timeStart               = strfind(zeile,'(UTC):');
            currentUTC              = datetime(zeile(timeStart+6:end), 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
            timeDelta.execTime(i)   = currentUTC;
        end

        % Extract Evaluation time (Creation time) from file
        if contains(zeile, 'Seastate map creation for UTC time:')
            timeStart               = strfind(zeile,'UTC time:');
            seastateCreationUTC     = datetime(zeile(timeStart+9:end), 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
            timeDelta.time2Eval(i)  = seastateCreationUTC;
            % Calculate timeshift between execution time and time2eval
            timeDelta.timeShift(i)  = timeDelta.execTime(i) - timeDelta.time2Eval(i);
        end

        % Extract Difference to time2Eval from file
        if contains(zeile, 'Diff. to time2Eval:')
            [siteStr, minutesStr]   = strtok(zeile, ':');
            [site,sensor]           = strtok(siteStr,' ');
            strStart                = strfind(minutesStr, 'time2Eval:');
            strStart                = strStart + 10; % time2Eval: 10 digits
            strEnd                  = strfind(minutesStr, 'Minutes');
            strEnd                  = strEnd - 1;
            % Delta: mostRecent time - Evaluation time --> (positive: Up to date data available / negative: no up to date data available)
            delta                   = str2double(minutesStr(strStart:strEnd));
            timeDelta.([site,'_Sensor']){i}         = sensor;
            timeDelta.([site,'_Delta'])(i)          = delta;
            % Delta mostRecent timestamp to Execution time.
            timeDelta.([site,'_Delta2ExecTime'])(i) = minutes(timeDelta.timeShift(i) - minutes(delta));
            % In case current row contains No data available
        elseif contains(zeile,'No data available.')
            [siteStr, minutesStr]                   = strtok(zeile, ':');
            [site,sensor]                           = strtok(siteStr,' ');
            timeDelta.([site,'_Sensor']){i}         = sensor;
            timeDelta.([site,'_Delta'])(i)          = NaN;
            timeDelta.([site,'_Delta2ExecTime'])(i) = NaN;
        end

    end

    % Close log file
    fclose(logDatei);

end

%% Properties of imported data 
% Timestrings of start and end time
startTime       = datestr(timeDelta.execTime(1),'yyyy-mm-dd');
endTime         = datestr(timeDelta.execTime(end),'yyyy-mm-dd');
% Variable names in timeDelta table
varNames        = timeDelta.Properties.VariableNames;
% Datetime vector of all timesteps
time2evalVec    = timeDelta.time2Eval;

%% :::::::::| Figure 1: Data availability matrix |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if boolFig1

    % Define thresholds in minutes
    minThresh       = [30,60,90,120,150];
    % Number timesteps
    nTimes          = length(timeDelta.execTime);
    % Search string for parameter names (Delta Execution time - mostRecentTime)
    searchStr       = 'Delta2ExecTime';
    % Idx for each var matching search string
    matchingIdx     = find( cellfun(@(name) ~isempty(regexp(name, searchStr, 'once')), varNames) );
    % Initialize table
    siteProbs       = table;

    % Loop over all matching vars
    for j = matchingIdx
        % Current site and delta
        currSite    = varNames{j}(1:3);
        currDelta   = timeDelta.(varNames{j});
        % Loop over all time thresholds
        for k = 1:length(minThresh)
            % Idx for all delta below current threshold
            currProbIdx             = currDelta < minThresh(k);
            % Calculate probability
            siteProbs.(currSite)(k) = sum(currProbIdx) / nTimes * 100;
        end
    end

    % Create heamap and adjust settings
    h                   = heatmap(siteProbs{:,:});
    h.XDisplayLabels    = siteProbs.Properties.VariableNames;
    h.YDisplayLabels    = strcat('\textless',string(minThresh));
    h.YLabel            = '$T_{Execution}$ -- $T_{VHM0~(latest)}$';
    h.Interpreter       = 'latex';
    h.FontSize          = FS;
    h.Title             = ['Data availability [$\%$] between '  startTime ' - ' endTime ' (' num2str(nTimes) ' TS)'];
    colormap("gray")

    if boolSaveFig
        exportgraphics(gcf,fullfile(figurePath,['fileAvailability_',startTime,'_',endTime,'.png']))
    end

end

%% :::::::::| Figure 2: Temporal evolvement heatmap |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if boolFig2

    % Search string for parameter names (Delta Execution time - mostRecentTime)
    searchStr       = 'Delta2ExecTime';
    % Idx for each var matching search string
    matchingIdx     = find( cellfun(@(name) ~isempty(regexp(name, searchStr, 'once')), varNames) );
    % Identify site names
    siteNames       = strtok(varNames(matchingIdx),'_');
    % Initialize counter 
    countDeltaMtx = 0;
    % Loop to create matrix containing delta2ExecTime vars as rows for each site
    for j = matchingIdx
        countDeltaMtx = countDeltaMtx + 1;
        delta2ExecRowMtx(countDeltaMtx,:) = timeDelta.(varNames{j});
    end
    % Identify maximum delta and round it
    maxDelta = max(abs(delta2ExecRowMtx),[],'all');
    if maxDelta <= 1000
        maxDeltaRounded = ceil(maxDelta / 100) * 100;
    elseif maxDelta > 1000
        maxDeltaRounded = ceil(maxDelta / 1000) * 1000;
    end

    % Chosen upper limit smaller? 
    if maxDelta > maxTimeDelta
        deltaFinal = maxTimeDelta;
    else
        deltaFinal = maxDeltaRounded;
    end
    
    % Set colorbar ticks
    deltaTicks = linspace(0,deltaFinal,11);
    % Create colormap based on sequential linspecer
    cmAdj = linspecer(nColors,'sequential');
    % Open figure
    figure(2),clf
    % Create heatmap and adjust settings
    h                           = heatmap(delta2ExecRowMtx,'YDisplayLabels',siteNames);
    h.Title                     = ['Temporal evolvement of data availability  (' startTime ' - ' endTime ')'];
    h.Interpreter               = 'latex';
    hStr                        = struct(h);
    hStr.Colorbar.Ticks         = deltaTicks;
    hStr.Colorbar.TickLabels    = round(hStr.Colorbar.Ticks,2);
    hStr.Colorbar.Label.String  = '$T_{Execution}$ -- $T_{VHM0~(latest)}~ [min]$';
    hStr.Colorbar.Label.Interpreter = 'latex';
    clim([deltaTicks(1),deltaTicks(end)])
    ax                          = gca;
    ax.FontSize                 = FS;
    showTickIdx                 = round(linspace(1,numel(time2evalVec),21));
    showtickCell                = repmat({''},1,numel(time2evalVec));
    showtickCell(showTickIdx)   = arrayfun(@(c) datestr(c,'mm/dd HH:MM'),time2evalVec(showTickIdx),'UniformOutput',false);
    h.XDisplayLabels            = showtickCell;
    colormap(cmAdj)

    if boolSaveFig
        exportgraphics(gcf,fullfile(figurePath,['TemporalEvolvement_',startTime,'_',endTime,'.png']))
    end

end

%% :::::::::| Plot heatmaps |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

varNames = timeDelta.Properties.VariableNames;
deltaIdx = contains(varNames,'Delta');
deltaNames = varNames(deltaIdx);
siteNames = strtok(deltaNames,'_');
time2evalVec = timeDelta.time2Eval;

countDeltaMtx = 0;

% colormap containing only red and green
cmRG = linspecer(2,'sequential');


for j = 2:2:numel(deltaNames)
    countDeltaMtx = countDeltaMtx + 1;
    deltaMtx(countDeltaMtx,:) = timeDelta.(deltaNames{j});
end

maxDelta = max(abs(deltaMtx),[],'all');
% maxDelta = 120;

if maxDelta <= 1000
    maxDeltaRounded = ceil(maxDelta / 100) * 100;
elseif maxDelta > 1000
    maxDeltaRounded = ceil(maxDelta / 1000) * 1000;
end

% maxDeltaRounded = 120;
deltaTicks = linspace(0,maxDeltaRounded,11);

cmAdj = flipud(bilbao(round(linspace(1,256,nColors)),:));

figure(1),clf

h = heatmap(deltaMtx,'YDisplayLabels',siteNames(2:2:end));
h.Title = ['Delta2ExecutionTime ' startTime ' - ' endTime ];
h.Interpreter = 'latex';
hStr = struct(h);
hStr.Colorbar.Ticks = deltaTicks;
hStr.Colorbar.TickLabels = round(hStr.Colorbar.Ticks,2);
hStr.Colorbar.Label.String = 'Time delta in minutes';
ax = gca;
ax.FontSize = FS;
showTickIdx = round(linspace(1,numel(time2evalVec),21));
showtickCell = repmat({''},1,numel(time2evalVec));
% showtickCell(showTickIdx) = {''};
showtickCell(showTickIdx) = arrayfun(@(c) datestr(c,'mm/dd HH:MM'),time2evalVec(showTickIdx),'UniformOutput',false);
h.XDisplayLabels = showtickCell;
colormap(cmAdj)



timeIn = datestr(time2evalVec(1),'yyyymmdd_HHMM');
timeOut = datestr(time2evalVec(end),'yyyymmdd_HHMM');
exportFileName = strcat(timeIn,'_',timeOut,'logfileHeatmap.png');
exportgraphics(gcf,fullfile(figurePath,exportFileName))

%% :::::::::| Plot Availability threshold heatmap |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if 0
    colorThresh = 180;
    colormap(cmRG)
    clim([0,colorThresh*2])
    hStr.Colorbar.Ticks = [0,colorThresh,deltaTicks(end)];
    hStr.Colorbar.TickLabels = round(hStr.Colorbar.Ticks,2);
    h.Title = ['Availability for timeshift = ' num2str(colorThresh) 'min between ' startTime ' - ' endTime ];

    timeIn = datestr(time2evalVec(1),'yyyymmdd_HHMM');
    timeOut = datestr(time2evalVec(end),'yyyymmdd_HHMM');
    exportFileName = strcat(timeIn,'_',timeOut,'_AvailabilityThreshold_',num2str(colorThresh),'min.png');
    exportgraphics(gcf,fullfile(figurePath,exportFileName))
end
%% :::::::::| Plot FN1/FN3/ELB history |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
idx2Eval = [12,15,18];
siteNames2Eval = {'ELB','FN1','FN3'};
figure(5),clf
tiledlayout('flow')
% hold on
for jj=1:numel(idx2Eval)
    nexttile
    plot(timeDelta.execTime,timeDelta{:,idx2Eval(jj)},'DisplayName',siteNames2Eval{jj})
    ylabel('Time2MostRecentFile [min]')
    title(siteNames2Eval{jj})
    ylim([0,300])
end

if 1
    exportgraphics(gcf,fullfile(figurePath,['timeHistoryAvailability_',startTime,'_',endTime,'.png']))
end
warning on

% clearvars -except timeDelta