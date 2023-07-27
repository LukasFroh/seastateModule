function [rawData,cleanedData,interpData] = imp_importCleanInterpSeastateData(fileList,headerPath,input)

% Check if files are available
if ~isempty(fileList)

    % Import raw data to fileList
    for iHis = 1: numel(fileList)
        currList                = fileList;
        currFile                = fullfile(currList(iHis).folder,currList(iHis).name);
        % No vars2Import because qf would be missing for cleaning process
        fileList(iHis).rawData  = imp_importSeastateData(currFile,headerPath);
    end

    %% Concatenate all raw data files
    % Initialize vector for all table sizes
    currTblSizes                = zeros(numel(fileList),1);
    % Identify number of vars for each raw timetable
    for ci = 1:numel(currTblSizes)
        currTblSizes(ci)        = size( fileList(ci).rawData, 2 );
    end
  
    % Check if more than one unique size is available
    if numel(unique(currTblSizes)) == 1
        % cat function can be used (way faster)
        rawData                 = cat(1,fileList(:).rawData);
    else
        % Use function imp_tblvertcat instead in case different variable names are existent
        rawData                 = imp_tblvertcat(fileList(:).rawData);
    end

    % Sort regarding date
    rawData                     = sortrows(rawData);
    % Remove duplicates
    rawData                     = unique(rawData);
    % Clean raw data
    cleanedData                 = imp_cleanQFdata(rawData, input.seastateVars2Eval, input.minQF);
    % Interpolate data to chosen datetime vector
    interpData                  = imp_interpData(cleanedData, input.time2Eval, input.timeThresh, input.seastateVars2Eval, input.interpMethod);

else

    % If fileList is empty, create empty placeholders for three output variables
    rawData                     = [];
    cleanedData                 = [];
    interpData                  = [];

end



end