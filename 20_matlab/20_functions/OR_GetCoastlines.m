function [Coastlines,latTotal,lonTotal] = OR_GetCoastlines(pathDir,filename,latlim,lonlim)


fullPath                                            = [pathDir filename];                                                                % full path to file
dataDir                                             = dir([pathDir '*.i']);

if ~any(strcmp({dataDir.name},strrep(filename,'.b','.i')))                                                                                     % If index file is not yet available
    indexfilename                                    = gshhs(fullPath, 'createindex');
end


GSHHG                                               = gshhs(fullPath, latlim,lonlim);                                                               % Import data

% Identify land entries
fnLevelString = {GSHHG(:).("LevelString")};

landIDX = find(strcmp(fnLevelString,'land'));

latTrimmed      = cell(numel(landIDX),1);
lonTrimmed      = cell(numel(landIDX),1);
nanIDXlat       = cell(numel(landIDX),1);
nanIDXlon       = cell(numel(landIDX),1);
counter         = 0;

latTotal        = [];
lonTotal        = [];
% progressbar('Set','Part')

for i = landIDX
    [latTrimmed{i},lonTrimmed{i}] = maptrimp(GSHHG(i).Lat,GSHHG(i).Lon, latlim, lonlim);

    nanIDXlat{i} = find(isnan(latTrimmed{i}));
    nanIDXlon{i} = find(isnan(lonTrimmed{i}));

    % Check if lat and lon have the same nan entries
    if ~isequal(nanIDXlat{i},nanIDXlon{i})
        error('NaN Values at different lat/lon positions')
    end

    %Create looping var
    nanIDXloop      = [1, nanIDXlat{i}];

    for j = 1:numel(nanIDXlat{i})
        counter = counter +1;
        if j == 1

            Coastlines.(['Set_' num2str(counter)]).lat       = latTrimmed{i}(nanIDXloop(j):nanIDXloop(j+1)-1);
            Coastlines.(['Set_' num2str(counter)]).lon       = lonTrimmed{i}(nanIDXloop(j):nanIDXloop(j+1)-1);

        else
            Coastlines.(['Set_' num2str(counter)]).lat   = latTrimmed{i}(nanIDXloop(j)+1:nanIDXloop(j+1)-1);
            Coastlines.(['Set_' num2str(counter)]).lon   = lonTrimmed{i}(nanIDXloop(j)+1:nanIDXloop(j+1)-1);

        end

        if isempty(latTotal) && isempty(lonTotal)
            latTotal                                    = Coastlines.(['Set_' num2str(counter)]).lat;
            lonTotal                                    = Coastlines.(['Set_' num2str(counter)]).lon;
        else
            latTotal                                    = [latTotal, Coastlines.(['Set_' num2str(counter)]).lat];
            lonTotal                                    = [lonTotal, Coastlines.(['Set_' num2str(counter)]).lon];
        end

%         progressbar([],j/numel(nanIDXlat{i}))
    end

%     progressbar(i/numel(landIDX))


end


end
