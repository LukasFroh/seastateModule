function [fileList,gridData,rawParameters,interpParameters] = wamImport(input,paths)


%% :::::::::| Set intermediate variables |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
time2Eval                                                       = input.time2Eval;
wamDataPath                                                     = paths.wamDataPath;
model2Eval                                                      = input.wamModel2Eval;
dateIn                                                          = input.dateIn;
dateOut                                                         = input.dateOut;
lonLim                                                          = input.lonLim;
latLim                                                          = input.latLim;
evalLatVec                                                      = input.evalLatVec;
evalLonVec                                                      = input.evalLonVec;
vars2Import                                                     = input.wamVars;

%% :::::::::| Create fileList to import |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
fileList                                                        = dir([wamDataPath model2Eval '\*.nc']);
fileList                                                        = rmfield(fileList,{'date','bytes','isdir','datenum'});

% Loop over all wam files to create fileList struct
for i = 1:numel(fileList)
    fileList(i).fileTime                                        = datetime(fileList(i).name(end-12:end-3),"InputFormat","uuuuMMddHH");
    fileList(i).fileTimeNum                                     = datenum(fileList(i).fileTime);
end

% Identify invalid files
invalidAfter                                                    = find([fileList(:).fileTimeNum] > dateOut);
invalidBefore                                                   = find([fileList(:).fileTimeNum] <= dateIn);
files2Exlude                                                    = [invalidBefore,invalidAfter];

% If no files before dateIn are available, stop function
if isempty(invalidBefore)
    error('No WAM data for chosen time available')
end

% If number of available files is equal to invalid files, keep the most recent one
if numel(files2Exlude) == numel(fileList)
    AdjFileIdx                                                  = find([fileList(:).fileTimeNum] < dateIn );
    AdjFileIdx                                                  = AdjFileIdx(end);
    notExludeIdx                                                = find(files2Exlude == AdjFileIdx);
    files2Exlude(notExludeIdx)                                  = [];
end

% First entry of CWAM files (0-1 & 12-13 o'clock) are empty. Check if dateIn is in this range
if hour(dateIn) >= 0 && hour(dateIn) <= 1 && numel(fileList) > 1 || hour(dateIn) >= 12 && hour(dateIn) <= 13 && numel(fileList) > 1

    % Consider one more past file
    AdjFileIdxII                                                = find([fileList(:).fileTimeNum] < dateIn );
    AdjFileIdxII                                                = AdjFileIdxII(end-1);
    notExludeIdxII                                              = find(files2Exlude == AdjFileIdxII);
    files2Exlude(notExludeIdxII)                                = [];
end

% Exlude not needed files
fileList(files2Exlude) = [];

%% :::::::::| Set general data for files |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
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

%% :::::::::| Identify unique time indexes |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

% If there are multiple files in fileList
if numel(fileList) > 1
    for k  = 1:numel(fileList)-1
        % Which timesteps are not included in following file?
        uniqIdx = find(~ismember(fileList(k).wamTime,fileList(k+1).wamTime));
        fileList(k).importTimeIdx(1)                            = uniqIdx(end-1);
        fileList(k).importTimeIdx(2)                            = uniqIdx(end);
    end

    % For last file in List
    fileList(end).importTimeIdx(1)                              = 1;
    [~,outIdx]                                                  = min(abs(fileList(end).wamTimeNum - dateOut) );
    fileList(end).importTimeIdx(2)                              = outIdx + 1;

    % If there is exactly one file in fileList
elseif numel(fileList) == 1
    % Set ind and Out time index
    [~,inIdx]                                                   = min(abs(fileList(1).wamTimeNum - dateIn) );
    [~,outIdx]                                                  = min(abs(fileList(1).wamTimeNum - dateOut) );

    % Check if its second entry. If not consider one more timestep
    if inIdx > 2
        fileList(1).importTimeIdx(1)                            = inIdx - 1;
    else
        fileList(1).importTimeIdx(1)                            = inIdx;
    end
    % Check if last first entry. If not consider one more timestep
    if outIdx < numel(fileList(1).wamTime)
        fileList(1).importTimeIdx(2)                            = outIdx + 1;
    else
        fileList(1).importTimeIdx(2)                            = outIdx;
    end

end

%% :::::::::| Import data from .nc files |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
for l = 1 : numel(fileList)
    currFile                                                    = [fileList(l).folder '\' fileList(l).name];

    % Create data for adjusted time array
    fileList(l).adjTime                                          = fileList(l).wamTime(fileList(l).importTimeIdx(1) : fileList(l).importTimeIdx(2));
    fileList(l).adjTimeNum                                       = datenum(fileList(l).adjTime);

    % Funktion, um Rohdaten einzuladen und zu croppen
    for ll = 1:numel(vars2Import)
        currVar2Import                                          = vars2Import{ll};
        % Set start idx
        lonStart                                                = fileList(l).lonIdx(1);
        latStart                                                = fileList(l).latIdx(1);
        timeStart                                               = fileList(l).importTimeIdx(1);
        % Set count idx
        lonCount                                                = fileList(l).lonIdx(2) - lonStart +1;
        latCount                                                = fileList(l).latIdx(2) - latStart +1;
        timeCount                                               = fileList(l).importTimeIdx(2) - timeStart +1;

        % timeCount = 0 leads to error. Check if this is the case and if yes, set it to 1.
        if timeCount == 0
            timeCount = 1;
        end

        % Import data as double
        fileList(l).(vars2Import{ll})                            = double(ncread(currFile,currVar2Import,[lonStart,latStart,timeStart],[lonCount,latCount,timeCount]));
    end
end

%% :::::::::| Final WAM information |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

% Set gridData settings
gridData                                                  = struct;
gridData.wamTime                                          = cat(1,fileList(:).adjTime);
gridData.evalTime                                         = time2Eval;
gridData.evalTimeNum                                      = datenum(time2Eval);
gridData.wamTimeNum                                       = cat(1,fileList(:).adjTimeNum);
gridData.wamLon                                           = fileList(1).lon;
gridData.wamLat                                           = fileList(1).lat;
gridData.evalLon                                          = evalLonVec;
gridData.evalLat                                          = evalLatVec;

% Initialize initial and result grids
[gridData.wamLatGrid, gridData.wamLonGrid, gridData.wamTimeNumGrid] = ...
    meshgrid(gridData.wamLat, gridData.wamLon, gridData.wamTimeNum);

[gridData.evalLatGrid,gridData.evalLonGrid, gridData.evalTimeGrid]  = ...
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
        % InputParameters
        inputX = rawParameters(si).latGrid;
        inputY = rawParameters(si).lonGrid;
        inputZ = rawParameters(si).timeGrid;
        inputVar = rawParameters(si).raw;
        % OutputParameters
        outputX = interpParameters(si).latGrid(:,:,startIdx:endIdx);
        outputY = interpParameters(si).lonGrid(:,:,startIdx:endIdx);
        outputZ = interpParameters(si).timeGrid(:,:,startIdx:endIdx);
        % 3D interpolation
        interpCell{ii} = interp3(inputX, inputY, inputZ, inputVar, outputX, outputY, outputZ);

    end

    % Concatenate all parts
    interpParameters(si).interp                                 = cat(3,interpCell{:});

end


end