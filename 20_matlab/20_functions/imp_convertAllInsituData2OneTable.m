function siteDataOut = imp_convertAllInsituData2OneTable(siteDataIn,finalSensorStructName,finalTTName)

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

    if ~istimetable(siteDataIn(iField).(finalSensorStructName))

        % Get all data names in current final live data struct
        try
            currFields                                              = fieldnames(siteDataIn(iField).(finalSensorStructName));
            % Set dwr > radac > radacSingle priority when creating the final timetable an
            % if ismember('dwrHIS',currFields) && ismember('dwrHIW',currFields) && ~isempty(siteDataIn(iField).(finalSensorStructName).('dwrHIS')) && ~isempty(siteDataIn(iField).(finalSensorStructName).('dwrHIW'))
            if ismember('dwrHIS',currFields) && ismember('dwrHIW',currFields) 
                siteDataOut(iField).(finalTTName)                   = [siteDataIn(iField).(finalSensorStructName).('dwrHIS'), siteDataIn(iField).(finalSensorStructName).('dwrHIW')];
                siteDataOut(iField).('chosenSensor')                = 'dwr';
            % elseif ismember('dwrHIS',currFields) && ~isempty(siteDataIn(iField).(finalSensorStructName).('dwrHIS'))
            elseif ismember('dwrHIS',currFields) 
                siteDataOut(iField).(finalTTName)                   = [siteDataIn(iField).(finalSensorStructName).('dwrHIS')];
                siteDataOut(iField).('chosenSensor')                = 'dwr';
            % elseif ismember('radac',currFields) && ~isempty(siteDataIn(iField).(finalSensorStructName).('radac'))
            elseif ismember('radac',currFields)
                siteDataOut(iField).(finalTTName)                   = siteDataIn(iField).(finalSensorStructName).('radac');
                siteDataOut(iField).('chosenSensor')                = 'radac';
            elseif ismember('radacSingle',currFields) && ~ismember('dwrHIS',currFields) && ~ismember('radac',currFields)
                siteDataOut(iField).(finalTTName)                   = siteDataIn(iField).(finalSensorStructName).('radacSingle');
                siteDataOut(iField).('chosenSensor')                = 'radacSingle';
            end

            % Replace field with nan timetable in case it is empty
            if isempty(siteDataOut(iField).(finalTTName))
                nTimesteps                                          = nan(numel(siteDataIn(iField).time),1);
                siteDataOut(iField).(finalTTName)                  = timetable(siteDataIn(iField).time,nTimesteps,'VariableNames',{'VHM0'});
            end

        catch
            nTimesteps                                          = nan(numel(siteDataIn(iField).time),1);
            siteDataOut(iField).(finalTTName)                  = timetable(siteDataIn(iField).time,nTimesteps,'VariableNames',{'VHM0'});
        end
    end
end

end