function siteData = OR_CalculateScaleData(siteData,interpLineLength,var2ScaleLive,var2ScaleWam)


% SiteNames
siteNames                                               = {siteData(:).name};

% Identify site names
if iscell(siteData(1).name)
    siteNames       = [siteData(:).name];
elseif ischar(siteData(1).name)
    siteNames       = {siteData(:).name};
end

% Initialize counter
counter                                                 = 0;

liveVar                                                 = var2ScaleLive{:};
wamVar                                                  = var2ScaleWam{:};

%% :::::::::| Identify connection sites |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

% First loop to identify missing data sites (either wam or live)
for j = 1:numel(siteNames)
    % Current site
    currSite                                            = siteNames{j};
    % Create missingIdx for site in case no data is available
    if isempty(siteData(j).finalLiveData) || isempty(siteData(j).extractedWAMData)
        counter                                         = counter + 1;
        missingIdx(counter)                             = j;
    end
end

% Second loop to calculate scaleData for valid sites
for i = 1:numel(siteNames)

    % Skip looping var if no data is available
    if isempty(siteData(i).finalLiveData) || isempty(siteData(i).extractedWAMData)
        continue
    end

    % Current site
    currSite                                            = siteNames{i};

    % Create new scale struct
    siteData(i).scaleData                               = struct;

    siteData(i).scaleData.liveVar                       = liveVar;
    siteData(i).scaleData.wamVar                        = wamVar;

    % Calculate scale and absolute delta
    siteData(i).scaleData.scale                         = siteData(i).finalLiveData.(liveVar) ./ siteData(i).extractedWAMData.(wamVar);
    siteData(i).scaleData.delta                         = siteData(i).finalLiveData.(liveVar) - siteData(i).extractedWAMData.(wamVar);

    % Create cellstring containing all sites for connection lines
    siteData(i).scaleData.connectionSites               = siteNames;

    %% _______________- Manual connection site exlusion-____________________________________________________________________________________________
    switch currSite
        case 'FN3'
            siteData(i).scaleData.excludeSitesIDX       = find(ismember(siteNames,{currSite,'WES','LTH','HEO','ELB','NOR','HEL'}));
        case 'BUD'
            siteData(i).scaleData.excludeSitesIDX       = find(ismember(siteNames,{currSite,'DBU','ELB','NOR','HEL'}));
        case 'WES'
            siteData(i).scaleData.excludeSitesIDX       = find(ismember(siteNames,{currSite,'DBU','ELB','FN1','NO1','AV0','HEL','NOR'}));
        case 'NOO'
            siteData(i).scaleData.excludeSitesIDX       = find(ismember(siteNames,{currSite,'ELB','NOR','HEL'}));
        case 'LTH'
            siteData(i).scaleData.excludeSitesIDX       = find(ismember(siteNames,{currSite,'DBU','ELB','NOR','FN3'}));
        case 'HEO'
            siteData(i).scaleData.excludeSitesIDX       = find(ismember(siteNames,{currSite,'DBU','FN3','FN1','NO1','AV0','AVF','NOR'}));
        case 'HEL'
            siteData(i).scaleData.excludeSitesIDX       = find(ismember(siteNames,{currSite,'NOO','WES','FN3','BUD','DBU','NOR'}));
        case 'ELB'
            siteData(i).scaleData.excludeSitesIDX       = find(ismember(siteNames,{currSite,'DBU','LTH','WES','FN3','ELB','NOO'}));
        case 'NOR'
            siteData(i).scaleData.excludeSitesIDX       = find(ismember(siteNames,{currSite,'DBU','LTH','BUD','FN1','AV0','AVF','NO1','HEO','BUH','FN3','NOO','WES','HEL'}));
        case 'NO1'
            siteData(i).scaleData.excludeSitesIDX       = find(ismember(siteNames,{currSite,'WES','HEO','NOR'}));
        case 'AV0'
            siteData(i).scaleData.excludeSitesIDX       = find(ismember(siteNames,{currSite,'WES','HEO','NOR'}));
        case 'AVF'
            siteData(i).scaleData.excludeSitesIDX       = find(ismember(siteNames,{currSite,'WES','HEO','NOR'}));
        case 'FN1'
            siteData(i).scaleData.excludeSitesIDX       = find(ismember(siteNames,{currSite,'BUH','WES','HEO','NOR'}));
        case 'DBU'
            siteData(i).scaleData.excludeSitesIDX       = find(ismember(siteNames,{currSite,'BUH','ELB','LTH','BUD','HEL','HEO','NO1','WES','NOR','HEL'}));
        case 'BO1'
            siteData(i).scaleData.excludeSitesIDX       = find(ismember(siteNames,{currSite,'BUH','ELB','LTH','BUD','HEL','HEO','NO1','WES','NOR','HEL'}));
        case 'BUH'
            siteData(i).scaleData.excludeSitesIDX       = find(ismember(siteNames,{currSite,'NOR','FN3','HEL','LTH','ELB'}));
    end

    % Create empty array in case variable missingIdx does not exist
    if ~exist('missingIdx','var')
        missingIdx = [];
    end

    siteData(i).scaleData.excludeSitesIDX               = [siteData(i).scaleData.excludeSitesIDX, missingIdx];
    siteData(i).scaleData.excludeSitesIDX               = unique(siteData(i).scaleData.excludeSitesIDX);

    % Exclude sites
    siteData(i).scaleData.connectionSites(siteData(i).scaleData.excludeSitesIDX) = [];

end

%% :::::::::| Creation of interpolation line structs |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

for j = 1:numel(siteNames)
    % Initialize adjustment counter for k
    adjCounter                                              = 0;

    % Skip current loopingVar if scaleData is empty
    if isempty(siteData(j).scaleData)
        continue
    end

    % Set current scale vector
    currScaleSite                                       = siteData(j).scaleData.scale;

    % Create struct connectionLines
    siteData(j).connectionLines                         = struct;

    % Loop over all connection sites for each current site, respectively
    for k = 1:numel(siteData(j).scaleData.connectionSites)
        % Name of current connectionSite
        currConnectionSite                              = siteData(j).scaleData.connectionSites{k};
        % Idx of current connectionSite in siteData struct
        cCS                                             = find(strcmp(siteNames,currConnectionSite));

        % Skip scaleLineMatrix creation if currConnectionSite is empty (matrix is 1-based)
        if all(isnan(siteData(cCS).scaleData.scale)) || all(isnan(currScaleSite))
            % Create adjustement counter to substract from looping index k
            adjCounter                                  = adjCounter + 1;
            continue
        end

        % Set current Distance, Lon, Lat and Timelength
        currDist                                        = lldistkm( [siteData(j).lat, siteData(j).lon], [siteData(cCS).lat, siteData(cCS).lon] );

        % In case currDist is smaller than 2, increase it to 2. Otherwise no vector can be created
        if currDist < 2
            usedCurrDist                                = 2;
        else
            usedCurrDist                                = currDist;
        end

        currLon                                         = linspace( siteData(j).lon, siteData(cCS).lon, round( usedCurrDist * interpLineLength ) );
        currLat                                         = linspace( siteData(j).lat, siteData(cCS).lat, round( usedCurrDist * interpLineLength ) );
        currTimeLength                                  = numel(siteData(j).time);

        % Set siteName in struct
        siteData(j).connectionLines(k-adjCounter).connectionSite   = currConnectionSite;

        % Set timeVector in struct
        siteData(j).connectionLines(k-adjCounter).lengthTimeVec    = currTimeLength;
        % Set distance to connectionSite in struct
        siteData(j).connectionLines(k-adjCounter).distance2Site    = currDist;
        % Set "used" distance to connectionSite in struct
        siteData(j).connectionLines(k-adjCounter).usedDistance2Site = usedCurrDist;
        % Set vector with lon values of connection line in struct
        siteData(j).connectionLines(k-adjCounter).lonLine2Site     = currLon;
        % Set vector with lat values of connection line in struct
        siteData(j).connectionLines(k-adjCounter).latLine2Site     = currLat;

        % Initialize scaleLineMatrix | rows -> Time, columns -> lineSegments
        siteData(j).connectionLines(k-adjCounter).interpTimeMTX    = ones( currTimeLength, numel(currLat) );

        % Scale vector of current connectionSite
        currScaleConnectionSite                     = siteData(cCS).scaleData.scale;
        % Set interpolationLineValues in Matrix with rows as time arrays for each timestep
        for m = 1:siteData(j).connectionLines(k-adjCounter).lengthTimeVec
            siteData(j).connectionLines(k-adjCounter).interpTimeMTX(m,:) = linspace( currScaleSite(m), currScaleConnectionSite(m), numel(currLat) );
        end
        % Identify nan values
        nanIdx                                      = find(isnan(siteData(j).connectionLines(k-adjCounter).interpTimeMTX));
        % Replace nan values with 1
        siteData(j).connectionLines(k-adjCounter).interpTimeMTX(nanIdx) = 1;

    end

    % Delete connectionLines field for current j-loop if no entries were created
    if isempty(fieldnames(siteData(j).connectionLines))
        siteData(j).connectionLines = [];
    end

end



end