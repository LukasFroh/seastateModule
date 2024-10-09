function [outData,outTable] = imp_importSiteConnections(folderPath,siteOverview)

% Path to file
p2f = fullfile(folderPath,'siteConnections');

% Set ImportOptions
opt = detectImportOptions(p2f);
% Set start row to 3
opt.DataRange = [3 Inf];
% Manually set variable type of all colums but the first (site names) to double
opt.VariableTypes(2:end) = {'double'};
% Import the data as table
in = readtable(p2f,opt);
% Identify site names in first column
siteNamesColumn = (in{:,1});
% Exclude cells without site name
siteNamesIdx = find(~cellfun(@isempty,siteNamesColumn));
% Identify sitename string
siteNames = siteNamesColumn(siteNamesIdx);
% Boolean siteConnection info as array
data = in {1:numel(siteNames),2:1+numel(siteNames)};
% Adjust siteNames to currently chosen sites2import according to siteOverview
[~,sortedIdx] = ismember(siteOverview.name,siteNames);
% Sorted array in order of siteOverview Table%
outData = data(sortedIdx,sortedIdx);
% Sorted table with row and column names
outTable = array2table(outData,'VariableNames',siteNames(sortedIdx)','RowNames',siteNames(sortedIdx));


end