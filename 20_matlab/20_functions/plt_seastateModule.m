function [lonInput,latInput,varInputScaledFinal,fig1] = plt_seastateModule(input,GSHHG,spatialData,siteData,plotType,statType,cbType,gridType,cmPath,cmName,cmStatsName,cmFlip)
%% :::::::::| Description |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% Function to create adjusted seastate overview maps based on wam and insitu data
% Only for one timestep possible, video creation disabled
% Choose between following options:
% 'wam': Show only initial wam data
% 'adj': Show only adjusted seastate map
% 'both': Show both datasets
% 'wamInfo': WAM Seastate Plot with Information regarding parameter values and scale factors for each site
% 'adjInfo': Adjusted Seastate Plot with Information regarding parameter values and scale factors for each site


%% :::::::::| Figure Properties |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
%% BSH screensize
% bshNorm = [0.0015625   0.0027778     0.99688     0.97639];
% bshPixOld  = [5     5  2552  1406]; % Wilms Monitor
% bshCMOld   = [0.105833     0.105833      67.5217      37.2004];
bshPix    = [5     5  1016   734];
bshCM     = [0.105833     0.105833      26.8817      19.4204];
%% Screensize LuFI
% lufiPix = [1          41        1920         963];
lufiCM  = [0    1.0583   50.8000   25.4794];

% Open figure and suppress graphical output
fig1                                = figure('visible','off');
% fig1                                = figure('visible','on');
% Maximize figure
% set(gcf,'units','normalized','outerposition',[0 0 1 1])
set(fig1,'units','centimeters','outerposition',bshCM)
pause(0.01)

% Set figure units to pixels
% fig1.Units                          = 'pixels';
% fig1.Position                       = bshPix;
% % Get figSize in 'pixels'
% figSize                             = fig1.Position;
% % Get monitor proportion (width/height)
% figProp                             = figSize(3) / figSize(4);
% % Ideal proportion (dev environment)
% % propIdeal                           = 1.829;
% propIdeal                            = 1.9938;
% % If figProp is not between 99% - 101% of propIdeal, adjust proportions!
% if ~(figProp > 0.99*propIdeal && figProp < 1.01*propIdeal)
%     figSize(3) = figSize(4) * propIdeal;
% end

% Set adjusted figSize
% fig1.Position                       = figSize;

% Set figure units back to normalized
fig1.Units                          = 'normalized';

% inpaint_nans function interpoaltes & extrapolates nan elements in 2d array
% Method <5>: Average of the 8 nearest neighbours to any element
% D'Errico, 2010: https://de.mathworks.com/matlabcentral/fileexchange/4551-inpaint_nans?s_tid=srchtitle
inpaintNANmethod                    = 4;
% Factor to calculate number of points used to smooth rows/columns of grid -> n = round( smoothFactor * length(rows) )
% Reeves, 2007: https://de.mathworks.com/matlabcentral/fileexchange/23287-smooth2a
smoothFactor                        = 0.05;
fig1.Color                          = [1,1,1];
edgeColor                           = [0,0,0];
coastColor                          = [0.65, 0.65, 0.65];
siteTextColorA                      = [0,0,0];
siteTextColorB                      = [1,1,1];
siteTextColorNoDataA                = [0.25,0.25,0.25];
siteTextColorNoDataB                = [0.75,0.75,0.75];
% siteTextColorA                      = [35,132,67]/255;
% siteTextColorB                      = [166,217,106]/255;
% siteTextColorNoDataA                = [0.4,0.4,0.4];
% siteTextColorNoDataB                = [0.8,0.8,0.8];
% siteTextColorA                      = [166,217,106]/255;
% siteTextColorA                      = [0,0,0];
% siteTextColorA                      = [178,24,43]/255;
% siteTextColorB                      = [1,1,1];
siteMarkerSize                      = input.siteMarkerSize;
% Fontsize axis
fsAxis                              = input.fsAxis;
% Fontsize site text
fsSites                             = input.fsSites;
% Fontsize title
fsTitle                             = input.fsTitle;


%% :::::::::| Identify input parameters |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% Hs insitu parameter name
var2ScaleInsitu                     = {'VHM0'};
% Hs wam parameter name
var2ScaleWam                        = {'sign_whight'};

% Cell of scale data for each site
siteCell                            = {siteData(:).scaleData};
% Check, if scaleData struct is available for each site
validSitesIdx                       = find(cellfun(@(site) isstruct(site),siteCell));
validSiteNames                      = [siteData(validSitesIdx).name];

% Cell containing timetables for insitu vars
siteInsituCell                      = {siteData(:).finalLiveData};
insituVarsInit                      = cellfun( @(site) site.(var2ScaleInsitu{:}),siteInsituCell,'UniformOutput',false);
insituVars                          = [insituVarsInit{:}];
% Cell containing timetables for wam vars
siteWamCell                         = {siteData(:).extractedWAMData};
wamVarsInit                         = cellfun( @(site) site.(var2ScaleWam{:}),siteWamCell,'UniformOutput',false);
wamVars                             = [wamVarsInit{:}];
% Delta and Scale values
siteDeltas                          = cellfun( @(site) site.delta,siteCell(validSitesIdx));
siteScales                          = cellfun( @(site) site.scale,siteCell(validSitesIdx));
siteDeltasPercentages               = cellfun( @(site) (1-site.scale^-1)*100,siteCell(validSitesIdx));

%% Prepare plotting data
% Identify index of struct array for given wam-parameter (in case multiple parameter
wamIdx                              = find(strcmp(var2ScaleWam,{spatialData.wamInterpParameters.name}));
% lon/lat grid input for plots
lonInput                            = spatialData.wamInterpParameters(wamIdx).lonGrid;
latInput                            = spatialData.wamInterpParameters(wamIdx).latGrid;
% Variable grid input wam/insitu for plots
varInputInit                        = spatialData.wamInterpParameters(wamIdx).interp;
varInputScaledInit                  = spatialData.wamInterpParameters(wamIdx).scaled;
% Identify size of var input
[rowLength, colLength]              = size(varInputInit);
% Smooth data and "inpaint" nan values as defined before
varInputSmoothed                    = smooth2a(varInputInit, round(rowLength*smoothFactor), round(colLength*smoothFactor));
varInputFinal                       = inpaint_nans(varInputSmoothed,inpaintNANmethod);
% Adjusted seastate variable
varInputScaledSmoothed              = smooth2a(varInputScaledInit, round(rowLength*smoothFactor), round(colLength*smoothFactor));
varInputScaledFinal                 = inpaint_nans(varInputScaledSmoothed,inpaintNANmethod);

% Determine maximum occured values for wam/insitu parameter
maxVarScaled                        = ceil( max(varInputScaledFinal,[],'all') );
maxVarWAM                           = ceil( max(varInputFinal,[],'all') );
% Max absolute Scale
maxScale                            = max(abs(siteScales));
maxDelta                            = max(abs(siteDeltas));
maxVar                              = max([maxVarWAM,maxVarScaled]);

% Max scale rounded to .5
maxScaleLim                         = ceil( maxScale * 2) / 2;
maxDeltaLim                         = ceil( maxDelta * 2) / 2;
maxVarLim                           = ceil( maxVar );

% For automatic scaling of colorbar axis
if strcmpi(cbType,'auto')
    % Levels for contourf plot
    if maxVar < 3
        nStep                       = 0.25;
        nLevels                     = maxVar*(nStep^-1)+1;
    elseif maxVar < 5 && maxVar >= 3
        nStep                       = 0.5;
        nLevels                     = maxVar*(nStep^-1)+1;
    else
        nStep                       = 1;
        nLevels                     = maxVar*(nStep^-1)+1;
    end
    % Set levels for contour plot
    cfLevels                        = linspace(0,maxVar,nLevels);

    %% For 'fixed' or no input
else

    if input.addFig == 0
        % Set levels for contour plot
        cfLevels                        = [0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.5, 5.0, 6.5, 8.0, 10];
        % Ticks for colorbar axis
        nLevels                         = length(cfLevels);

        %% Colormap settings
        % Import "scientific colormap" from Crameri et al. (2020), https://www.fabiocrameri.ch/colourmaps/
        % or use colormaps from cmocean toolbox http://dx.doi.org/10.5670/oceanog.2016.66

        % Names of sequential cm of cmOcean toolbox
        cmOceanSequentialNames = {'thermal','haline','solar','ice','gray','oxy','deep','dense','algae','matter','turbid','speed','amp','tempo','rain'};

        % cmocean toolbox
        if ismember(cmName,cmOceanSequentialNames)
            % Define Colormap settings
            cmInit                          = cmocean(cmName);
            % cmDeepInit                          = cmocean('rain');


            % Scientific colormaps
        else
            cmStruct                        = load(fullfile(cmPath,[cmName '.mat']));
            cmFN                            = fieldnames(cmStruct);
            cmInit                          = cmStruct.(cmFN{1});
        end

        % Final colormap
        cmFin                               = cmInit( round(linspace(1, size(cmInit,1), nLevels-1)), : );
        % Flip colormap?
        if strcmpi(cmFlip,'flip')
            cmFin                           = flipud(cmFin);
        end

    elseif input.boolHighResCM && input.addFig

        %% 1. Colormap levels
        % upper limit
        uL = input.highResUpLimit;
        if uL > 0.5 && uL < 3
            cf1Levels = [0, 0.5:0.25:uL];
        else
            error('Upper Hs limit for figure with refined CM must be between 0.5m and 3m!')
        end

        % Amount of color levels for cf1
        n1Levels                    = length(cf1Levels);

        %% 2. Colormap levels
        % Discretize levels between 0.5 and 2.5 with x=0.5, >2.5 with nonlinear scale
        if uL > 0.5 && uL < 2.5
            cf2Levels               = [uL+0.5:0.5:2.5, 3.5, 5, 6.5, 8, 10];
        elseif uL >= 2.5
            cf2Levels               = [3.5, 5, 6.5, 8, 10];
        end
        % Amount of color levels for cf2
        n2Levels                    = length(cf2Levels);

        %% Colormap color vectors
        % 1. CM: White -> Green (manual defined with help from www.colorbrewer2.org)
        cm1init                         = [255,255,229; 247,252,185; 217,240,163; 173,221,142; 120,198,121; 65,171,93; 35,132,67; 0,104,55] / 255;
        % Interpolate to levels
        % levels - 1, since only colors between 0 and uL are considered
        cm1                             = interp1(cm1init, linspace(1,size(cm1init,1),n1Levels-1));

        % 2. CM
        % Colormap name
        cmName                          = 'lipariAdj';
        cm2Struct                       = load(fullfile(cmPath,[cmName '.mat']));
        cm2FN                           = fieldnames(cm2Struct);
        cm2init                         = cm2Struct.(cm2FN{1});
        % Interpolate to levels
        % levels not -1,  since color directly after uL has to be considered
        cm2                             = interp1(cm2init, linspace(1,size(cm2init,1),n2Levels));

        % Final levels vector
        cfLevels                        = [cf1Levels, cf2Levels];
        % Final colormap matrix
        cmFin                           = [cm1;cm2];

    else
        error(['Wrong input for boolHighResCM: <' num2str(input.boolHighResCM) '>! Must either be 0 or 1.'])
    end

end

% Identify site colors
insituColors    = zeros(length(insituVars),3);
wamColors       = zeros(length(wamVars),3);

for sci = 1:numel(insituVars)
    currInsituIdx   = find(insituVars(sci) < cfLevels);
    currWamIdx      = find(wamVars(sci) < cfLevels);
    % Insitu
    if isempty(currInsituIdx)
        insituColors(sci,:) = cmFin(end,:);
    else
        cfIdx = currInsituIdx(1);
        if cfIdx > size(cmFin,1)
            cfIdx = size(cmFin,1);
        end
        insituColors(sci,:) = cmFin(cfIdx,:);
    end
    % Wam
    if isempty(currWamIdx)
        wamColors(sci,:) = cmFin(end,:);
    else
        cfIdx = currWamIdx(1);
        if cfIdx > size(cmFin,1)
            cfIdx = size(cmFin,1);
        end
        wamColors(sci,:) = cmFin(cfIdx,:);
    end
end

%% Load colormap for visualization of statistics
cmStatsStruct   = load(fullfile(cmPath,[cmStatsName '.mat']));
cmStatsFN       = fieldnames(cmStatsStruct);
cmStats         = cmStatsStruct.(cmStatsFN{1});

% Initialize parameters
[sitesWam, sitesInsitu, nearIdxWAM, nearIdxInsitu] = deal( zeros(length(validSitesIdx),1) );
[textColorWAM,textColorInsitu,siteTextColorNoData] = deal( zeros(length(validSitesIdx),3) );

% Identification of threshold for different site color based on colormap type
if input.addFig
    threshSiteCol = n1Levels-1;
else
    threshSiteCol = round(numel(cfLevels)/3);
end

for si = 1:length(validSitesIdx)
    % Identify parameter values for sites (WAM & insitu)
    sitesWam(si) = siteData(validSitesIdx(si)).extractedWAMData.(var2ScaleWam{:});
    sitesInsitu(si) = siteData(validSitesIdx(si)).finalLiveData.(var2ScaleInsitu{:});

    % Find nearest level
    [~,nearIdxWAM(si)] = min(abs(cfLevels - sitesWam(si)));
    [~,nearIdxInsitu(si)] = min(abs(cfLevels - sitesInsitu(si)));

    % Set text color for first half of colormap to black and for second half to white
    if nearIdxWAM(si) > threshSiteCol
        textColorWAM(si,:) = siteTextColorB;
        % NoData color based on wam, since no insitu data to be ordered
        siteTextColorNoData(si,:) = siteTextColorNoDataB;
    elseif nearIdxWAM(si) <= threshSiteCol
        textColorWAM(si,:) = siteTextColorA;
        siteTextColorNoData(si,:) = siteTextColorNoDataA;
    end

    if nearIdxInsitu(si) > threshSiteCol
        textColorInsitu(si,:) = siteTextColorB;
    elseif nearIdxInsitu(si) <= threshSiteCol
        textColorInsitu(si,:) = siteTextColorA;
    end



end


%% :::::::::| Only WAM |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
switch plotType

    case 'wam'
        %% :::::::::| Only WAM |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        % Set figure layout
        tiledlayout(1,1);
        nexttile
        hold on
        ax1 = gca;
        % Spatial plot
        plt_spatialPlot(ax1,input,cmFin,lonInput,latInput,varInputFinal,cfLevels,GSHHG,fsAxis,coastColor,edgeColor,gridType);
        % Set title
        title([upper(input.wamModel2Eval) ' | ' datestr(input.time2Eval,'yyyy-mm-dd HH:MM')],'FontSize',fsTitle)

    case 'adj'
        %% :::::::::| Only adjusted  |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        % Set figure layout
        tiledlayout(1,1);
        nexttile
        hold on
        ax2 = gca;
        ax2 = plt_spatialPlot(ax2,input,cmFin,lonInput,latInput,varInputScaledFinal,cfLevels,GSHHG,fsAxis,coastColor,edgeColor,gridType);
        % Set title
        title(['Adj. | ' datestr(input.time2Eval,'yyyy-mm-dd HH:MM')],'FontSize',fsTitle)

    case 'both'
        %% :::::::::| Both (WAM & Scaled) |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        % Set figure layout
        tiledlayout(1,2);
        %% --------- WAM  ----------------------------------------------------------------------------------------------------------
        nexttile
        hold on
        ax1 = gca;
        % Spatial plot
        plt_spatialPlot(ax1,input,cmFin,lonInput,latInput,varInputFinal,cfLevels,GSHHG,fsAxis,coastColor,edgeColor,gridType);
        % Set title
        title([upper(input.wamModel2Eval) ' | ' datestr(input.time2Eval,'yyyy-mm-dd HH:MM')],'FontSize',fsTitle)
        %% --------- Adjusted  ----------------------------------------------------------------------------------------------------------
        nexttile
        hold on
        ax2 = gca;
        % Spatial plot
        plt_spatialPlot(ax2,input,cmFin,lonInput,latInput,varInputScaledFinal,cfLevels,GSHHG,fsAxis,coastColor,edgeColor,gridType);
        % Set title
        title(['Adj. | ' datestr(input.time2Eval,'yyyy-mm-dd HH:MM')],'FontSize',fsTitle)

    case 'wamInfo'
        %% :::::::::| WAM with detailed information |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        tiledlayout(3,2);
        nexttile([3 1])
        hold on
        ax1 = gca;
        % Spatial plot
        plt_spatialPlot(ax1,input,cmFin,lonInput,latInput,varInputFinal,cfLevels,GSHHG,fsAxis,coastColor,edgeColor,gridType);
        % Plot site indication
        plt_plotSites(siteData,validSitesIdx,siteMarkerSize,textColorWAM,fsAxis)
        % Set title
        title([upper(input.wamModel2Eval) ' | ' datestr(input.time2Eval,'yyyy-mm-dd HH:MM')],'FontSize',fsTitle)
        % Plot statistics from insitu / Wam comparison (3 free tiles in tiled layout mandatory)
        [ax2,ax3,ax4] = plt_insitu_wam_Statistics(coastColor,fsAxis,maxVarLim,maxDeltaLim,siteData,maxScaleLim,validSitesIdx);

    case 'adjInfo'
        %% :::::::::| Scaled with detailed information |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        % tiledlayout(3,2);
        % nexttile([3 1])
        subplot(3,2,[1,5])
        % subplot(3,5,[1,13])
        % subplot(3,6,[1,16])
        % subplot(3,7,[1,18])
        hold on
        ax1 = gca;
        %% Spatial plot
        plt_spatialPlot(ax1,input,cmFin,lonInput,latInput,varInputScaledFinal,cfLevels,GSHHG,fsAxis,coastColor,edgeColor,gridType);
        %% Plot site indication
        plt_plotSites(siteData,validSitesIdx,siteMarkerSize,textColorInsitu,siteTextColorNoData,fsSites,siteScales)
        %% Set title
        title([datestr(input.time2Eval,'yyyy-mm-dd HH:MM') ' (UTC)'],'FontSize',fsTitle,'Interpreter','latex')

        %% Barplot Hs insitu/wam (black/white)
        % Set Background color for statistics
        backGroundColor = [1,1,1];
        % nexttile
        subplot(3,2,2)
        % subplot(3,5,[4,5])
        % subplot(3,6,[5,6])
        % subplot(3,7,[5,7])
        plt_insituWam_barPlot(backGroundColor,fsAxis,fsTitle,validSiteNames,input.wamModel2Eval,insituVars,wamVars);
        ax2             = gca;
        %% Absolute Differences
        cmDeltas        = cmStats;
        % nexttile
        subplot(3,2,4)
        % subplot(3,5,[9,10])
        % subplot(3,6,[11,12])
        % subplot(3,7,[12,14])
        % Y-Limits
        yLims           = [-0.5,0.5];
        plt_siteDeltasAbsolute(backGroundColor,cmDeltas,fsAxis,fsTitle,validSiteNames,siteDeltas,yLims,statType);
        ax3             = gca;
        %% Relative Differences
        yLimsPerc       = yLims*100;
        % nexttile
        subplot(3,2,6)
        % subplot(3,5,[14,15])
        % subplot(3,6,[17,18])
        % subplot(3,7,[19,21])
        plt_siteDeltasRelative(backGroundColor,cmDeltas,fsAxis,fsTitle,validSiteNames,siteDeltasPercentages,yLimsPerc,statType);
        ax4             = gca;

        %% Set figure position
        % fig1.Position   = [1.0000    0.0370    1.0000    0.8917];
        % 2023/10/09: 3/2 subplot (BSH Screensize)
        %   ax1.Position    =  [0.1300    0.1100    0.3115    0.8150];
        %   ax2.Position    =  [0.5703    0.7093    0.3347    0.1975];
        %   ax3.Position    =  [0.5703    0.4096    0.3347    0.1975];
        %   ax4.Position    =  [0.5703    0.1100    0.3347    0.1975];
        % 2023/10/09: 3/5 subplot (BSH Screensize)
        %   ax1.Position    =  [0.1300    0.1100    0.4262    0.8150];
        %   ax2.Position    =  [0.6184    0.7093    0.2866    0.2157];
        %   ax3.Position    =  [0.6184    0.4096    0.2866    0.2157];
        %   ax4.Position    =  [0.6184    0.1100    0.2866    0.2157];
        % LuFI screensize
        % Settings 17.11.
        % Top right plot Oberkante: 0.9079
        ax1.Position = [0.1460    0.2537    0.3360    0.6542];
        ax2.Position = [0.5703    0.7220    0.3295    0.1859];
        ax3.Position = [0.5703    0.4224    0.3295    0.1859];
        ax4.Position = [0.5703    0.1228    0.3295    0.1859];

        % Adjust horizontal start of Barplot legend (1% of total axes width)
        ax2.Legend.Position(1) = ax2.Position(1) + ax2.Position(3) + 0.01*ax2.Position(3);

        % ax1.Position    = [0.0986    0.1100    0.3218    0.7986];
        % ax2.Position    = [0.5190    0.7269    0.3801    0.1817];
        % ax3.Position    = [0.5190    0.4185    0.3801    0.1817];
        % ax4.Position    = [0.5190    0.1100    0.3801    0.1817];

        %% Set infobox
        pause(0.5)
        [~] = plt_infoBox(ax1,input);


        %% Infoboxes with warnings in case deviations are too large or mandatory sites/area are missing
        % Initialize warning bool vector (2 entries for deviation and missing crucial sites)
        warnBoolVec = zeros(2,1);

        % If no data is available for either (FN1,NO1,AV0) or (FN3,BUD) or (NOO,LTH,HEO,ELB)
        % Define elemantary site groups, from which data from at least one site must be available. Otherwise create warning infobox
        elemSites1 = {'FN1','NO1','AV0'};
        elemSites2 = {'FN3'};
        elemSites3 = {'BUD'};
        elemSites4 = {'NOO','LTH','HEO','ELB'};

        % Cell containing all elemSite cells
        elemSites   = {elemSites1,elemSites2,elemSites3,elemSites4};
        % Initialize counter
        elemCounter = 0;
        % Initialize missingVec indicating missing information. One value (1 / 0) for each group, 1 indicates no data
        missingVec  = zeros(numel(elemSites),0);

        % Loop over all cells in elemSites
        for eSi = 1:numel(elemSites)
            % Increase counter
            elemCounter             = elemCounter + 1;
            % Index whether current elemSites is in validSiteNames cellstring
            [eS_Bool,eS_Idx]        = ismember(elemSites{eSi},validSiteNames);
            % currES                  = elemSites{eSi}(eS_Bool);
            % Scale data for current group
            currGroupScales         = cellfun( @(a) a.scale, siteCell(eS_Idx),'UniformOutput',true);
            % Add information to missingVec
            missingVec(elemCounter) = all( isnan(currGroupScales) );

        end

        % Set first entry for high deviation to true
        if any(abs(siteDeltasPercentages) > input.warningThresh)
            warnBoolVec(1) = 1;
        end
        % Set second entry for missing sites to true
        if any(missingVec)
            warnBoolVec(2) = 1;
        end

        %% Plot warning boxes
        % For missing crucial sites
        if any(missingVec)
            [~] = plt_missingCrucialSitesWarningBox(ax1,input,warnBoolVec);
        end
        % For too high deviations
        if any(abs(siteDeltasPercentages) > input.warningThresh)
            [~] = plt_highDeviationWarningBox(ax1,input,validSiteNames,siteDeltasPercentages);
        end
        
end


end