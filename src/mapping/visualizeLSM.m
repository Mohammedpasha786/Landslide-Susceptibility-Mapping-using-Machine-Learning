function visualizeLSM(classMap, R, susceptMap, titleStr, lsPoints)
% VISUALIZELSM  Render a publication-quality Landslide Susceptibility Map
%   using the MATLAB Mapping Toolbox.
%
%   visualizeLSM(classMap, R, susceptMap, titleStr)
%   visualizeLSM(classMap, R, susceptMap, titleStr, lsPoints)
%
%   Inputs:
%     classMap    - [rows x cols] uint8 class raster (1–5)
%     R           - spatial referencing object (from geotiffread)
%     susceptMap  - [rows x cols] continuous probability raster [0,1]
%     titleStr    - figure title string
%     lsPoints    - (optional) struct with .Lat .Lon of historical events

    if nargin < 4, titleStr = 'Landslide Susceptibility Map'; end
    if nargin < 5, lsPoints = []; end

    %% ── Colormap (very low=blue → very high=dark red) ────────────────────
    lsmColors = [...
        0.11, 0.36, 0.69;   % 1 Very Low   — blue
        0.24, 0.54, 0.16;   % 2 Low        — green
        0.91, 0.63, 0.13;   % 3 Moderate   — amber
        0.82, 0.29, 0.15;   % 4 High       — orange-red
        0.48, 0.07, 0.07];  % 5 Very High  — dark red

    %% ── Figure setup ─────────────────────────────────────────────────────
    fig = figure('Name', 'Landslide Susceptibility Map', ...
                 'Position', [100 100 1400 900]);

    %% ── Panel 1: Classified susceptibility map ───────────────────────────
    ax1 = subplot(1, 2, 1);
    geoshow(double(classMap), R, 'DisplayType', 'texturemap');
    colormap(ax1, lsmColors);
    caxis([0.5 5.5]);

    % Overlay historical landslide inventory
    if ~isempty(lsPoints)
        hold on;
        geoshow(lsPoints.Lat, lsPoints.Lon, ...
                'DisplayType', 'point', ...
                'Marker', 'o', ...
                'MarkerFaceColor', 'black', ...
                'MarkerEdgeColor', 'white', ...
                'MarkerSize', 4);
    end

    % Colorbar with class labels
    cb1 = colorbar('Location', 'southoutside');
    cb1.Ticks = 1:5;
    cb1.TickLabels = {'Very Low', 'Low', 'Moderate', 'High', 'Very High'};
    cb1.FontSize = 9;
    xlabel(cb1, 'Susceptibility class');

    title(ax1, [titleStr ' — Classified'], 'FontSize', 11, 'FontWeight', 'bold');
    setm(ax1, 'FontSize', 8);
    gridm on; framem on;

    %% ── Panel 2: Continuous probability map ─────────────────────────────
    ax2 = subplot(1, 2, 2);
    geoshow(susceptMap, R, 'DisplayType', 'texturemap');
    colormap(ax2, parula);
    caxis([0 1]);

    if ~isempty(lsPoints)
        hold on;
        geoshow(lsPoints.Lat, lsPoints.Lon, ...
                'DisplayType', 'point', ...
                'Marker', '^', ...
                'MarkerFaceColor', 'red', ...
                'MarkerEdgeColor', 'white', ...
                'MarkerSize', 4);
    end

    cb2 = colorbar('Location', 'southoutside');
    cb2.Label.String = 'Susceptibility probability';
    cb2.FontSize = 9;

    title(ax2, [titleStr ' — Probability'], 'FontSize', 11, 'FontWeight', 'bold');
    setm(ax2, 'FontSize', 8);
    gridm on; framem on;

    %% ── Area statistics annotation ────────────────────────────────────────
    total = numel(classMap);
    zoneNames = {'Very Low', 'Low', 'Moderate', 'High', 'Very High'};
    annotation_text = sprintf('Zone Distribution:\n');
    for k = 1:5
        pct = sum(classMap(:) == k) / total * 100;
        annotation_text = [annotation_text sprintf('  %-10s %5.1f%%\n', zoneNames{k}, pct)]; %#ok<AGROW>
    end
    annotation(fig, 'textbox', [0.01 0.01 0.18 0.18], ...
               'String', annotation_text, ...
               'FontSize', 8, ...
               'BackgroundColor', [0.95 0.95 0.95], ...
               'EdgeColor', [0.7 0.7 0.7], ...
               'FitBoxToText', 'on');

    sgtitle(sprintf('%s', titleStr), 'FontSize', 13, 'FontWeight', 'bold');
end
