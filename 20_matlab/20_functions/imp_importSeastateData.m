function importTimeTable = imp_importSeastateData(fileName,fileHeaderPath,vars2Import)

%% Set up Import Options
opts        = detectImportOptions(fileName);
% Find line where variable names are located in file
hline       = opts.VariableNamesLine;

% Seastate data types
dataTypes = {'_HIS','_HIW','_GPS','_RADAC_','_RADAC_SINGLE_'};

% Loop over all available dataTypes
for i = 1:numel(dataTypes)

    if contains(fileName,dataTypes(i))
        switch dataTypes{i}
            case '_HIS'
                headerFileName = 'DWR_HISHeader.mat';
            case '_HIW'
                headerFileName = 'DWR_HIWHeader.mat';
            case '_GPS'
                headerFileName = 'DWR_GPSHeader.mat';
            case '_RADAC_'
                headerFileName = 'RADAC_Header.mat';
            case '_RADAC_SINGLE_'
                headerFileName = 'RADAC_SINGLE_Header.mat';
        end

        % Import header file in struct header file
        headerFile              = load(fullfile(fileHeaderPath,headerFileName));
        % Identify name of imported variable
        headerField             = fieldnames(headerFile);

        % Break for loop
        break

    end
end

if hline == 0
    % Set Variable names according to imported header file
    opts.VariableNames              = headerFile.(headerField{:});

end

% If vars2Import are available
if nargin > 2
    % Add 'Time' to vars2Import if it doesn't exist
    if ~ismember(lower(vars2Import),'time')
        vars2Import = [{'Time'},vars2Import];
    end

    % Import all vars if vars2Import == 'all'
    if any(strcmpi(vars2Import,'all'))
        opts.SelectedVariableNames  = opts.VariableNames;
    else

        % Find idx of vars2Import that are available in variable names
        availVarIdx = find( ismember(opts.VariableNames, vars2Import) );
        % Chose only available vars
        opts.SelectedVariableNames  = opts.VariableNames(availVarIdx);
    end
end

% Find index of time variable
% timeIdx                             = find(ismember(opts.VariableNames,'Time'));
% % Set variable type of Time to datetime
% opts.VariableTypes{timeIdx}         = 'datetime';
% % Set input format 
% timeFormat                          = 'yyyyMMddHHmm';
% opts.VariableOptions(1).InputFormat = timeFormat;
% % Set output datetime format
% opts.VariableOptions(1).DatetimeFormat = 'yyyy-MM-dd HH:mm' ;


% Import data as timetable
% importTimeTable                     = readtimetable(fileName, opts,'RowTimes','Time'); % Deutlich langsamer (Faktor 10!!)
importTable                         = readtable(fileName, opts);
timeFormat                          = 'yyyyMMddHHmm';
timeDateTime                        = datetime(string(importTable.Time),'InputFormat',timeFormat,'Format','yyyy-MM-dd HH:mm');

importTable.Time                    = [];

importTimeTable                     = table2timetable(importTable,'RowTimes',timeDateTime);
importTimeTable.Time.TimeZone       = 'UTC';


% Timeshift for dwrHIS datasets
if exist('headerField','var') &&  strcmp(headerField,'DWR_HISHeader')
    importTimeTable.Time.Minute      = 30 * floor(importTimeTable.Time.Minute / 30);
    importTimeTable.Time             = importTimeTable.Time - duration([00 15 00]);
end

% Timeshift for dwrGPS datasets
if exist('headerField','var') &&  strcmp(headerField,'DWR_GPSHeader')
    importTimeTable.Time.Minute      = 30 * floor(importTimeTable.Time.Minute / 30);
    importTimeTable.Time             = importTimeTable.Time - duration([00 15 00]);
end

% Timeshift for dwrGPS datasets
if exist('headerField','var') &&  strcmp(headerField,'DWR_HIWHeader')
    importTimeTable.Time             = importTimeTable.Time + duration([00 15 00]);
end

end