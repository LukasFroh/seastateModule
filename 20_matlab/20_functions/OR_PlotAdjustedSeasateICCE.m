function OR_PlotAdjustedSeasateICCE(spatialData,siteData,PlottingOpts,GSHHG,input)

% Deactivate textInterpreter
% set(0, 'DefaulttextInterpreter', 'tex')

% General
dateIn                                          = datestr(PlottingOpts.input.Time2Eval(1),'yyyy_mm_dd-HH_MM');
dateOut                                         = datestr(PlottingOpts.input.Time2Eval(end),'yyyy_mm_dd-HH_MM');
nTimesteps                                      = numel(PlottingOpts.input.Time2Eval);
wamModel                                        = upper(input.model2Eval);

% Identify site names
if iscell(siteData(1).name)
    sites       = [siteData(:).name];
elseif ischar(siteData(1).name)
    sites       = {siteData(:).name};
end

%% :::::::::| Figure Properties |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

fig1                                            = figure;
maximize(gcf)

inpaintNANmethod                                = 5;
smoothFactor                                    = 0.05;
edgeColor                                       = [0,0,0];
fig1.Color                                      = [1 1 1];


%% ---------------- Video settings ------------------------------------------------------------------------------------------------
if PlottingOpts.videoOpts.boolVideo
    exportPath                                  = [PlottingOpts.figureOpts.figPath dateIn '_to_' dateOut '\'];
    if exist(exportPath,'dir') == 0
        mkdir(exportPath)
    end
    PlottingOpts.videoOpts.file                 = VideoWriter([exportPath dateIn '_to_' dateOut '_AdjustedSeastateMap']); %open video file

    PlottingOpts.videoOpts.file.FrameRate       = PlottingOpts.videoOpts.FramesPerSecond;
    open(PlottingOpts.videoOpts.file)
end


%% :::::::::| Loop over all timesteps |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
for i = 1:nTimesteps



    %% --------- Only WAM -------------------------------------------------------------------------------------------------------------
    if strcmp(PlottingOpts.figureOpts.figType,'wam')
        tl = tiledlayout(1,1);
        nexttile
        % Identify valid sites with available scale factors
        siteCell                                    = {siteData(:).scaleData};
        siteLiveCell                                = {siteData(:).finalLiveData};
        siteWamCell                                 = {siteData(:).extractedWAMData};
        validSites                                  = cellfun(@(site) isstruct(site),siteCell);
        validSitesIdx                               = find(validSites);
        siteDeltas                                  = cellfun(@(site) site.delta(1:end),siteCell(validSitesIdx),'UniformOutput',false);
        siteScales                                  = cellfun(@(site) site.scale(1:end),siteCell(validSitesIdx),'UniformOutput',false);
        siteLive                                    = cellfun(@(site) site.(PlottingOpts.liveVariable{:})(1:end),siteLiveCell(validSitesIdx),'UniformOutput',false);
        siteWam                                     = cellfun(@(site) site.(PlottingOpts.plotVariable{:})(1:end),siteWamCell(validSitesIdx),'UniformOutput',false);

        % Max absolute Scale
        maxScale                                    = max(abs(cat(1,siteScales{:,:})));
        maxDelta                                    = max(abs(cat(1,siteDeltas{:,:})));
        maxVar                                      = max([max(cat(1,siteLive{:,:})), max(cat(1,siteWam{:,:}))]);
        % Max scale rounded to .5
        maxScaleLim                                 = ceil( maxScale * 2) / 2;
        maxDeltaLim                                 = ceil( maxDelta * 2) / 2;
        maxVarLim                                   = ceil( maxVar );

        %% Adjusted Seastate
        hold on
        ax1                                         = gca;
        ax1.Color                                   = PlottingOpts.BackGroundColor;
        ax1.FontSize                                = PlottingOpts.Axis_FontSize;
        ax1.XLim                                    = PlottingOpts.input.lonLim;
        ax1.YLim                                    = PlottingOpts.input.latLim;

        ax1.XLabel.Interpreter                      = 'latex';
        ax1.YLabel.Interpreter                      = 'latex';

        ax1.XLabel.String                           = 'Longitude';
        ax1.YLabel.String                           = 'Latitude';

        % Set correct lat/lon axis settings
        lat_lon_proportions(ax1)

        fieldIdx                                    = find(strcmp(PlottingOpts.plotVariable,{spatialData.wamInterpParameters.name}));
        lonInput                                    = spatialData.wamInterpParameters(fieldIdx).lonGrid(:,:,i);
        latInput                                    = spatialData.wamInterpParameters(fieldIdx).latGrid(:,:,i);
        varInput                                    = spatialData.wamInterpParameters(fieldIdx).interp(:,:,i);

        [rowLength, colLength]                      = size(varInput);
        % Smooth data
        varInput                                    = smooth2a(varInput,round(rowLength*smoothFactor),round(colLength*smoothFactor));
        varInput                                    = inpaint_nans(varInput,inpaintNANmethod);

        contourf(ax1,lonInput,latInput,varInput,[PlottingOpts.cbOpts.CBTicks(1:end-1)])

        % Plot coastlines
        for cli = 1:numel(GSHHG.clFieldnames)
            patch(ax1,GSHHG.sets.(GSHHG.clFieldnames{cli}).lon,GSHHG.sets.(GSHHG.clFieldnames{cli}).lat,PlottingOpts.CoastlineColor,'EdgeColor',edgeColor)
        end

        % Plot available measuring sites with text
%         scatter([siteData(validSitesIdx).lon],[siteData(validSitesIdx).lat],150,'k','o','LineWidth',1)
        scatter([siteData(validSitesIdx).lon],[siteData(validSitesIdx).lat],150,'k','x','LineWidth',1)
        text([siteData(validSitesIdx).lon]+0.03,[siteData(validSitesIdx).lat],{siteData(validSitesIdx).name},'FontSize',PlottingOpts.plotTextFontSize,'Color','k','FontWeight','bold')

        cbTickLabels                                    = PlottingOpts.cbOpts.CBTickLabels;
        cbTickLabels                                    = strrep(cbTickLabels,'>','$>$');
        cbTickLabels                                    = strcat(cbTickLabels,'m');
        cb                                              = colorbar('Ticks',PlottingOpts.cbOpts.CBTicks+PlottingOpts.cbOpts.CBTickDelta/2,'TickLabels',cbTickLabels,'Limits',PlottingOpts.cbOpts.CBLimits);                             	% Set colorbar;
%         cb.Label.String                                 = 'VHM0 [m]';
        cb.Label.Interpreter                            = 'latex';
        ax1.CLim                                        = PlottingOpts.cbOpts.CBLimits;
        caxis([PlottingOpts.cbOpts.CBLimits])
        % Set colormap
        colormap(PlottingOpts.cpOpts.ColorM)

        ax1.XTick                                   = [6.5,7.5,8.5];
        ax1.YTick                                   = floor(PlottingOpts.input.latLim(1)):0.5:floor(PlottingOpts.input.latLim(end));
        ax1.XTickLabel                              = strcat(ax1.XTickLabel,'$^{\circ}$E');
        ax1.YTickLabel                              = strcat(ax1.YTickLabel,'$^{\circ}$N');                              

        title(ax1,[wamModel ' $|$ ' datestr(PlottingOpts.input.Time2Eval(i),'yyyy-mm-dd HH:MM')],'FontSize',40,'Interpreter','latex')

        %% --------- Only ADJ -------------------------------------------------------------------------------------------------------------
    elseif strcmp(PlottingOpts.figureOpts.figType,'adj')
        tl = tiledlayout(1,1);
        nexttile
         % Identify valid sites with available scale factors
        siteCell                                    = {siteData(:).scaleData};
        siteLiveCell                                = {siteData(:).finalLiveData};
        siteWamCell                                 = {siteData(:).extractedWAMData};
        validSites                                  = cellfun(@(site) isstruct(site),siteCell);
        validSitesIdx                               = find(validSites);
        siteDeltas                                  = cellfun(@(site) site.delta(1:end),siteCell(validSitesIdx),'UniformOutput',false);
        siteScales                                  = cellfun(@(site) site.scale(1:end),siteCell(validSitesIdx),'UniformOutput',false);
        siteLive                                    = cellfun(@(site) site.(PlottingOpts.liveVariable{:})(1:end),siteLiveCell(validSitesIdx),'UniformOutput',false);
        siteWam                                     = cellfun(@(site) site.(PlottingOpts.plotVariable{:})(1:end),siteWamCell(validSitesIdx),'UniformOutput',false);
        
        hold on
        ax1                                         = gca;
        ax1.Color                                   = PlottingOpts.BackGroundColor;
        ax1.FontSize                                = PlottingOpts.Axis_FontSize;
        ax1.XLim                                    = PlottingOpts.input.lonLim;
        ax1.YLim                                    = PlottingOpts.input.latLim;
        ax1.XTick                                   = [6.5,7.5,8.5];
        ax1.YTick                                   = floor(PlottingOpts.input.latLim(1)):0.5:floor(PlottingOpts.input.latLim(end));
        ax1.XTickLabel                              = strcat(ax1.XTickLabel,'$^{\circ}$E');
        ax1.YTickLabel                              = strcat(ax1.YTickLabel,'$^{\circ}$N');
        ax1.XLabel.Interpreter                      = 'latex';
        ax1.YLabel.Interpreter                      = 'latex';
        ax1.XLabel.String                           = 'Longitude';
        ax1.YLabel.String                           = 'Latitude';
        % Set correct lat/lon axis settings
        lat_lon_proportions(ax1)

        fieldIdx                                    = find(strcmp(PlottingOpts.plotVariable,{spatialData.wamInterpParameters.name}));
        lonInput                                    = spatialData.wamInterpParameters(fieldIdx).lonGrid(:,:,i);
        latInput                                    = spatialData.wamInterpParameters(fieldIdx).latGrid(:,:,i);
        varInput                                    = spatialData.wamInterpParameters(fieldIdx).scaled(:,:,i);

        [rowLength, colLength]                      = size(varInput);
        % Smooth data
        varInput                                    = smooth2a(varInput,round(rowLength*smoothFactor),round(colLength*smoothFactor));
        varInput                                    = inpaint_nans(varInput,inpaintNANmethod);

        contourf(ax1,lonInput,latInput,varInput,[PlottingOpts.cbOpts.CBTicks(1:end-1)])

        % Plot coastlines
        for cli = 1:numel(GSHHG.clFieldnames)
            patch(ax1,GSHHG.sets.(GSHHG.clFieldnames{cli}).lon,GSHHG.sets.(GSHHG.clFieldnames{cli}).lat,PlottingOpts.CoastlineColor,'EdgeColor',edgeColor)
        end

        % Plot available measuring sites with text
%         scatter([siteData(validSitesIdx).lon],[siteData(validSitesIdx).lat],150,'k','o','LineWidth',1)
        scatter([siteData(validSitesIdx).lon],[siteData(validSitesIdx).lat],150,'k','x','LineWidth',1)
        text([siteData(validSitesIdx).lon]+0.03,[siteData(validSitesIdx).lat],{siteData(validSitesIdx).name},'FontSize',PlottingOpts.plotTextFontSize,'Color','k','FontWeight','bold')

        cbTickLabels                                    = PlottingOpts.cbOpts.CBTickLabels;
        cbTickLabels                                    = strrep(cbTickLabels,'>','$>$');
        cbTickLabels                                    = strcat(cbTickLabels,'m');
        cb                                              = colorbar('Ticks',PlottingOpts.cbOpts.CBTicks+PlottingOpts.cbOpts.CBTickDelta/2,'TickLabels',cbTickLabels,'Limits',PlottingOpts.cbOpts.CBLimits);                             	% Set colorbar;
%         cb.Label.String                                 = 'VHM0 [m]';
        cb.Label.Interpreter                            = 'latex';
        ax1.CLim                                        = PlottingOpts.cbOpts.CBLimits;
        caxis([PlottingOpts.cbOpts.CBLimits])
        % Set colormap
        colormap(PlottingOpts.cpOpts.ColorM)

        title(['Adjusted seastate | ' datestr(PlottingOpts.input.Time2Eval(i),'yyyy-mm-dd HH:MM')],'FontSize',40)

        %% --------- WAM and ADJ ----------------------------------------------------------------------------------------------------------
    elseif strcmp(PlottingOpts.figureOpts.figType,'both')
        tl = tiledlayout(1,2);
        % WAM
        nexttile
        hold on
        ax1                                         = gca;
        ax1.Color                                   = PlottingOpts.BackGroundColor;
        ax1.FontSize                                = PlottingOpts.Axis_FontSize;
        ax1.XLim                                    = PlottingOpts.input.lonLim;
        ax1.YLim                                    = PlottingOpts.input.latLim;
        ax1.XLabel.String                           = 'Longitude [°]';
        ax1.YLabel.String                           = 'Latitude [°]';
        % Set correct lat/lon axis settings
        lat_lon_proportions(ax1)

        fieldIdx                                    = find(strcmp(PlottingOpts.plotVariable,{spatialData.wamInterpParameters.name}));
        lonInput                                    = spatialData.wamInterpParameters(fieldIdx).lonGrid(:,:,i);
        latInput                                    = spatialData.wamInterpParameters(fieldIdx).latGrid(:,:,i);
        varInput                                    = spatialData.wamInterpParameters(fieldIdx).interp(:,:,i);
        varInput                                    = inpaint_nans(varInput,inpaintNANmethod);

        contourf(ax1,lonInput,latInput,varInput,[PlottingOpts.cbOpts.CBTicks(1:end-1)])

        caxis([PlottingOpts.cbOpts.CBLimits])

        % Plot coastlines
        for cli = 1:numel(GSHHG.clFieldnames)
            patch(ax1,GSHHG.sets.(GSHHG.clFieldnames{cli}).lon,GSHHG.sets.(GSHHG.clFieldnames{cli}).lat,PlottingOpts.CoastlineColor,'EdgeColor',edgeColor)
        end

        title([PlottingOpts.model2Eval ' | ' datestr(PlottingOpts.input.Time2Eval(i),'yyyy-mm-dd HH:MM')],'FontSize',40)

        % ADJ
        nexttile
        hold on
        ax2                                         = gca;
        ax2.Color                                   = PlottingOpts.BackGroundColor;
        ax2.FontSize                                = PlottingOpts.Axis_FontSize;
        ax2.XLim                                    = PlottingOpts.input.lonLim;
        ax2.YLim                                    = PlottingOpts.input.latLim;
        ax2.XLabel.String                           = 'Longitude [°]';
        ax2.YLabel.String                           = 'Latitude [°]';
        % Set correct lat/lon axis settings
        lat_lon_proportions(ax2)

        fieldIdx                                    = find(strcmp(PlottingOpts.plotVariable,{spatialData.wamInterpParameters.name}));
        lonInput                                    = spatialData.wamInterpParameters(fieldIdx).lonGrid(:,:,i);
        latInput                                    = spatialData.wamInterpParameters(fieldIdx).latGrid(:,:,i);
        varInput                                    = spatialData.wamInterpParameters(fieldIdx).scaled(:,:,i);

        [rowLength, colLength]                      = size(varInput);


        % Smooth data
        varInput                                    = smooth2a(varInput,round(rowLength*smoothFactor),round(colLength*smoothFactor));

        varInput                                    = inpaint_nans(varInput,inpaintNANmethod);

        contourf(ax2,lonInput,latInput,varInput,[PlottingOpts.cbOpts.CBTicks(1:end-1)])

        % Plot coastlines
        for cli = 1:numel(GSHHG.clFieldnames)
            patch(ax2,GSHHG.sets.(GSHHG.clFieldnames{cli}).lon,GSHHG.sets.(GSHHG.clFieldnames{cli}).lat,PlottingOpts.CoastlineColor,'EdgeColor',edgeColor)
        end

        cb                                              = colorbar('Ticks',PlottingOpts.cbOpts.CBTicks+PlottingOpts.cbOpts.CBTickDelta/2,'TickLabels',PlottingOpts.cbOpts.CBTickLabels,'Limits',PlottingOpts.cbOpts.CBLimits);                             	% Set colorbar;
        cb.TickLabels                                   = PlottingOpts.cbOpts.CBTickLabels;

        cb.Label.String                                 = 'VHM0 [m]';
        ax2.CLim                                        = PlottingOpts.cbOpts.CBLimits;
        caxis([PlottingOpts.cbOpts.CBLimits])
        % Set colormap
        colormap(PlottingOpts.cpOpts.ColorM)

        title(['Adjusted seastate | ' datestr(PlottingOpts.input.Time2Eval(i),'yyyy-mm-dd HH:MM')],'FontSize',40)


        %% --------- ADJinfo ----------------------------------------------------------------------------------------------------------
        % Adjusted Seastate Plot with Information regarding parameter values and scale factors for each site
    elseif strcmp(PlottingOpts.figureOpts.figType,'adjInfo')

        % Identify valid sites with available scale factors
        siteCell                                    = {siteData(:).scaleData};
        siteLiveCell                                = {siteData(:).finalLiveData};
        siteWamCell                                 = {siteData(:).extractedWAMData};
        validSites                                  = cellfun(@(site) isstruct(site),siteCell);
        validSitesIdx                               = find(validSites);
        siteDeltas                                  = cellfun(@(site) site.delta(i),siteCell(validSitesIdx));
        siteScales                                  = cellfun(@(site) site.scale(i),siteCell(validSitesIdx));
        siteLive                                    = cellfun(@(site) site.(PlottingOpts.liveVariable{:})(i),siteLiveCell(validSitesIdx));
        siteWam                                     = cellfun(@(site) site.(PlottingOpts.plotVariable{:})(i),siteWamCell(validSitesIdx));

        % Max absolute Scale
        maxScale                                    = max(abs(siteScales));
        maxDelta                                    = max(abs(siteDeltas));
        maxVar                                      = max([siteLive, siteWam]);
        % Max scale rounded to .5
        maxScaleLim                                 = ceil( maxScale * 2) / 2;
        maxDeltaLim                                 = ceil( maxDelta * 2) / 2;
        maxVarLim                                   = ceil( maxVar );

        tl = tiledlayout(2,2);
        nexttile([2 1])
        %% Adjusted Seastate
        hold on
        ax1                                         = gca;
        ax1.Color                                   = PlottingOpts.BackGroundColor;
        ax1.FontSize                                = PlottingOpts.Axis_FontSize;
        ax1.XLim                                    = PlottingOpts.input.lonLim;
        ax1.YLim                                    = PlottingOpts.input.latLim;
        ax1.XLabel.String                           = 'Longitude [°]';
        ax1.YLabel.String                           = 'Latitude [°]';
        % Set correct lat/lon axis settings
        lat_lon_proportions(ax1)

        fieldIdx                                    = find(strcmp(PlottingOpts.plotVariable,{spatialData.wamInterpParameters.name}));
        lonInput                                    = spatialData.wamInterpParameters(fieldIdx).lonGrid(:,:,i);
        latInput                                    = spatialData.wamInterpParameters(fieldIdx).latGrid(:,:,i);
        varInput                                    = spatialData.wamInterpParameters(fieldIdx).scaled(:,:,i);

        [rowLength, colLength]                      = size(varInput);
        % Smooth data
        varInput                                    = smooth2a(varInput,round(rowLength*smoothFactor),round(colLength*smoothFactor));
        varInput                                    = inpaint_nans(varInput,inpaintNANmethod);

        contourf(ax1,lonInput,latInput,varInput,[PlottingOpts.cbOpts.CBTicks(1:end-1)])

        % Plot coastlines
        for cli = 1:numel(GSHHG.clFieldnames)
            patch(ax1,GSHHG.sets.(GSHHG.clFieldnames{cli}).lon,GSHHG.sets.(GSHHG.clFieldnames{cli}).lat,PlottingOpts.CoastlineColor,'EdgeColor',edgeColor)
        end

        % Plot available measuring sites with text
        scatter([siteData(validSitesIdx).lon],[siteData(validSitesIdx).lat],150,PlottingOpts.siteTextColor,'o','LineWidth',1)
        scatter([siteData(validSitesIdx).lon],[siteData(validSitesIdx).lat],150,PlottingOpts.siteTextColor,'x','LineWidth',1)
        text([siteData(validSitesIdx).lon]+0.03,[siteData(validSitesIdx).lat],{siteData(validSitesIdx).name},'FontSize',PlottingOpts.plotTextFontSize,'Color',PlottingOpts.siteTextColor,'FontWeight','bold')

%         % New colorbar
%         cbTicks                                         = [0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.5, 5.0, 6.5, 8, 10];
%         cmNew                                           = linspecer(numel(cbTicks,'sequential'));
%         cbTickLabels                                    = string(num2cell(round(cbTicks,2)));
%         cellfun( @(obj)  [obj 'm']  ,cbTickLabels,'UniformOutput',false)
% 
%         cb                                              = colorbar('Ticks',cbTicks, 'TickLabels',cbTickLabels,'Limits', [cbTicks(1), cbTicks(end)]);
%         caxis([cbTicks(1), cbTicks(end)])
%         colormap(cmNew)

        cb                                              = colorbar('Ticks',PlottingOpts.cbOpts.CBTicks+PlottingOpts.cbOpts.CBTickDelta/2,'TickLabels',PlottingOpts.cbOpts.CBTickLabels,'Limits',PlottingOpts.cbOpts.CBLimits);                             	% Set colorbar;
%         cb.TickLabels                                   = PlottingOpts.cbOpts.CBTickLabels;

        cb.Label.String                                 = 'VHM0 [m]';
        ax1.CLim                                        = PlottingOpts.cbOpts.CBLimits;
        caxis([PlottingOpts.cbOpts.CBLimits])
        % Set colormap
        colormap(PlottingOpts.cpOpts.ColorM)

        title(['Adjusted seastate | ' datestr(PlottingOpts.input.Time2Eval(i),'yyyy-mm-dd HH:MM')],'FontSize',40)

        %% Site Overview with paramater values as bar plot
        nexttile

        % Axes settings
        ax2 = gca;
        hold on
        ax2.Color                                   = PlottingOpts.CoastlineColor;
        ax2.FontSize                                = PlottingOpts.Axis_FontSize;
        ax2.YGrid                                   = 'on';
        ax2.YLim                                    = [0 maxVarLim];
        ax2.YTick                                   = [0:1:maxVarLim];
        ax2.GridColor                               = [1 1 1];

        %% Site Overview with absolute deltas
        nexttile

        ax3 = gca;
        hold on
        ax3.Color                                   = PlottingOpts.CoastlineColor;
        ax3.FontSize                                = PlottingOpts.Axis_FontSize;
        ax3.YGrid                                   = 'on';
        ax3.GridColor                               = [1 1 1];
        ax3.YLim                                    = [-maxDeltaLim, maxDeltaLim];
        ax3.YTick                                   = round(linspace(-maxDeltaLim, maxDeltaLim,5),2);

        %% Site Overview with scale factors
        nexttile

        ax4 = gca;
        hold on
        ax4.Color                                   = PlottingOpts.CoastlineColor;
        ax4.FontSize                                = PlottingOpts.Axis_FontSize;
        ax4.YGrid                                   = 'on';
        ax4.YLabel.String                           = ['Scale Factor [ ]'];
        ax4.GridColor                               = [1 1 1];
        ax4.YLim                                    = [0, maxScaleLim];
        ax4.YTick                                   = 0:0.5:maxScaleLim;

        % Loop over all valid Sites
        for j = validSitesIdx
            currSite                                = {siteData(j).name};
            currLat                                 = siteData(j).lat;
            currLon                                 = siteData(j).lon;
            currLiveVar                             = siteData(j).scaleData.liveVar;
            currWamVar                              = siteData(j).scaleData.wamVar;
            currLive                                = siteData(j).finalLiveData.(currLiveVar)(i);
            currWam                                 = siteData(j).extractedWAMData.(currWamVar)(i);
            currScale                               = siteData(j).scaleData.scale(i);
            currDelta                               = siteData(j).scaleData.delta(i);

            bp                                      = bar(ax2,categorical(currSite),[currLive,currWam]);
            % Barplot settings
            bp(1).FaceColor                         = [222,235,247]/255;
            bp(1).LineWidth                         = 1;
            bp(1).EdgeColor                         = [1 1 1];
            % Barplot wamdata settings
            bp(2).FaceColor                         = [49,130,189]/255;
            bp(2).LineWidth                         = 1;
            bp(2).EdgeColor                         = [1 1 1];

            if currDelta > 0
                deltaColor                          = [0.8902, 0.2902, 0.2000];
            elseif currDelta < 0
                deltaColor                          = [0.5686, 0.8118, 0.3765];
            else
                deltaColor                          = [0 0 0];
            end
            
            delta                                   = bar(ax3,categorical(currSite),currDelta);
            delta.EdgeColor                         = [1 1 1];
%             delta.FaceColor                         = PlottingOpts.siteTextColor;
            delta.FaceColor                         = deltaColor;

            sc                                      = bar(ax4,categorical(currSite),currScale);
            sc.EdgeColor                            = [1 1 1];
%             sc.FaceColor                            = PlottingOpts.siteTextColor;
            sc.FaceColor                            = deltaColor;
        end

        % Legend settings
        leg1                                         = legend(ax2,bp(1:2),{'live','WAM'});
        leg1.TextColor                               = [1 1 1];
        leg1.Color                                   = PlottingOpts.CoastlineColor;
        leg1.LineWidth                               = 1;
        leg1.Location                                = 'eastoutside';

        % Change Rotation to 90° if 0° does not fit
        if ax2.XTickLabelRotation > 0
            ax2.XTickLabelRotation                  = 90;
        end
        if ax4.XTickLabelRotation > 0
            ax4.XTickLabelRotation                  = 90;
        end
        if ax3.XTickLabelRotation > 0
            ax3.XTickLabelRotation                  = 90;
        end
        
        ax2.YLabel.String                           = [currLiveVar ' [m]'];
        ax3.YLabel.String                           = ['$\Delta' currLiveVar ' [m]$'];

%% --------- waminfo ----------------------------------------------------------------------------------------------------------
        % WAM Seastate Plot with Information regarding parameter values and scale factors for each site
    elseif strcmp(PlottingOpts.figureOpts.figType,'wamInfo')

        % Identify valid sites with available scale factors
        siteCell                                    = {siteData(:).scaleData};
        siteLiveCell                                = {siteData(:).finalLiveData};
        siteWamCell                                 = {siteData(:).extractedWAMData};
        validSites                                  = cellfun(@(site) isstruct(site),siteCell);
        validSitesIdx                               = find(validSites);
        siteDeltas                                  = cellfun(@(site) site.delta(1:end),siteCell(validSitesIdx),'UniformOutput',false);
        siteScales                                  = cellfun(@(site) site.scale(1:end),siteCell(validSitesIdx),'UniformOutput',false);
        siteLive                                    = cellfun(@(site) site.(PlottingOpts.liveVariable{:})(1:end),siteLiveCell(validSitesIdx),'UniformOutput',false);
        siteWam                                     = cellfun(@(site) site.(PlottingOpts.plotVariable{:})(1:end),siteWamCell(validSitesIdx),'UniformOutput',false);

        % Max absolute Scale
        maxScale                                    = max(abs(cat(1,siteScales{:,:})));
        maxDelta                                    = max(abs(cat(1,siteDeltas{:,:})));
        maxVar                                      = max([max(cat(1,siteLive{:,:})), max(cat(1,siteWam{:,:}))]);
        % Max scale rounded to .5
        maxScaleLim                                 = ceil( maxScale * 2) / 2;
        maxDeltaLim                                 = ceil( maxDelta * 2) / 2;
        maxVarLim                                   = ceil( maxVar );

        tl = tiledlayout(2,2);
        nexttile([2 1])
        %% Adjusted Seastate
        hold on
        ax1                                         = gca;
        ax1.Color                                   = PlottingOpts.BackGroundColor;
        ax1.FontSize                                = PlottingOpts.Axis_FontSize;
        ax1.XLim                                    = PlottingOpts.input.lonLim;
        ax1.YLim                                    = PlottingOpts.input.latLim;

        ax1.XLabel.Interpreter                      = 'latex';
        ax1.YLabel.Interpreter                      = 'latex';

        ax1.XLabel.String                           = 'Longitude';
        ax1.YLabel.String                           = 'Latitude';

        % Set correct lat/lon axis settings
        lat_lon_proportions(ax1)

        fieldIdx                                    = find(strcmp(PlottingOpts.plotVariable,{spatialData.wamInterpParameters.name}));
        lonInput                                    = spatialData.wamInterpParameters(fieldIdx).lonGrid(:,:,i);
        latInput                                    = spatialData.wamInterpParameters(fieldIdx).latGrid(:,:,i);
        varInput                                    = spatialData.wamInterpParameters(fieldIdx).interp(:,:,i);

        [rowLength, colLength]                      = size(varInput);
        % Smooth data
        varInput                                    = smooth2a(varInput,round(rowLength*smoothFactor),round(colLength*smoothFactor));
        varInput                                    = inpaint_nans(varInput,inpaintNANmethod);

        contourf(ax1,lonInput,latInput,varInput,[PlottingOpts.cbOpts.CBTicks(1:end-1)])

        % Plot coastlines
        for cli = 1:numel(GSHHG.clFieldnames)
            patch(ax1,GSHHG.sets.(GSHHG.clFieldnames{cli}).lon,GSHHG.sets.(GSHHG.clFieldnames{cli}).lat,PlottingOpts.CoastlineColor,'EdgeColor',edgeColor)
        end

        % Plot available measuring sites with text
%         scatter([siteData(validSitesIdx).lon],[siteData(validSitesIdx).lat],150,'k','o','LineWidth',1)
        scatter([siteData(validSitesIdx).lon],[siteData(validSitesIdx).lat],150,'k','x','LineWidth',1)
        text([siteData(validSitesIdx).lon]+0.03,[siteData(validSitesIdx).lat],{siteData(validSitesIdx).name},'FontSize',PlottingOpts.plotTextFontSize,'Color','k','FontWeight','bold')

        cbTickLabels                                    = PlottingOpts.cbOpts.CBTickLabels;
        cbTickLabels                                    = strrep(cbTickLabels,'>','$>$');
        cbTickLabels                                    = strcat(cbTickLabels,'m');
        cb                                              = colorbar('Ticks',PlottingOpts.cbOpts.CBTicks+PlottingOpts.cbOpts.CBTickDelta/2,'TickLabels',cbTickLabels,'Limits',PlottingOpts.cbOpts.CBLimits);                             	% Set colorbar;
%         cb.Label.String                                 = 'VHM0 [m]';
        cb.Label.Interpreter                            = 'latex';
        ax1.CLim                                        = PlottingOpts.cbOpts.CBLimits;
        caxis([PlottingOpts.cbOpts.CBLimits])
        % Set colormap
        colormap(PlottingOpts.cpOpts.ColorM)

        ax1.XTick                                   = [6.5,7.5,8.5];
        ax1.YTick                                   = floor(PlottingOpts.input.latLim(1)):0.5:floor(PlottingOpts.input.latLim(end));
        ax1.XTickLabel                              = strcat(ax1.XTickLabel,'$^{\circ}$E');
        ax1.YTickLabel                              = strcat(ax1.YTickLabel,'$^{\circ}$N');                              

        title(ax1,[wamModel ' $|$ ' datestr(PlottingOpts.input.Time2Eval(i),'yyyy-mm-dd HH:MM')],'FontSize',40,'Interpreter','latex')

        %% Site Overview with paramater values as bar plot
        nexttile

        % Axes settings
        ax2 = gca;
        hold on
        ax2.Color                                   = PlottingOpts.CoastlineColor;
        ax2.FontSize                                = PlottingOpts.Axis_FontSize;
        ax2.YGrid                                   = 'on';
        ax2.YLim                                    = [0 maxVarLim];
        ax2.YTick                                   = [0:1:maxVarLim];
        ax2.YTickLabel                              = num2str(ax2.YTick','%.2f');
        ax2.GridColor                               = [1 1 1];

        %% Site Overview with absolute deltas
        nexttile

        ax3 = gca;
        hold on
        ax3.Color                                   = PlottingOpts.CoastlineColor;
        ax3.FontSize                                = PlottingOpts.Axis_FontSize;
        ax3.YGrid                                   = 'on';
        ax3.YLabel.Interpreter                      = 'latex';
        ax3.GridColor                               = [1 1 1];
        ax3.YLim                                    = [-maxDeltaLim, maxDeltaLim];
        ax3.YTick                                   = round(linspace(-maxDeltaLim, maxDeltaLim,7),2);
        ax3.YTickLabel                              = num2str(ax3.YTick','%.2f');

        %% Site Overview with scale factors
%         nexttile

%         ax4 = gca;
%         hold on
%         ax4.Color                                   = PlottingOpts.CoastlineColor;
%         ax4.FontSize                                = PlottingOpts.Axis_FontSize;
%         ax4.YGrid                                   = 'on';
% %         ax4.YLabel.String                           = ['$\frac{ Hs_{inSitu} }{ Hs_{CWAM} }$'];
%         ax4.YLabel.String                           = ['Scale factor [ ]'];
%         ax4.YLabel.Interpreter                      = 'latex';
%         ax4.GridColor                               = [1 1 1];
%         ax4.YLim                                    = [0, maxScaleLim];
%         ax4.YTick                                   = 0:0.5:maxScaleLim;
%         ax4.YTickLabel                              = num2str(ax4.YTick','%.2f');

        % Loop over all valid Sitesc
        for j = validSitesIdx
            currSite                                = siteData(j).name;
            currLat                                 = siteData(j).lat;
            currLon                                 = siteData(j).lon;
            currLiveVar                             = siteData(j).scaleData.liveVar;
            currWamVar                              = siteData(j).scaleData.wamVar;
            currLive                                = siteData(j).finalLiveData.(currLiveVar)(i);
            currWam                                 = siteData(j).extractedWAMData.(currWamVar)(i);
            currScale                               = siteData(j).scaleData.scale(i);
            currDelta                               = siteData(j).scaleData.delta(i);

            bp                                      = bar(ax2,categorical(currSite),[currLive,currWam]);
            % Barplot settings
            bp(1).FaceColor                         = [222,235,247]/255;
            bp(1).LineWidth                         = 1;
            bp(1).EdgeColor                         = [1 1 1];
            % Barplot wamdata settings
            bp(2).FaceColor                         = [49,130,189]/255;
            bp(2).LineWidth                         = 1;
            bp(2).EdgeColor                         = [1 1 1];

            if currDelta > 0
                deltaColor                          = [0.8902, 0.2902, 0.2000];
            elseif currDelta < 0
                deltaColor                          = [0.5686, 0.8118, 0.3765];
            else
                deltaColor                          = [0 0 0];
            end
            
            delta                                   = bar(ax3,categorical(currSite),currDelta);
            delta.EdgeColor                         = [1 1 1];
%             delta.FaceColor                         = PlottingOpts.siteTextColor;
            delta.FaceColor                         = deltaColor;

%             sc                                      = bar(ax4,categorical(currSite),currScale);
%             sc.EdgeColor                            = [1 1 1];
%             sc.FaceColor                            = PlottingOpts.siteTextColor;
%             sc.FaceColor                            = deltaColor;
        end

        % Legend settings
        leg1                                         = legend(ax2,bp(1:2),{'in situ',wamModel});
        leg1.TextColor                               = [1 1 1];
        leg1.Color                                   = PlottingOpts.CoastlineColor;
        leg1.LineWidth                               = 1;
        leg1.Location                                = 'eastoutside';

        % Change Rotation to 90° if 0° does not fit
        if ax2.XTickLabelRotation > 0
            ax2.XTickLabelRotation                  = 90;
        end
%         if ax4.XTickLabelRotation > 0
%             ax4.XTickLabelRotation                  = 90;
%         end
        if ax3.XTickLabelRotation > 0
            ax3.XTickLabelRotation                  = 90;
        end
        
        ax2.YLabel.String                           = ['Hs [m]'];
        ax2.YLabel.Interpreter                      = 'latex';
        ax3.YLabel.String                           = ['$\Delta$Hs [m]'];

    end



    % Draw figure for video
    if PlottingOpts.videoOpts.boolVideo
        drawnow
        frame = getframe(gcf);
        writeVideo(PlottingOpts.videoOpts.file, frame);
    end

end

%% ---------------- Video settings ------------------------------------------------------------------------------------------------
% Close and save video file
if PlottingOpts.videoOpts.boolVideo
    close (PlottingOpts.videoOpts.file)
end

%% ---------------- Figure settings ------------------------------------------------------------------------------------------------
% Export figure if boolean is true
if PlottingOpts.figureOpts.boolSaveFig && PlottingOpts.figureOpts.boolAdjustedSeastatePlot
    
    name                            = ['AdjustedSeastate_' PlottingOpts.figureOpts.figType];
    figPath                         = PlottingOpts.figureOpts.figPath;
    contentType                     = PlottingOpts.figureOpts.contentType;
    resolution                      = PlottingOpts.figureOpts.resolution;

    OR_exportFigure(fig1,figPath,contentType,resolution,name,dateIn,dateOut)
    
%     exportPath = [PlottingOpts.figureOpts.figPath dateIn '_to_' dateOut '\'];
% 
%     if exist(exportPath,'dir') == 0
%         mkdir(exportPath)
%     end
%     exportgraphics(figure(fig1.Number),[exportPath 'AdjustedSeastate.png'],'ContentType',PlottingOpts.figureOpts.contentType,'Resolution',PlottingOpts.figureOpts.resolution)

end

end