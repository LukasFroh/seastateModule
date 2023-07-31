function [currDataList,latestTime] = imp_createFileList(input,currDataPath,fileAddon)
%% Search for relevant 

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

currFileNames                           = {currDataList(:).name};

% % Set start and end date
% for ii = 1:numel(currFileNames)
%     currFileDates                       = regexp(currFileNames{ii},'(\d+)-(\d+)-(\d+)','match');
%     currDataList(ii).startDate          = datetime(currFileDates{1},'InputFormat','yyyy-MM-dd');
%     currDataList(ii).endDate            = datetime(currFileDates{2},'InputFormat','yyyy-MM-dd');
%     currDataList(ii).startDateNum       = datenum(currDataList(ii).startDate);
%     currDataList(ii).endDateNum         = datenum(currDataList(ii).endDate);
% end

% Identify most recent time of all files in list
% latestTime                              = max([currDataList(:).endDate]);


% % Exclude files not in timerange
% exclIdx                                 = [currDataList(:).endDateNum] < input.dateIn | [currDataList(:).startDateNum] > input.dateOut;
% % Delete lines in struct
% currDataList(exclIdx)                   = [];

% Sort after ascending start date
% [~,index]                               = sortrows([currDataList.startDateNum].'); 
% currDataList                            = currDataList(index); 

end