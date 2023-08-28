function plt_plotSites(siteData,validSitesIdx,siteMarkerSize,siteTextColor,fsAxis)

% Plot available measuring sites with text
% scatter([siteData(validSitesIdx).lon],[siteData(validSitesIdx).lat],siteMarkerSize,siteTextColor,'o','LineWidth',1)
scatter([siteData(validSitesIdx).lon],[siteData(validSitesIdx).lat],siteMarkerSize,siteTextColor,'x','LineWidth',1)
% Loop over all sites to plot different text colors
for i = 1:numel(validSitesIdx)
    text([siteData(i).lon]+0.03,[siteData(i).lat],siteData(i).name,'FontSize',fsAxis,'Color',siteTextColor(i,:),'FontWeight','bold')
end