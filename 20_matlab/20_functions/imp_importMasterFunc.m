function [data] = imp_importMasterFunc(paths,input,bools)

% Initialize struct
data                    = struct('name',{},'lat',{},'lon',{},'depth',{},'time',{},'dwr',{},'radac',{},'radacSingle',{},'finalSensorTT',{});

% Counter for most recent time (mrt)
mrtCounter              = 0;
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
           [data(i).dwr.hisFileList, data(i).dwr.hisLatestTime] = imp_createFileList(input,currDataPath,'*HIS*');
           % Increase counter
           mrtCounter = mrtCounter + 1;
           latestTime(mrtCounter) = data(i).dwr.hisLatestTime;
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
            [data(i).dwr.hiwFileList, data(i).dwr.hiwLatestTime] = imp_createFileList(input,currDataPath,'*HIW*');
            % Increase counter
            mrtCounter = mrtCounter + 1;
            latestTime(mrtCounter) = data(i).dwr.hiwLatestTime;
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
            [data(i).dwr.gpsFileList, data(i).dwr.gpsLatestTime] = imp_createFileList(input,currDataPath,'*GPS*');
            % Increase counter
            mrtCounter = mrtCounter + 1;
            latestTime(mrtCounter) = data(i).dwr.gpsLatestTime;
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
            [data(i).radac.fileList, data(i).radac.radacLatestTime] = imp_createFileList(input,currDataPath,'');
            % Increase counter
            mrtCounter = mrtCounter + 1;
            latestTime(mrtCounter) = data(i).radac.radacLatestTime;
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
            [data(i).radacSingle.fileList, data(i).radacSingle.radacSingleLatestTime]    = imp_createFileList(input,currDataPath,'');
            % Increase counter
            mrtCounter = mrtCounter + 1;
            latestTime(mrtCounter) = data(i).radacSingle.radacSingleLatestTime;
            % Import, clean and interpolate data
            [data(i).radacSingle.raw, data(i).radacSingle.cleaned, data(i).finalSensorTT.('radacSingle')] = ...
                imp_importCleanInterpSeastateData(data(i).radacSingle.fileList,paths.headerPath,input);
        end
    end

    % Set most recent time
    data(i).timeMostRecent = max(latestTime);
    clear latestTime
    mrtCounter = 0;

end


%% ___ Create "finalLiveData" ______________
% Name of struct with all interpoalted sensor timetables
finalSensorStructName   = 'finalSensorTT';
% Name of final timetable containing all interpolated metOcean data
finalTTName             = 'finalLiveData';
% Priority DWR > RADAC > RADAC_Single for final timetable
data = imp_convertAllInsituData2OneTable(data,finalSensorStructName,finalTTName);


end