function [data] = imp_importMasterFunc(paths,input,bools)

% Initialize struct
data                    = struct('name',{},'lat',{},'lon',{},'depth',{},'time',{},'dwr',{},'radac',{},'radacSingle',{},'finalSensorTT',{});

%% --- Loop over all sites ------------------------------------------

for i = 1:numel(input.site2imp)
    currSite            = input.site2imp{i};
    currSiteIdx         = find(strcmp(currSite,input.siteOverview.name));

    % Error if site doesn't exist
    if isempty(currSiteIdx)
        error('Chosen site does not exist!')
    end

    % Set general data for current site
    data(i).name        = input.siteOverview{currSiteIdx,"name"};
    data(i).lat         = input.siteOverview{currSiteIdx,"lat"};
    data(i).lon         = input.siteOverview{currSiteIdx,"lon"};
    data(i).depth       = input.siteOverview{currSiteIdx,"depth"};
    data(i).time        = input.time2Eval;

    %% ___ dwr ______________________________
    if input.siteOverview.dwr(currSiteIdx)
        % Current data path
        currDataPath        = fullfile(paths.dataPath,currSite,'dwr');

        % His data
        if bools.boolDwrHIS
            % Initialize struct
            if ~isfield(data(i),'dwr')
                data(i).dwr = struct;
            end
            % Create fileList for his data
            [data(i).dwr.hisFileList] = imp_createFileList(currDataPath,'*HIS*');
            % Import, clean and interpolate data
            [data(i).dwr.hisRaw, data(i).dwr.hisCleaned, data(i).finalSensorTT.('dwrHIS')] = ...
                imp_importCleanInterpSeastateData(data(i).dwr.hisFileList,paths.headerPath,input);
        end

        % HIW Data
        if bools.boolDwrHIW
            % Initialize struct
            if ~isfield(data(i),'dwr')
                data(i).dwr = struct;
            end
            % Create fileList for hiw data
            [data(i).dwr.hiwFileList] = imp_createFileList(currDataPath,'*HIW*');
            % Import, clean and interpolate data
            [data(i).dwr.hiwRaw, data(i).dwr.hiwCleaned, data(i).finalSensorTT.('dwrHIW')] = ...
                imp_importCleanInterpSeastateData(data(i).dwr.hiwFileList,paths.headerPath,input);
        end

        % GPS Data
        if bools.boolDwrGPS
            % Initialize struct
            if ~isfield(data(i),'dwr')
                data(i).dwr = struct;
            end
            % Create fileList for gps data
            [data(i).dwr.gpsFileList] = imp_createFileList(currDataPath,'*GPS*');
            % Import, clean and interpolate data
            [data(i).dwr.gpsRaw, data(i).dwr.gpsCleaned, data(i).finalSensorTT.('dwrGPS')] = ...
                imp_importCleanInterpSeastateData(data(i).dwr.gpsFileList,paths.headerPath,input);
        end
    end

    %% ___ radac ____________________________
    if input.siteOverview.radac(currSiteIdx)
        if bools.boolRadac
            currDataPath                    = fullfile(paths.dataPath,currSite,'radac');
            data(i).radac                   = struct;
            % Create fileList for radac data
            [data(i).radac.fileList] = imp_createFileList(currDataPath,'');
            % Import, clean and interpolate data
            [data(i).radac.raw, data(i).radac.cleaned, data(i).finalSensorTT.('radac')] = ...
                imp_importCleanInterpSeastateData(data(i).radac.fileList,paths.headerPath,input);
        end
    end

    %% ___ radacSingle ______________________
    if input.siteOverview.radacSingle(currSiteIdx)
        if bools.boolRadacSingle
            currDataPath                    = fullfile(paths.dataPath,currSite,'radacSingle');
            data(i).radacSingle             = struct;
            % Create fileList for radac data
            [data(i).radacSingle.fileList]    = imp_createFileList(currDataPath,'');
            % Import, clean and interpolate data
            [data(i).radacSingle.raw, data(i).radacSingle.cleaned, data(i).finalSensorTT.('radacSingle')] = ...
                imp_importCleanInterpSeastateData(data(i).radacSingle.fileList,paths.headerPath,input);
        end
    end
end


%% ___ Create "finalLiveData" ______________
% Name of struct with all interpoalted sensor timetables
finalSensorStructName   = 'finalSensorTT';
% Name of final timetable containing all interpolated metOcean data
finalTTName             = 'finalLiveData';
% Priority DWR > RADAC > RADAC_Single for final timetable
data = imp_convertAllInsituData2OneTable(input,data,finalSensorStructName,finalTTName);

for ii = 1:numel(input.site2imp)
    % Chosen Sensor
    cS = data(ii).chosenSensor;
    % For dwr sensors
    if strcmpi(cS,'dwr')
        
        % If no data is imported, set timeMostRecent to not a time NaT
        if isempty(data(ii).(cS).('hisCleaned'))
            data(ii).timeMostRecent = datetime(NaT,"TimeZone","UTC");
            continue
        end

        % Current cleaned dataset without nan values
        seastateVarIdx              = find(ismember(data(ii).(cS).('hisCleaned').Properties.VariableNames,input.seastateVars2Eval));
        currWOnanIdx                = find(all(~isnan(data(ii).(cS).('hisCleaned'){:,seastateVarIdx}),2));
        if ~isempty(currWOnanIdx)
            data(ii).timeMostRecent = data(ii).(cS).('hisCleaned').Time(currWOnanIdx(end));
        else
            data(ii).timeMostRecent = data(ii).(cS).('hisCleaned').Time(end);
        end
        
        % For radac and radacSingle
    elseif strcmpi(cS,'radac') || strcmpi(cS,'radacSingle')

        % If no data is imported, set timeMostRecent to not a time NaT
        if isempty(data(ii).(cS).('cleaned'))
            data(ii).timeMostRecent = datetime(NaT,"TimeZone","UTC");
            continue
        end

        % Current cleaned dataset without nan values
        seastateVarIdx              = find(ismember(data(ii).(cS).('cleaned').Properties.VariableNames,input.seastateVars2Eval));
        currWOnanIdx                = find(all(~isnan(data(ii).(cS).('cleaned'){:,seastateVarIdx}),2));
        if ~isempty(currWOnanIdx)
            data(ii).timeMostRecent = data(ii).(cS).('cleaned').Time(currWOnanIdx(end));
        else
            data(ii).timeMostRecent = data(ii).(cS).('cleaned').Time(end);
        end

    else
        % Set timeMostRecent to not a time NaT
        data(ii).timeMostRecent     = datetime(NaT,"TimeZone","UTC");

    end

end

end