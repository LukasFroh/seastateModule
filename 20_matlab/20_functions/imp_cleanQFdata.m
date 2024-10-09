%% ############################################################################################################################
%  _______________- OpenRAVE Clean Data Skript -_______________________________________________________________________________
%  ############################################################################################################################
function outputTimetable = imp_cleanQFdata(inputTimetable,Variables2Eval,AcceptedFQF)

% Initialize timetable
outputTimetable = inputTimetable;

% Check if input is set to specific variables or to "all" variables
if strcmpi(Variables2Eval,'all')
    loopingVars = inputTimetable.Properties.VariableNames;
else
    loopingVars = Variables2Eval;
end

% in case no variable2Eval is available, set Looping vars back to 'all'
if ~any(ismember(inputTimetable.Properties.VariableNames,Variables2Eval))
    loopingVars = inputTimetable.Properties.VariableNames;
end



% Loop over chosen variables
for i = 1:numel(loopingVars)
    % Current name of variable
    currVar         = loopingVars{i};
    % Find colunnb of variable in table
    currVarIdx      = find( strcmp ( inputTimetable.Properties.VariableNames, currVar ) );
    if isempty(currVarIdx)
        continue
    end
    % Current name of variables final quality flag (fqf)
    currVarFQFname  = ['fqf_' currVar];
    % Find column of fqf in table
    currFQFidx      = find( strcmp( inputTimetable.Properties.VariableNames, currVarFQFname ) );
    % If currFQF idx does not exist, skip looping variable
    if isempty(currFQFidx)
        continue
    end

    % Find entries that are not equal to accepted quality flags (AcceptedFQF)
    % errorIDX        = ~any( inputTimetable.(currVarFQFname) == AcceptedFQF , 2);

    % Find entries that are above accepted quality flag (AcceptedFQF)
    errorIDX        = inputTimetable.(currVarFQFname) > AcceptedFQF;

    % Set entries with errorIDX to nan
    outputTimetable{errorIDX, currVarIdx:currFQFidx} = nan;
end

end
