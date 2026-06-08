function distMaps = computeDistanceTransforms(dataDir, pixelSize)
% COMPUTEDISTANCETRANSFORMS  Compute Euclidean distance rasters from
%   linear features: faults, roads, streams, anticlines.
%
%   distMaps = computeDistanceTransforms(dataDir, pixelSize)
%
%   Inputs:
%     dataDir   - folder containing binary line-feature rasters (.tif)
%     pixelSize - spatial resolution in metres (default: 30)
%
%   Outputs:
%     distMaps  - struct with fields:
%                   dist_faults, dist_roads, dist_streams, dist_anticlines
%
%   Input rasters should be binary (1 = feature present, 0 = background).
%   If a raster is not found, a uniform zero map is returned with a warning.

    if nargin < 2, pixelSize = 30; end

    features = {'faults', 'roads', 'streams', 'anticlines'};

    for i = 1:numel(features)
        fname = fullfile(dataDir, [features{i} '_binary.tif']);

        if isfile(fname)
            binaryRaster = logical(geotiffread(fname));
        else
            warning('Binary raster not found: %s\n  → Returning zero distance map.', fname);
            % Attempt to infer size from elevation raster
            elevFile = fullfile(dataDir, 'elevation.tif');
            if isfile(elevFile)
                tmp = geotiffread(elevFile);
                binaryRaster = false(size(tmp));
            else
                binaryRaster = false(512, 512);   % fallback size
            end
        end

        % bwdist: Euclidean distance transform (pixels) × pixelSize → metres
        distMetres = bwdist(binaryRaster) * pixelSize;

        % Log-transform to reduce extreme skew in large distance fields
        distMaps.(['dist_' features{i}]) = log1p(distMetres);

        fprintf('  ✓ Distance to %-15s | max = %.0f m\n', ...
                features{i}, max(distMetres(:)));
    end
end
