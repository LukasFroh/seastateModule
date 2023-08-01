function [Coastlines,latTotal,lonTotal] = OR_GetCoastlines(pathDir,filename,latlim,lonlim)

% Full path to file (either .mat or .b)
fullPath                = [pathDir filename];
  
%% :::::::::| Access to mapping toolbox |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if license('test','MAP_Toolbox')

    % Mapping toolbox available at LuFI. When .mat file is defined as Input, switch filename to original input files
    if strcmp(filename(end-3:end),'.mat')
        filename        = 'gshhs_f.b';
        fullPath        = [pathDir filename];
    end

    % List available index files
    dataDir             = dir([pathDir '*.i']);

    % If index file is not yet available, create a new one
    if ~any(strcmp({dataDir.name},strrep(filename,'.b','.i')))
        indexfilename   = gshhs(fullPath, 'createindex');
    end

    % Import coastline data
    GSHHG               = gshhs(fullPath, latlim,lonlim);

    % Identify land entries
    fnLevelString           = {GSHHG(:).("LevelString")};
    landIDX                 = find(strcmp(fnLevelString,'land'));
    % Initialize parameters
    latTrimmed              = cell(numel(landIDX),1);
    lonTrimmed              = cell(numel(landIDX),1);
    nanIDXlat               = cell(numel(landIDX),1);
    nanIDXlon               = cell(numel(landIDX),1);
    counter                 = 0;
    latTotal                = [];
    lonTotal                = [];

    % Loop over all land entries
    for i = landIDX
        % Trim
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
        end
    end

    %% :::::::::| No access to mapping toolbox |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
else
    % Instead: Load already imported GSHHG struct:
    s                   = load(fullPath);
    % Name of imported struct;
    sFN                 = fieldnames(s);
    % Set GSHHG as struct name
    GSHHG               = s.(sFN{1});
end

end
