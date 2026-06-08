function [susceptMap, classMap] = generateSusceptMap(net, X_all, meta)
% GENERATESUSCEPTMAP  Apply trained network across full raster extent and
%   classify output into 5 susceptibility zones.
%
%   [susceptMap, classMap] = generateSusceptMap(net, X_all, meta)
%
%   Inputs:
%     net        - trained cascadeforwardnet
%     X_all      - [nVars x nPixels] feature matrix
%     meta       - struct with rows, cols (from loadConditioningFactors)
%
%   Outputs:
%     susceptMap - [rows x cols] continuous susceptibility probability [0,1]
%     classMap   - [rows x cols] integer class map (1=very low … 5=very high)

    %% 1. Predict susceptibility scores across full extent
    scores = predictSusceptibility(net, X_all);

    %% 2. Reshape to 2D raster
    susceptMap = reshape(scores, meta.rows, meta.cols);

    %% 3. Classify into 5 zones using Jenks natural breaks
    classMap = classifyZones(susceptMap, 5);

    %% 4. Summary statistics
    zoneNames = {'Very Low', 'Low', 'Moderate', 'High', 'Very High'};
    total = numel(classMap);
    fprintf('\n  ── Susceptibility Zone Distribution ────────────\n');
    for k = 1:5
        pct = sum(classMap(:) == k) / total * 100;
        fprintf('  Class %d %-12s: %5.1f%%\n', k, zoneNames{k}, pct);
    end
    fprintf('  ────────────────────────────────────────────────\n');
end
