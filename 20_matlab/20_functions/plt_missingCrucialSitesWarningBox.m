function a = plt_missingCrucialSitesWarningBox(ax,input,warnBoolVec)

% Position: left, bottom, width, height
unit        = 'normalized';
ax.Units    = unit;

legFS       = input.fsAxis;
str2Plot    = {['Warning! Data for crucial sites not available. This may result in incorrect spatial insitu adjustments.']};
% Get actual position of axes with plotboxpos function
pos         = arrayfun(@plotboxpos, ax, 'uni', 0);
dim         = cellfun(@(x) x.*[1 1 1 1], pos, 'uni',0);

% Identify position based on warnBoolVec
if sum(warnBoolVec) == 1
    % Dimensions for top 20% height of the axes
    dim{:}(2)   = dim{:}(2) + dim{:}(4) - 0.2*dim{:}(4);
    dim{:}(4)   = 0.2*dim{:}(4);
else
    % Dimensions for position at 60-80% of the vertical axes
    dim{:}(2)   = dim{:}(2) + dim{:}(4) - 0.4*dim{:}(4);
    dim{:}(4)   = 0.2*dim{:}(4);
end

% Plot Warning
a           = annotation('textbox',dim{1},'String',str2Plot,'FitBoxToText','off','BackgroundColor',[0.95,0.95,0.95],'EdgeColor',[.1,.1,.1],'Color',[0.8902, 0.2902, 0.2000],'FontSize',legFS,'VerticalAlignment','mid','HorizontalAlignment','left','FontWeight','bold','Interpreter','latex');


end