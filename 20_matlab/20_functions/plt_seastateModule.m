function [lonInput,latInput,varInputScaledFinal,fig1] = plt_seastateModule(input,GSHHG,spatialData,siteData,plotType,cbType,gridType,cmPath,cmName,cmFlip)
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

% Open figure and suppress graphical output
fig1                                = figure('visible','off');
% fig1                                = figure('visible','on');

% inpaint_nans function interpoaltes & extrapolates nan elements in 2d array
% Method <5>: Average of the 8 nearest neighbours to any element
% D'Errico, 2010: https://de.mathworks.com/matlabcentral/fileexchange/4551-inpaint_nans?s_tid=srchtitle
inpaintNANmethod                    = 4;
% Factor to calculate number of points used to smooth rows/columns of grid -> n = round( smoothFactor * length(rows) )
% Reeves, 2007: https://de.mathworks.com/matlabcentral/fileexchange/23287-smooth2a
smoothFactor                        = 0.05;
fig1.Color                          = [1,1,1];
edgeColor                           = [0,0,0];
coastColor                          = [0.25, 0.25, 0.25];
% siteTextColorA                      = [0,0,0];
siteTextColorA                      = [178,24,43]/255;
siteTextColorB                      = [1,1,1];
siteMarkerSize                      = 50;
% Fontsize axis 
fsAxis                              = 20;
% Fontsize site text
fsSites                             = 14;
% Fontsize title
fsTitle                             = 40;


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
    % Ticks for colorbar axis
    cbTicks                         = 0:nStep:maxVar;
    % Set levels for contour plot
    cfLevels                        = linspace(0,maxVar,nLevels);

   %% For 'fixed' or no input
else
    % Set levels for contour plot
    cfLevels                        = [0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.5, 5.0, 6.5, 8.0, 10];
    % Ticks for colorbar axis
    cbTicks                         = cfLevels;
    nLevels                         = length(cfLevels);
end

%% Colormap settings
% Import "scientific colormap" from Crameri et al. (2020), https://www.fabiocrameri.ch/colourmaps/
% or use colormaps from cmocean toolbox http://dx.doi.org/10.5670/oceanog.2016.66

% cmocean toolbox
if strcmp(cmName,'deep')
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

% Initialize parameters
[sitesWam, sitesInsitu, nearIdxWAM, nearIdxInsitu] = deal( zeros(length(validSitesIdx),1) );
[textColorWAM,textColorInsitu] = deal( zeros(length(validSitesIdx),3) );

for si = 1:length(validSitesIdx)
    % Identify parameter values for sites (WAM & insitu)
    sitesWam(si) = siteData(validSitesIdx(si)).extractedWAMData.(var2ScaleWam{:});
    sitesInsitu(si) = siteData(validSitesIdx(si)).finalLiveData.(var2ScaleInsitu{:});

    % Find nearest level
    [~,nearIdxWAM(si)] = min(abs(cfLevels - sitesWam(si)));
    [~,nearIdxInsitu(si)] = min(abs(cfLevels - sitesInsitu(si)));

    % Set text color for first half of colormap to black and for second half to white
    if nearIdxWAM(si) > round(numel(cfLevels)/2)
        textColorWAM(si,:) = siteTextColorB;
    elseif nearIdxWAM(si) <= round(numel(cfLevels)/2)
        textColorWAM(si,:) = siteTextColorA;
    end

    if nearIdxInsitu(si) > round(numel(cfLevels)/2)
        textColorInsitu(si,:) = siteTextColorB;
    elseif nearIdxInsitu(si) <= round(numel(cfLevels)/2)
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
        plt_spatialPlot(ax1,input,cmFin,lonInput,latInput,varInputFinal,cfLevels,GSHHG,cbTicks,fsAxis,coastColor,edgeColor,gridType);
        % Set title
        title([upper(input.wamModel2Eval) ' | ' datestr(input.time2Eval,'yyyy-mm-dd HH:MM')],'FontSize',fsTitle)

    case 'adj'
        %% :::::::::| Only adjusted  |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        % Set figure layout
        tiledlayout(1,1);
        nexttile
        hold on
        ax2 = gca;
        ax2 = plt_spatialPlot(ax2,input,cmFin,lonInput,latInput,varInputScaledFinal,cfLevels,GSHHG,cbTicks,fsAxis,coastColor,edgeColor,gridType);
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
        plt_spatialPlot(ax1,input,cmFin,lonInput,latInput,varInputFinal,cfLevels,GSHHG,cbTicks,fsAxis,coastColor,edgeColor,gridType);
        % Set title
        title([upper(input.wamModel2Eval) ' | ' datestr(input.time2Eval,'yyyy-mm-dd HH:MM')],'FontSize',fsTitle)
        %% --------- Adjusted  ----------------------------------------------------------------------------------------------------------
        nexttile
        hold on
        ax2 = gca;
        % Spatial plot
        plt_spatialPlot(ax2,input,cmFin,lonInput,latInput,varInputScaledFinal,cfLevels,GSHHG,cbTicks,fsAxis,coastColor,edgeColor,gridType);
        % Set title
        title(['Adj. | ' datestr(input.time2Eval,'yyyy-mm-dd HH:MM')],'FontSize',fsTitle)

    case 'wamInfo'
        %% :::::::::| WAM with detailed information |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        tiledlayout(3,2);
        nexttile([3 1])
        hold on
        ax1 = gca;
        % Spatial plot
        plt_spatialPlot(ax1,input,cmFin,lonInput,latInput,varInputFinal,cfLevels,GSHHG,cbTicks,fsAxis,coastColor,edgeColor,gridType);
        % Plot site indication
        plt_plotSites(siteData,validSitesIdx,siteMarkerSize,textColorWAM,fsAxis)
        % Set title
        title([upper(input.wamModel2Eval) ' | ' datestr(input.time2Eval,'yyyy-mm-dd HH:MM')],'FontSize',fsTitle)
        % Plot statistics from insitu / Wam comparison (3 free tiles in tiled layout mandatory)
        [ax2,ax3,ax4] = plt_insitu_wam_Statistics(coastColor,fsAxis,maxVarLim,maxDeltaLim,siteData,maxScaleLim,validSitesIdx);

    case 'adjInfo'
        %% :::::::::| Scaled with detailed information |::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        tiledlayout(3,2);
        nexttile([3 1])
        hold on
        ax1 = gca;
        % Spatial plot
        plt_spatialPlot(ax1,input,cmFin,lonInput,latInput,varInputScaledFinal,cfLevels,GSHHG,cbTicks,fsAxis,coastColor,edgeColor,gridType);
        % Plot site indication
        plt_plotSites(siteData,validSitesIdx,siteMarkerSize,textColorInsitu,fsSites)
        % Set title
        % title(['Adj. | ' datestr(input.time2Eval,'yyyy-mm-dd HH:MM')],'FontSize',fsTitle,'Interpreter','latex')
        title([datestr(input.time2Eval,'yyyy-mm-dd HH:MM')],'FontSize',fsTitle,'Interpreter','latex')
        % Plot statistics from insitu / Wam comparison (3 free tiles in tiled layout mandatory)
        plt_insitu_wam_Statistics(coastColor,fsAxis,maxVarLim,maxDeltaLim,siteData,maxScaleLim,validSitesIdx);
        
end

    % Maximize figure
    set(gcf,'units','normalized','outerposition',[0 0 1 1])

end