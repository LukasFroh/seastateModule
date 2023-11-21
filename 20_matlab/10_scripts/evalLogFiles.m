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
boolFig1        = 1;   % Data availability matrix

boolFig2        = 1;   % Temporal evolvement heatmap

boolFig3        = 1;   % Temporal evolvement with threshold
maxTimeDelta    = 600; % Choose upper limit (in minutes) for time delta for heatmap visualization for Fig2 & Fig3

boolFig4        = 1;   % Time series for chosen sites


boolSaveFig     = 1;   % Export figures?


% Choose sites that should be considered for Figure 4 (as cellstring)
fig4ChosenSites = {'ELB','FN1','FN3','AV0','BUD'};

% ++++++++ Figure Settings ++++++++
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
    % Deactive cell grid if more than X timesteps needs to be colorized
    gridThresh                  = 50;
    if length(time2evalVec) > gridThresh
        h.GridVisible = 'off';
    end

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

%% :::::::::| Figure 3: Temporal evolvement heatmap (only available/not available) |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if boolFig3

    % Search string for parameter names (Delta Execution time - mostRecentTime)
    searchStr       = 'Delta2ExecTime';
    % Idx for each var matching search string
    matchingIdx     = find( cellfun(@(name) ~isempty(regexp(name, searchStr, 'once')), varNames) );
    % Identify site names
    siteNames       = strtok(varNames(matchingIdx),'_');
    % Initialize counter 
    countDeltaMtx   = 0;
    % Colormap with only 2 colors
    cm2Colors       = linspecer(2,'sequential');

    % Loop to create matrix containing delta2ExecTime vars as rows for each site
    for j = matchingIdx
        countDeltaMtx = countDeltaMtx + 1;
        delta2ExecRowMtx(countDeltaMtx,:) = timeDelta.(varNames{j});
    end

    % Set color threshold to preDefinedMaxTimeDelta
    colorThresh = maxTimeDelta;

    % Set colorbar ticks
    deltaTicks = linspace(0,colorThresh*2,3);
    % Create colormap based on sequential linspecer
    % Open figure
    figure(3),clf
    % Create heatmap and adjust settings
    h                           = heatmap(delta2ExecRowMtx,'YDisplayLabels',siteNames);
    h.Title                     = ['Temporal evolvement of data availability  (' startTime ' - ' endTime ')'];
    h.Interpreter               = 'latex';
    h.Colormap                  = cm2Colors;
    hStr                        = struct(h);
    hStr.Colorbar.Label.String  = '$T_{Execution}$ -- $T_{VHM0~(latest)}~ [min]$';
    hStr.Colorbar.Label.Interpreter = 'latex';
    clim([0,colorThresh*2])
    hStr.Colorbar.Ticks = [0,colorThresh,deltaTicks(end)];
    hStr.Colorbar.TickLabels = round(hStr.Colorbar.Ticks,2);

    % Deactive cell grid if more than X timesteps needs to be colorized
    gridThresh                  = 50;
    if length(time2evalVec) > gridThresh
        h.GridVisible = 'off';
    end

    clim([deltaTicks(1),deltaTicks(end)])
    ax                          = gca;
    ax.FontSize                 = FS;
    showTickIdx                 = round(linspace(1,numel(time2evalVec),21));
    showtickCell                = repmat({''},1,numel(time2evalVec));
    showtickCell(showTickIdx)   = arrayfun(@(c) datestr(c,'mm/dd HH:MM'),time2evalVec(showTickIdx),'UniformOutput',false);
    h.XDisplayLabels            = showtickCell;

    if boolSaveFig
        exportgraphics(gcf,fullfile(figurePath,['TemporalEvolvement_2Colors_',startTime,'_',endTime,'.png']))
    end

end

%% :::::::::| Figure 4: Time series for chosen sites |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if boolFig2

    % <fig4ChosenSites> is predefined parameter
    % Search string for parameter names (Delta Execution time - mostRecentTime)
    searchStr       = 'Delta2ExecTime';
    % Idx for each var matching search string
    matchingIdx     = find( cellfun(@(name) ~isempty(regexp(name, searchStr, 'once')), varNames) );
    % Identify site names
    siteNames       = strtok(varNames(matchingIdx),'_');
    % Find index of chosen sites
    chosenSiteIdx   = find(ismember(siteNames,fig4ChosenSites));

    figure(4)
    tiledlayout('flow')
    for ci = 1:numel(chosenSiteIdx)
        nexttile
        currIdx     = matchingIdx(chosenSiteIdx(ci));
        currSite    = siteNames{chosenSiteIdx(ci)};
        ax          = gca;
        ax.FontSize = FS;
        plot(timeDelta.execTime,timeDelta{:,currIdx},'DisplayName',currSite,'LineWidth',1.5)
        ax.Title.String = currSite;
        ax.YLabel.String = 'delta2ExecTime [min]';
        ax.YLim     = ([0,maxTimeDelta]);

    end
    
    if boolSaveFig
        exportgraphics(gcf,fullfile(figurePath,['TimeSeries_ChosenSites_',startTime,'_',endTime,'.png']))
    end

end

%% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

warning on
