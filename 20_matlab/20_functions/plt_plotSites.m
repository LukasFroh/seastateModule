function plt_plotSites(siteData,validSitesIdx,siteMarkerSize,siteTextColor,siteTextColorNoData,fsAxis,siteScales)

% Intermediate variables
lon     = [siteData(validSitesIdx).lon];
lat     = [siteData(validSitesIdx).lat];
names   = [siteData(:).name];

% Loop over all sites to plot different text colors
for i = 1:numel(validSitesIdx)
    if strcmpi(names{i},'FN1')
        horizDispl = -0.2;
    else
        horizDispl = +0.03;
    end

    if isnan(siteScales(i))
        scatter(lon(i),lat(i),siteMarkerSize,siteTextColorNoData,'x','LineWidth',1)                               % Marker I 
        % scatter(lon(i),lat(i),siteMarkerSize,siteTextColor,'o','LineWidth',1)                             % Marker II
        text(lon(i)+horizDispl,lat(i),['$\it{' names{i} '}$'],'FontSize',fsAxis,'Color',siteTextColorNoData,'FontWeight','bold','Interpreter','latex')  % Site text
    else
        scatter(lon(i),lat(i),siteMarkerSize,siteTextColor(i,:),'x','LineWidth',1)                               % Marker I 
        % scatter(lon(i),lat(i),siteMarkerSize,siteTextColor,'o','LineWidth',1)                             % Marker II
        text(lon(i)+horizDispl,lat(i),names{i},'FontSize',fsAxis,'Color',siteTextColor(i,:),'FontWeight','bold')  % Site text
    end
end