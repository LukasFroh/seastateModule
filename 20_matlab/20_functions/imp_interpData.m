%% ############################################################################################################################
%  _______________- OpenRAVE Interpolate Data -________________________________________________________________________________
%  ############################################################################################################################
function varOutput = imp_interpData(varInput,Target_Time,Zeitgrenze,Vars2Eval,InterpMethod)

%% Funktion zur Interpolation von Wind-, Welle- und Strömungsdaten
% - Input muss als Timetable vorliegen
% - Input-Timetable müssen Zeitstempel im Namen enthalten, in der Form <..._yyyymmdd_yyyymmdd>
% - Richtungsvariablen werden separat in sin/cos Anteile aufgeteilt und interpoliert
% - Interpolation basierend auf der Funktion interp1gap zur Berücksichtigung von Datenlücken > Zeitgrenze

%% ############################################################################################################################
%  _______________- General -__________________________________________________________________________________________________
%  ############################################################################################################################

% Identify variable names of input timetable
varNames                                    = varInput.Properties.VariableNames;

% in case no Vars2Eval is available, set Looping vars back to 'all'
if ~any(ismember(varNames,Vars2Eval))
    Vars2Eval = varNames;
end

% Remove quality flag vars
qfIDX                                       = find(contains(varNames,{'dqf_','fqf_'}));
varInput                                    = removevars(varInput,varNames(qfIDX));
% Identify variable names of input timetable (after qf var cleaning)
varNames                                    = varInput.Properties.VariableNames;

% Initialize exlude index
exludeIdx                                   = zeros(numel(Vars2Eval),1);
% loop über alle Vars2Eval und überprüfe, ob Var in varInput existiert
for i = 1:numel(Vars2Eval)
    exludeIdx(i)                            = ~any(ismember(varNames,Vars2Eval{i}));
end

clearIdx                                    = find(exludeIdx);

if ~isempty(clearIdx)

    for ii = flip(1:numel(clearIdx))
        Vars2Eval(clearIdx(ii))             = [];
    end

end

% Grenzwert in dateNum-Format
Tgrenz                                      = datenum(minutes(Zeitgrenze));

% Starte Schleife über alle fields
% for fieldi = 1:numel(fn_Structdata)

% Zwischenvariable für aktuelles field
currField                                   = varInput;
NumTime                                     = datenum(currField.(currField.Properties.DimensionNames{1}));

% Duplikate entfernen
[~, uniqueIDX]                              = unique(NumTime);
currField                                   = currField(uniqueIDX,:);

% NumTime erneuern
NumTime                                     = datenum(currField.(currField.Properties.DimensionNames{1}));

% Initialisiere Interpolierte Timetable
TT_interp                                   = timetable('RowTimes',Target_Time,'DimensionNames',{currField.Properties.DimensionNames{1},'Variables'});

%% ############################################################################################################################
%  _______________- Interpolation -__________________________________________________________________________________________________
%  ############################################################################################################################

% Schleife über zu interpolierende Spalten Vars2Eval
for vari = 1:numel(Vars2Eval)
    % Wenn weniger als 2 Datenpunkte in Datensatz vorhanden sind, setzte alle auf nan.
    if sum(~isnan(currField.(Vars2Eval{vari}))) < 2
        TT_interp.(Vars2Eval{vari}) = nan(numel(Target_Time),1);
    else
        % Fall aktuelle Vars2Eval-Variable eine der definierten Richtungsvariablen ist
        if contains(upper(Vars2Eval{vari}),{'VPED','DIR'})
            %% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Interpolation Richtungsvariablen ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            % Wandle Richtungsvariable in Sinus und Cosinus Anteil um
            CurrDegreeStruct.COS                    = cosd(currField.(Vars2Eval{vari})); % Cosinus
            CurrDegreeStruct.SIN                    = sind(currField.(Vars2Eval{vari})); % Sinus

            % Interpoliere Cos und Sin mit interp1gap Funktion
            CurrDegreeStruct.COS_interp             = interp1gap(NumTime,CurrDegreeStruct.COS,datenum(Target_Time),Tgrenz,InterpMethod);
            CurrDegreeStruct.SIN_interp             = interp1gap(NumTime,CurrDegreeStruct.SIN,datenum(Target_Time),Tgrenz,InterpMethod);

            % Vier-Quadrant inverser Tangens zum Zurückrechnen des Winkels
            CurrDegreeStruct.DEG_interp             = atan2d(CurrDegreeStruct.SIN_interp,CurrDegreeStruct.COS_interp);
            % Funktion atan2d gibt Winkel im geschlossenen Interval [-180,180] aus. Daher +360° für alle Winkel < 0°
            CurrDegreeStruct.DEG_interp(CurrDegreeStruct.DEG_interp < 0) = CurrDegreeStruct.DEG_interp(CurrDegreeStruct.DEG_interp < 0) + 360;

            % Übergebe interpolierten Winkel der Output-Variable
            TT_interp.(Vars2Eval{vari})             = CurrDegreeStruct.DEG_interp;

            % Lösche Zwischenvariable
            clearvars CurrDegreeStruct
            % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

            %% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Interpolation restliche Variablen ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

            % Wende interp1gap Funktion zur Interpolation an
        else
            TT_interp.(Vars2Eval{vari})              = interp1gap(NumTime,currField.(Vars2Eval{vari}),datenum(Target_Time),Tgrenz,InterpMethod);
        end
        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    end
end


% Übermittle interpolierte Timetable zu Output-Struct
varOutput                    = TT_interp;

% Lösche Zwischenvariablen
clearvars TT_interp currField  

% end

end




