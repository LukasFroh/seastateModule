function plt_plotSites(siteData,validSitesIdx,siteMarkerSize,siteTextColor,siteTextColorNoData,fsAxis,siteScales)

% Intermediate variables
lon     = [siteData(validSitesIdx).lon];
lat     = [siteData(validSitesIdx).lat];
names   = [siteData(:).name];

% Loop over all sites to plot different text colors
for i = 1:numel(validSitesIdx)
    
    % Site displacement special adjustments
    switch names{i}
        case 'FN1'
            horizDispl = -0.3;
        case 'AV0'
            vertDispl  = 0.04;
        case 'LTH'
            vertDispl  = 0.045;
            horizDispl = 0.03;
    end

    if ~exist("horizDispl",'var')
        horizDispl = 0.04;
    end
    if ~exist("vertDispl",'var')
        vertDispl = 0;
    end
    

    if isnan(siteScales(i))
        scatter(lon(i),lat(i),siteMarkerSize,siteTextColorNoData(i,:),'x','LineWidth',1)                               % Marker I 
        % scatter(lon(i),lat(i),siteMarkerSize,siteTextColor,'o','LineWidth',1)                             % Marker II
        text(lon(i)+horizDispl,lat(i)+vertDispl,['$\it{' names{i} '}$'],'FontSize',fsAxis,'Color',siteTextColorNoData(i,:),'FontWeight','bold','Interpreter','latex')  % Site text
    else
        scatter(lon(i),lat(i),siteMarkerSize,siteTextColor(i,:),'x','LineWidth',1)                               % Marker I 
        % scatter(lon(i),lat(i),siteMarkerSize,siteTextColor,'o','LineWidth',1)                             % Marker II
        text(lon(i)+horizDispl,lat(i)+vertDispl,names{i},'FontSize',fsAxis,'Color',siteTextColor(i,:),'FontWeight','bold')  % Site text
    end

    % Clear displacement parameters
    clear horizDispl vertDispl
end