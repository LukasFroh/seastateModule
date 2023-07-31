function [currDataList] = imp_createFileList(currDataPath,fileAddon)


% Add empty file Addon if not declared (mandatory for his,hiw,gps)
if nargin < 2
    fileAddon = '';
end

% List all relevant files
currDataList                            = dir([currDataPath,'\' fileAddon]);
if isempty(currDataList)
    return
end

% Remove not needed fields
currDataList                            = rmfield(currDataList,{'date','isdir','datenum'});

% Remove files with no content. Find Idx of files with 0 bytes
zeroByteIdx                             = find(~([currDataList.bytes] > 0));
if ~isempty(zeroByteIdx)
    currDataList(zeroByteIdx)  = [];
end




end