function [outputArg1,outputArg2] = untitled3(inputArg1,inputArg2)
set(gcf,'Visible','on')
addpath('C:\Users\LuFI_LF\seadrive_root\froehlin\Meine Bibliotheken\GitLab\Seegangsmodul\10_inputFiles\40_colormaps')
load("vik.mat")

% 

%% Measurements
outTable = array2table([insituVars;wamVars],'VariableNames',validSiteNames,'RowNames',{'insitu','wam'});
nexttile([2 1])
h1 = heatmap([insituVars;wamVars]);
h1.FontSize = 15;
h1.Colormap = cmFin;

%% Deltas
nexttile([1 1])
h = heatmap(round(siteDeltas,2));
h.Colormap = vik;

% h.ColorData = [siteDeltas;siteDeltas];
% h.ColorDisplayData = [siteDeltas;siteDeltas];
axs = struct(gca);
lims = [-0.5,0.5];
axs.Colorbar.Limits = lims;
axs.Colorbar.Ticks = [linspace(lims(1),lims(2),5)];
axs.NodeChildren(3).XAxis.TickLabelInterpreter = 'latex';
axs.NodeChildren(3).YAxis.TickLabelInterpreter = 'latex';
axs.NodeChildren(3).Title.Interpreter = 'latex';
axs.NodeChildren(2).TickLabelInterpreter = 'latex';
axs.NodeChildren(1).TickLabelInterpreter = 'latex';


clim(lims)
h.FontSize = 15;
h.XDisplayLabels = validSiteNames;
h.Title = '$\Delta$Hs [m]';

%% Scale
nexttile([1 1])
h = heatmap(round(siteScales,2));
h.Colormap = vik;

% h.ColorData = [siteDeltas;siteDeltas];
% h.ColorDisplayData = [siteDeltas;siteDeltas];
axs = struct(gca);
lims = [0,2];
axs.Colorbar.Limits = lims;
axs.Colorbar.Ticks = [linspace(lims(1),lims(2),5)];
axs.NodeChildren(3).XAxis.TickLabelInterpreter = 'latex';
axs.NodeChildren(3).YAxis.TickLabelInterpreter = 'latex';
axs.NodeChildren(3).Title.Interpreter = 'latex';
axs.NodeChildren(2).TickLabelInterpreter = 'latex';
axs.NodeChildren(1).TickLabelInterpreter = 'latex';


clim(lims)
h.FontSize = 15;
h.XDisplayLabels = validSiteNames;
h.Title =  ['$\frac{Hs_{insitu}}{Hs_{WAM}}$ [ ]'];


end