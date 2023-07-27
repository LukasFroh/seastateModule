function spatialData = OR_ScaleWAMdata(spatialData,var2ScaleWam)

% Define fieldname in struct spatialData
fn_Struct           = 'wamInterpParameters';

% Get all varnames in struct
[varNames]          = {spatialData.(fn_Struct)(:).name};


% Loop over all variables with scale information (at the moment only for one parameter possible)
for i = 1:numel(var2ScaleWam)
    % Get varname idx
    varNameIdx          = find(strcmp(varNames,var2ScaleWam{i}));
    spatialData.(fn_Struct)(varNameIdx).scaled = spatialData.(fn_Struct)(varNameIdx).interp .* spatialData.scaleData.scaleGrid;
end


end