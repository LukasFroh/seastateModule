function [fileList,gridData,rawParameters,interpParameters] = wamImport(input,paths)


% Set Variables

time2Eval                                                       = input.time2Eval;
wamDataPath                                                     = paths.wamDataPath;
model2Eval                                                      = input.wamModel2Eval;
date_in                                                         = input.dateIn;
date_out                                                        = input.dateOut;
lonLim                                                          = input.lonLim;
latLim                                                          = input.latLim;
evalLatVec                                                      = input.evalLatVec;
evalLonVec                                                      = input.evalLonVec;
vars2Import                                                     = input.wamVars;

%% :::::::::| Import wam data |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

fileList                                                        = dir([wamDataPath model2Eval '\*.nc']);
fileList                                                        = rmfield(fileList,{'date','bytes','isdir','datenum'});

% Loop over all wam files to create fileList struct
for i = 1:numel(fileList)
    fileList(i).fileTime                                        = datetime(fileList(i).name(end-12:end-3),"InputFormat","uuuuMMddHH");
    fileList(i).fileTimeNum                                     = datenum(fileList(i).fileTime);
end

invalidAfter                                                    = find([fileList(:).fileTimeNum] > date_out);
invalidBefore                                                   = find([fileList(:).fileTimeNum] < date_in);


% Create counter
counter = 0;

% Für historische CWAM DAten 2021
if ~isempty(invalidBefore)

    % Ausschließen, wenn es nicht exakt Inputzeit ist, damit auf jeden Fall gültiger Datensatz vorhanden ist
    if ~(fileList(invalidBefore(end)).fileTimeNum == date_in)
        invalidBefore(end)                                          = [];
        counter                                                     = counter + 1;
    elseif strcmpi(model2Eval,'cwam') && fileList(invalidBefore(end)).fileTimeNum == date_in
        invalidBefore(end)                                          = [];
        counter                                                     = counter + 1;
    end

    files2Exlude                                                    = [invalidBefore,invalidAfter];

    % If sum of files2Exlude is equal to amount of available files, include last file in "invalidBefore"
    if numel([invalidBefore,invalidAfter]) == (numel(fileList) - counter)
        AdjFileIdx                                                  = find([fileList(:).fileTimeNum] <= date_in );
        AdjFileIdx                                                  = AdjFileIdx(end);

        % CWAM due to timeshift has no data from 0-1 and 12-13 (if dataset starts there)
        if strcmpi(model2Eval,'cwam') && hour(date_in) >= 0 && hour(date_in) <= 1.0
            AdjFileIdx                                                  = AdjFileIdx - 1;
        elseif strcmpi(model2Eval,'cwam') && hour(date_in) >= 12 && hour(date_in) <= 13.0
            AdjFileIdx                                                  = AdjFileIdx - 1;
        end

        notExludeIdx                                                = find(files2Exlude == AdjFileIdx);
        files2Exlude(notExludeIdx)                                  = [];

    end

    % Für CWAM2021 ausschließlich files2Exlude ermitteln
else
    files2Exlude                                                    = [invalidBefore,invalidAfter];
end


% Nicht benötigte Files ausschließen
fileList(files2Exlude)                                          = [];

% Set general information
for e = 1:numel(fileList)
    currFile                                                    = [fileList(e).folder '\' fileList(e).name];
    fileList(e).ncInfo                                          = ncinfo(currFile);
    fileList(e).vars2Imp                                        = vars2Import;

    % Funktion, um Rohdaten einzuladen und zu croppen
    for ee = 1:numel(vars2Import)
        currVar2Import                                           = vars2Import{ee};
        fileList(e).wamTimeNum                                   = datenum(1900,1,1,0,0,0) + double(ncread(currFile,'time'));
        fileList(e).wamTime                                      = datetime(fileList(e).wamTimeNum,'ConvertFrom','datenum');
        fileList(e).lonRaw                                       = double(ncread(currFile,'lon'));
        fileList(e).latRaw                                       = double(ncread(currFile,'lat'));
        [~,fileList(e).lonIdx(1)]                                = min(abs( fileList(e).lonRaw - lonLim(1) ));
        [~,fileList(e).lonIdx(2)]                                = min(abs( fileList(e).lonRaw - lonLim(2) ));
        [~,fileList(e).latIdx(1)]                                = min(abs( fileList(e).latRaw - latLim(1) ));
        [~,fileList(e).latIdx(2)]                                = min(abs( fileList(e).latRaw - latLim(2) ));
        fileList(e).lon                                          = fileList(e).lonRaw(fileList(e).lonIdx(1):fileList(e).lonIdx(2));
        fileList(e).lat                                          = fileList(e).latRaw(fileList(e).latIdx(1):fileList(e).latIdx(2));
    end

end

% Identify unique time indexes for different wam datasets
for k = 1: numel(fileList)

    if k == 1
        [~,fileList(k).importTimeIdx(1)]                         = min(abs(fileList(k).wamTimeNum - date_in) );

        if fileList(k).importTimeIdx(1) > 1
            fileList(k).importTimeIdx(1)                         = fileList(k).importTimeIdx(1) -1;
        end

    end

    if k > 1
        [~,fileList(k-1).importTimeIdx(2)]                       = min(abs(fileList(k-1).wamTimeNum - fileList(k).wamTimeNum(1) ) );
        fileList(k-1).importTimeIdx(2)                           = fileList(k-1).importTimeIdx(2) - 1;
        fileList(k).importTimeIdx(1)                             = 1;
    end

    if k == numel(fileList)
        [~,fileList(k).importTimeIdx(2)]                         = min(abs(fileList(k).wamTimeNum - date_out ) );

        if fileList(k).importTimeIdx(2) < numel(fileList(k).wamTimeNum)
            fileList(k).importTimeIdx(2)                         = fileList(k).importTimeIdx(2) + 1;
        end

    end
end

% Imported specified times
for l = 1 : numel(fileList)
    currFile                                                    = [fileList(l).folder '\' fileList(l).name];

    % Create data for adjusted time array
    fileList(l).adjTime                                          = fileList(l).wamTime(fileList(l).importTimeIdx(1) : fileList(l).importTimeIdx(2));
    fileList(l).adjTimeNum                                       = datenum(fileList(l).adjTime);

    % Funktion, um Rohdaten einzuladen und zu croppen
    for ll = 1:numel(vars2Import)
        currVar2Import                                          = vars2Import{ll};

        lonStart                                                = fileList(l).lonIdx(1);
        latStart                                                = fileList(l).latIdx(1);
        timeStart                                               = fileList(l).importTimeIdx(1);

        lonCount                                                = fileList(l).lonIdx(2) - lonStart +1;
        latCount                                                = fileList(l).latIdx(2) - latStart +1;
        timeCount                                               = fileList(l).importTimeIdx(2) - timeStart +1;

        fileList(l).(vars2Import{ll})                            = double(ncread(currFile,currVar2Import,[lonStart,latStart,timeStart],[lonCount,latCount,timeCount]));
    end
end

%% :::::::::| Final WAM information |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

gridData                                                  = struct;
gridData.wamTime                                          = cat(1,fileList(:).adjTime);
gridData.evalTime                                         = time2Eval;
gridData.evalTimeNum                                      = datenum(time2Eval);
gridData.wamTimeNum                                       = cat(1,fileList(:).adjTimeNum);
gridData.wamLon                                           = fileList(1).lon;
gridData.wamLat                                           = fileList(1).lat;
gridData.evalLon                                          = evalLonVec;
gridData.evalLat                                          = evalLatVec;

% [gridData.wamLatGrid, gridData.wamLonGrid, gridData.wamTimeGrid] = ...
%     meshgrid(gridData.wamLat, gridData.wamLon, gridData.wamTime);

[gridData.wamLatGrid, gridData.wamLonGrid, gridData.wamTimeNumGrid] = ...
    meshgrid(gridData.wamLat, gridData.wamLon, gridData.wamTimeNum);

[gridData.evalLatGrid,gridData.evalLonGrid, gridData.evalTimeGrid]                              = ...
    meshgrid(evalLatVec, evalLonVec, gridData.evalTimeNum);


% Preallocating structs for higher speed
n                                                               = cell(numel(vars2Import),1);
rawParameters                                                   = struct('name',n,'time',n,'timeNum',n,'lonGrid',n,'latGrid',n,'timeGrid',n,'raw',n);
interpParameters                                                = struct('name',n,'time',n,'timeNum',n,'lonGrid',n,'latGrid',n,'timeGrid',n,'interp',n);
timeLength                                                      = numel(gridData.evalTime);
interpLim                                                       = 1000;
nSteps                                                          = ceil(timeLength / interpLim);
interpCell                                                      = cell(nSteps,1);

for si = 1:numel(vars2Import)

    % _______________- raw parameter struct -____________________________________________________________________________________________
    rawParameters(si).name                                      = vars2Import{si};
    rawParameters(si).time                                      = gridData.wamTime;
    rawParameters(si).timeNum                                   = gridData.wamTimeNum;
    rawParameters(si).lonGrid                                   = gridData.wamLonGrid;
    rawParameters(si).latGrid                                   = gridData.wamLatGrid;
    rawParameters(si).timeGrid                                  = gridData.wamTimeNumGrid;
    rawParameters(si).raw                                       = cat(3,fileList(:).(vars2Import{si}));

    % _______________- interpolated parameter struct -____________________________________________________________________________________________
    interpParameters(si).name                                   = vars2Import{si};
    interpParameters(si).time                                   = gridData.evalTime;
    interpParameters(si).timeNum                                = gridData.evalTimeNum;
    interpParameters(si).lonGrid                                = gridData.evalLonGrid;
    interpParameters(si).latGrid                                = gridData.evalLatGrid;
    interpParameters(si).timeGrid                               = gridData.evalTimeGrid;

    % Split interpolation process in multiple parts to avoid out of memory issues
    for ii = 1:nSteps
        % Identify start and end index
        startIdx    = (ii-1) * interpLim + 1;
        if ii == nSteps
            endIdx  = timeLength;
        else
            endIdx      = ii * interpLim;
        end
        % Interpolate current data part
        interpCell{ii} =                                  ...
            interp3(rawParameters(si).latGrid,rawParameters(si).lonGrid,rawParameters(si).timeGrid,     ... % (Input: Y,X,Z)
            rawParameters(si).raw,                                                                      ... % (Var2Interpolate)
            interpParameters(si).latGrid(:,:,startIdx:endIdx),interpParameters(si).lonGrid(:,:,startIdx:endIdx),interpParameters(si).timeGrid(:,:,startIdx:endIdx));       % (Output: Y,X,Z)

    end

    % Concatenate all parts
    interpParameters(si).interp                                 = cat(3,interpCell{:});

end



