clear, clc, close all

% Set Paths
logPath = 'C:\Users\LuFI_LF\seadrive_root\froehlin\Meine Bibliotheken\output_Seegangsmodul\50_logEvaluation_2023-10-12/';
cmPath = 'C:\Users\LuFI_LF\seadrive_root\froehlin\Meine Bibliotheken\GitLab\Seegangsmodul\10_inputFiles\40_colormaps';
figurePath = 'C:\Users\LuFI_LF\seadrive_root\froehlin\Meine Bibliotheken\Evaluation_LogFiles\30_figures';
% Fontsize
FS = 20;
% Amount colors Colormap
nColors = 15;

% Load colormap
addpath(cmPath)
load vik.mat

warning off

% list all log files
logDateien = dir([logPath, '*.out']);

timeDelta = table;

% Start loop over all log files
for i = 1:numel(logDateien)
    % file path to current file
    logDateiPfad = fullfile(logPath, logDateien(i).name);

    % Open current file
    logDatei = fopen(logDateiPfad, 'r');


    % read every line of current file
    while ~feof(logDatei)
        zeile = fgetl(logDatei);

        % Current time
        if contains(zeile, 'Current time (UTC):')
            timeStart = strfind(zeile,'(UTC):');
            currentUTC = datetime(zeile(timeStart+6:end), 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
            timeDelta.execTime(i) = currentUTC;
        end

        % Suchen Sie nach dem Zeitstempel
        if contains(zeile, 'Seastate map creation for UTC time:')
            timeStart = strfind(zeile,'UTC time:');
            seastateCreationUTC = datetime(zeile(timeStart+9:end), 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
            timeDelta.time2Eval(i) = seastateCreationUTC;
            % Calculate timeshift between execution time and time2eval
            timeDelta.timeShift(i) = timeDelta.execTime(i) - timeDelta.time2Eval(i);
        end

        % Identify delta information
        if contains(zeile, 'Diff. to time2Eval:')
            [siteStr, minutesStr] = strtok(zeile, ':');
            [site,sensor] = strtok(siteStr,' ');
            strStart = strfind(minutesStr, 'time2Eval:');
            strStart = strStart + 10; % time2Eval: hat Länge 10
            strEnd = strfind(minutesStr, 'Minutes');
            strEnd = strEnd - 1;
            delta = str2double(minutesStr(strStart:strEnd));
            timeDelta.([site,'_Sensor']){i} = sensor;
            timeDelta.([site,'_Delta'])(i) = delta;
            timeDelta.([site,'_Delta2ExecTime'])(i) = minutes(timeDelta.timeShift(i) - minutes(delta));
        elseif contains(zeile,'No data available.')
            [siteStr, minutesStr] = strtok(zeile, ':');
            [site,sensor] = strtok(siteStr,' ');
            timeDelta.([site,'_Sensor']){i} = sensor;
            timeDelta.([site,'_Delta'])(i) = NaN;
            timeDelta.([site,'_Delta2ExecTime'])(i) = NaN;
        end

       
    end
    
    % Close log file
    fclose(logDatei);
 
end

%% :::::::::| Plot probabilities |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% Define thresholds in minutes
minThresh = [30,60,90,120,150];
% Number timesteps
nTimes  = length(timeDelta.execTime);
startTime = datestr(timeDelta.execTime(1),'yyyy-mm-dd');
endTime = datestr(timeDelta.execTime(end),'yyyy-mm-dd');

varNames = timeDelta.Properties.VariableNames;
searchStr = 'Delta2ExecTime';
matchingIdx = find( cellfun(@(name) ~isempty(regexp(name, searchStr, 'once')), varNames) );

siteProbs = table;

for j = matchingIdx
    currSite = varNames{j}(1:3);
    currDelta = timeDelta.(varNames{j});
    for k = 1:length(minThresh)
        currProbIdx = currDelta < minThresh(k);
        siteProbs.(currSite)(k) = sum(currProbIdx) / nTimes * 100;
    end
end

h = heatmap(siteProbs{:,:});
h.XDisplayLabels = siteProbs.Properties.VariableNames;
h.YDisplayLabels = strcat('\textless',string(minThresh));
h.YLabel = 'Time to most recent file in minutes';
h.Interpreter = 'latex';
h.FontSize = 24;
h.Title = ['Data availability [$\%$] between '  startTime ' - ' endTime ' (' num2str(nTimes) ' TS)'];
colormap("gray")

if 1
    exportgraphics(gcf,fullfile(figurePath,['fileAvailability_',startTime,'_',endTime,'.png']))
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

%% :::::::::| Plot heatmaps |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

varNames = timeDelta.Properties.VariableNames;
deltaIdx = contains(varNames,'Delta');
deltaNames = varNames(deltaIdx);
siteNames = strtok(deltaNames,'_');
time2evalVec = timeDelta.time2Eval;


for j = 1:numel(deltaNames)
    deltaMtx(j,:) = timeDelta.(deltaNames{j});
end

maxDelta = max(abs(deltaMtx),[],'all');
vikAdj = vik(round(linspace(1,256,nColors)),:);

figure(1),clf

h = heatmap(deltaMtx,'YDisplayLabels',siteNames);
h.Title = 'Difference: mostRecent site time - time2Eval (Blue: No data available / Red: Data available)';
hStr = struct(h);
hStr.Colorbar.Ticks = linspace(-maxDelta,maxDelta,nColors+1);
hStr.Colorbar.TickLabels = round(hStr.Colorbar.Ticks,2);
hStr.Colorbar.Label.String = 'Time delta in minutes';
ax = gca;
ax.FontSize = FS;
showTickIdx = round(linspace(1,numel(time2evalVec),21));
showtickCell = repmat({''},1,numel(time2evalVec));
% showtickCell(showTickIdx) = {''};
showtickCell(showTickIdx) = arrayfun(@(c) datestr(c,'mm/dd HH:MM'),time2evalVec(showTickIdx),'UniformOutput',false);
h.XDisplayLabels = showtickCell;



colormap(vikAdj)
clim([-maxDelta,maxDelta])

timeIn = datestr(time2evalVec(1),'yyyymmdd_HHMM');
timeOut = datestr(time2evalVec(end),'yyyymmdd_HHMM');
exportFileName = strcat(timeIn,'_',timeOut,'logfileHeatmap.png');
exportgraphics(gcf,fullfile(figurePath,exportFileName))


warning on

% clearvars -except timeDelta 