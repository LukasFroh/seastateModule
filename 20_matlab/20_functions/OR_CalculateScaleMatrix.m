function spatialData = OR_CalculateScaleMatrix(spatialData,siteData,GSHHG)

%% :::::::::| Longitude and Latitude definition |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

% Longitude and latitude vectors
lonVec                          = spatialData.gridData.evalLon;
latVec                          = spatialData.gridData.evalLat;

% Limits
lonLim                          = [lonVec(1), lonVec(end)];
latLim                          = [latVec(1), latVec(end)];

% Griddata
latGrid                         = spatialData.gridData.evalLatGrid;
lonGrid                         = spatialData.gridData.evalLonGrid;
timeGrid                        = spatialData.gridData.evalTimeGrid;

% Number of Timesteps
nTS                             = size(timeGrid,3);
% Number of sites
nSites                          = numel(siteData);

%% :::::::::| Get boundary vectors |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

% Identify Idx of western and northern boundaries
boundIdx                        = find(latGrid(:,:,1) == latLim(2) | lonGrid(:,:,1) == lonLim(1));
% Latitude, longitude and scale vectors for boundaries
boundLat                        = latGrid(boundIdx);
boundLon                        = lonGrid(boundIdx);
boundScale                      = ones(1,numel(boundIdx));

%% :::::::::| Get coastline vectors |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
clLon                           = GSHHG.lon;
clLat                           = GSHHG.lat;
clScale                         = ones(1,numel(clLon));


%% :::::::::| Get connection line vectors |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
intpLineLon                     = [];
intpLineLat                     = [];
intpScale                       = [];

% Loop over all sites with try statement to skip empty fields
for j = 1:nSites
    try
        % Longitude
        currLineLon             = cat(2,siteData(j).connectionLines.lonLine2Site);
        currLineLat             = cat(2,siteData(j).connectionLines.latLine2Site);
        % Latitude
        intpLineLon             = cat(2,intpLineLon,currLineLon);
        intpLineLat             = cat(2,intpLineLat,currLineLat);
        % Full time matrix of all connection lines
        currSiteScale           = cat(2,siteData(j).connectionLines.interpTimeMTX);
        intpScale               = cat(2,intpScale,currSiteScale);
    end
end

%% :::::::::| Determine final vectors and calculate scale Matrix |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

% Final longitude and latitude vector
lonFinal                        = [boundLon',clLon,intpLineLon];
latFinal                        = [boundLat',clLat,intpLineLat];

% Initialize scale matrix
scaleMTX                        = ones(numel(lonVec),numel(latVec),nTS);

% Deactivate warnings since griddata removes duplicats that sometimes occure
warning off

% Loop over all timesteps
for i = 1:nTS
    % Current finale scale vector
    scaleFinal                  = [boundScale,clScale,intpScale(i,:)];
    % Set current row in scale matrix
    scaleMTX(:,:,i)             = griddata(lonFinal,latFinal,scaleFinal,lonGrid(:,:,i),latGrid(:,:,i),'linear');

end

% Reactivate warnings
warning on

%% :::::::::| Save variables in spatialData struct |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
spatialData.scaleData.lonVec    = lonFinal;
spatialData.scaleData.latVec    = latFinal;
spatialData.scaleData.timeVec   = spatialData.gridData.evalTime;
spatialData.scaleData.lonGrid   = lonGrid;
spatialData.scaleData.latGrid   = latGrid;
spatialData.scaleData.timeGrid  = timeGrid;
spatialData.scaleData.scaleGrid = scaleMTX;

end