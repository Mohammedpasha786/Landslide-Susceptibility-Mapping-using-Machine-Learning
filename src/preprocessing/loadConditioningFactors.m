function [X_all, R, meta] = loadConditioningFactors(dataDir, nVars)
% LOADCONDITIONINGFACTORS  Load and stack 24 spatial conditioning factor rasters.
%
%   [X_all, R, meta] = loadConditioningFactors(dataDir, nVars)
%
%   Inputs:
%     dataDir  - path to folder containing GeoTIFF rasters
%     nVars    - number of conditioning factors (default: 24)
%
%   Outputs:
%     X_all    - [nVars x nPixels] feature matrix (double, normalized)
%     R        - spatial referencing object (map or geographic raster ref)
%     meta     - struct with rows, cols, nPixels, varNames, extent
%
%   Expected GeoTIFF filenames (place in dataDir):
%     elevation.tif, slope.tif, aspect.tif, curvature.tif,
%     plan_curv.tif, profile_curv.tif, twi.tif, spi.tif,
%     dist_streams.tif, dist_faults.tif, dist_roads.tif,
%     lithology.tif, land_use.tif, ndvi.tif, rainfall.tif,
%     seismic.tif, drainage_density.tif, fault_density.tif,
%     road_density.tif, tri.tif, tpi.tif, flow_accum.tif,
%     soil_type.tif, dist_anticlines.tif

    if nargin < 2, nVars = 24; end

    varNames = { ...
        'elevation',      'slope',          'aspect',         'curvature', ...
        'plan_curv',      'profile_curv',   'twi',            'spi', ...
        'dist_streams',   'dist_faults',    'dist_roads',     'lithology', ...
        'land_use',       'ndvi',           'rainfall',       'seismic', ...
        'drainage_density','fault_density', 'road_density',   'tri', ...
        'tpi',            'flow_accum',     'soil_type',      'dist_anticlines'};

    assert(numel(varNames) >= nVars, ...
        'nVars (%d) exceeds available variable list (%d).', nVars, numel(varNames));
    varNames = varNames(1:nVars);

    % Determine raster size from first layer
    firstFile = fullfile(dataDir, [varNames{1} '.tif']);
    assert(isfile(firstFile), 'File not found: %s', firstFile);
    [tmp, R] = geotiffread(firstFile);
    [rows, cols] = size(tmp);
    nPixels = rows * cols;

    % Preallocate
    stack = zeros(rows, cols, nVars, 'double');

    fprintf('  Loading conditioning factors:\n');
    for i = 1:nVars
        fpath = fullfile(dataDir, [varNames{i} '.tif']);
        if ~isfile(fpath)
            warning('Missing file: %s — filling with zeros.', fpath);
            layer = zeros(rows, cols);
        else
            layer = double(geotiffread(fpath));
            % Resize if needed (all layers must match first layer dimensions)
            if ~isequal(size(layer), [rows cols])
                layer = imresize(layer, [rows cols], 'bilinear');
            end
        end

        % Handle NoData (common values: -9999, -32768, NaN)
        layer(layer < -9000) = NaN;
        layer = fillmissing(layer, 'linear', 1);   % interpolate along rows
        layer = fillmissing(layer, 'linear', 2);   % interpolate along cols

        % Distance transforms for proximity variables
        if contains(varNames{i}, 'dist_')
            binaryMask = layer > 0;
            layer = bwdist(binaryMask) * 30;  % convert pixels → metres
        end

        stack(:,:,i) = layer;
        fprintf('    [%2d/%2d] %-22s loaded\n', i, nVars, varNames{i});
    end

    % Normalize each layer to [0, 1]
    stack = normalizeFeatures(stack);

    % Reshape to [nVars x nPixels]
    X_all = reshape(stack, nPixels, nVars)';

    % Build metadata struct
    meta.rows     = rows;
    meta.cols     = cols;
    meta.nPixels  = nPixels;
    meta.varNames = varNames;
    meta.extent   = R;

    fprintf('  ✓ Feature matrix size: %d vars × %d pixels\n', nVars, nPixels);
end
