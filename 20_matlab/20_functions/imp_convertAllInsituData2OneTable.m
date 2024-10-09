function siteDataOut = imp_convertAllInsituData2OneTable(input,siteDataIn,finalSensorStructName,finalTTName)

% Identify site names
if iscell(siteDataIn(1).name)
    sites       = [siteDataIn(:).name];
elseif ischar(siteData(1).name)
    sites       = {siteDataIn(:).name};
end

% Initialize siteData struct
siteDataOut             = siteDataIn;

% Loop over all sites
for iField = 1:numel(sites)
    
    % If finalSensorStructName is no timetable, do sensor priority sorting
    if ~istimetable(siteDataIn(iField).(finalSensorStructName))

        % Initialize validCounter --> 1 for valid data / 0 for no valid data (skip to next sensor)
        validCounter = 0;

        % Get all data names in current final live data struct
        currFields          = fieldnames(siteDataIn(iField).(finalSensorStructName));

        %% ----- If dwrHis data is available and not empty -----
        if ismember("dwrHIS",currFields)
            if ~isempty(siteDataIn(iField).(finalSensorStructName).("dwrHIS"))
                % Set final timetable
                siteDataOut(iField).(finalTTName)           = siteDataIn(iField).(finalSensorStructName).('dwrHIS');
                % Set chosenSensor to dwr
                siteDataOut(iField).('chosenSensor')        = 'dwr';
                % Set valid counter to true
                validCounter = 1;
            end
        end

        %% ----- If dwr not valid/available and radac is available and not empty -----
        if ismember("radac",currFields) && validCounter == 0
            if ~isempty(siteDataIn(iField).(finalSensorStructName).("radac"))
                % Set final timetable
                siteDataOut(iField).(finalTTName)           = siteDataIn(iField).(finalSensorStructName).('radac');
                % Set chosenSensor to radac
                siteDataOut(iField).('chosenSensor')        = 'radac';
                % Set valid counter to true
                validCounter = 1;
            end
        end

        %% ----- If dwr + radac not valid/available and radac single is available and not empty -----
        if ismember("radacSingle",currFields) && validCounter == 0
            if ~isempty(siteDataIn(iField).(finalSensorStructName).("radacSingle"))
                % Set final timetable
                siteDataOut(iField).(finalTTName)           = siteDataIn(iField).(finalSensorStructName).('radacSingle');
                % Set chosenSensor to radacSingle
                siteDataOut(iField).('chosenSensor')        = 'radacSingle';
                % Set valid counter to true
                validCounter = 1;
            end
        end

        %% ----- If none of dwr, radac or radac single is valid/available -----
        if validCounter == 0
            % No valid sensor available. Create timetable with NaN entry for current timestep and set chosenSensor to none
            nTimesteps                                  = nan(numel(siteDataIn(iField).time),1);
            siteDataOut(iField).(finalTTName)           = timetable(siteDataIn(iField).time,nTimesteps,'VariableNames',{'VHM0'});
            siteDataOut(iField).('chosenSensor')        = 'none';
        end

    end
end