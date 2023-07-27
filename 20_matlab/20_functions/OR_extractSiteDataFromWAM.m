function siteData = OR_extractSiteDataFromWAM(siteData,spatialData,di)

% Determine variables 2 extract
vars2extr                                   = {spatialData.wamInterpParameters(:).name};
% Initialize data matrix with nan values
extractedWAMDataMTX                         = nan(numel(siteData(di).time),numel(vars2extr));

% If site is within latitute and longitude boundaries, extract data
if siteData(di).lon > spatialData.gridData.evalLon(1) && siteData(di).lon < spatialData.gridData.evalLon(end) && ...
        siteData(di).lat > spatialData.gridData.evalLat(1) && siteData(di).lat < spatialData.gridData.evalLat(end)

    % Identify nearest WAM datapoint for current site
    [~,nearestLonIdx]                       = min( abs( spatialData.gridData.evalLon - siteData(di).lon  ) );
    [~,nearestLatIdx]                       = min( abs( spatialData.gridData.evalLat - siteData(di).lat  ) );

    % Intermediate Variable for struct with interp parameters
    currS                                   = spatialData.wamInterpParameters;
    % Intermediate Variables for vectors of lon, lat and time of current grid
    lonVec                                  = spatialData.gridData.evalLon;
    latVec                                  = spatialData.gridData.evalLat;
    timeVec                                 = spatialData.gridData.evalTimeNum;

    % Identify ranges of nearest idx + and - 1
    adjLonIdx                               = (nearestLonIdx-1 : nearestLonIdx+1);
    adjLatIdx                               = (nearestLatIdx-1 : nearestLatIdx+1);

    % Set adjusted vectors
    adjLonVec                               = lonVec(adjLonIdx);
    adjLatVec                               = latVec(adjLatIdx);
    adjTimeVec                              = timeVec(:);
    % Create ND grids for gridded interpolant
    % Check if only 1 timestep is available
    if numel(adjTimeVec) == 1
        % Artificially increase time steps by a second value for griddetInterpolabt
        adjTimeVec(2,1)                       = adjTimeVec + datenum(seconds(1));
    end

    [X1,X2,X3]                              = ndgrid(adjLonVec,adjLatVec,adjTimeVec);

    % Create finale lon and lat vectors for interpolation with length of time vector
    finLonVec                               = ones(numel(adjTimeVec),1) * siteData(di).lon;
    finLatVec                               = ones(numel(adjTimeVec),1) * siteData(di).lat;

    % Loop over all variables and extract data for current site
    for i = 1:numel(vars2extr)
        %% New (2022/09/29): Instead of taking the value of the nearest value, interpolate between the lon lat range of +-1 of this value with the help of griddedInterpolant
        % Grid of current interp parameter
        varGrid                             = currS(i).interp;
        % Set adjusted grids
        adjVarGrid                          = varGrid(adjLonIdx,adjLatIdx,:);
        
        % If only one timestep is available, inrease dimensions for gridded Interpolant
        if length(size(adjVarGrid)) < 3
            adjVarGrid(:,:,2)               = adjVarGrid;
        end
        
        % Create gridded interpolant for current var grid
        gridInterpObj                       = griddedInterpolant(X1,X2,X3,adjVarGrid);
       
        % Use only first entry if timestep was increased artifically
        if numel(timeVec) == 1
            extractedWAMDataMTX(:,i)            = gridInterpObj(finLonVec(1),finLatVec(1),adjTimeVec(1));
        else
            extractedWAMDataMTX(:,i)            = gridInterpObj(finLonVec,finLatVec,adjTimeVec);
        end

        % Old Method: Take only nearest value
        %         extractedWAMDataMTX(:,i)                = squeeze([spatialData.wamInterpParameters(i).interp(nearestLonIdx,nearestLatIdx,:)]);
    end

end

% Create timetable containing all data
siteData(di).extractedWAMData              = array2timetable(extractedWAMDataMTX,"RowTimes",spatialData.gridData.evalTime,'VariableNames',vars2extr);

end