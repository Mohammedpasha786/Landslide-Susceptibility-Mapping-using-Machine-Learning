function stackNorm = normalizeFeatures(stack)
% NORMALIZEFEATURES  Min-max normalize each layer in a 3-D raster stack to [0, 1].
%
%   stackNorm = normalizeFeatures(stack)
%
%   Input:
%     stack     - [rows x cols x nVars] double array
%
%   Output:
%     stackNorm - same size, each variable independently scaled to [0, 1]
%
%   NaN values are preserved (not included in min/max computation).

    [rows, cols, nVars] = size(stack);
    stackNorm = zeros(rows, cols, nVars, 'double');

    for i = 1:nVars
        layer = stack(:,:,i);
        mn = min(layer(:), [], 'omitnan');
        mx = max(layer(:), [], 'omitnan');
        rng = mx - mn;

        if rng < eps
            % Constant layer: map to 0
            stackNorm(:,:,i) = zeros(rows, cols);
            warning('Variable %d is constant (min=max=%.4f). Mapped to 0.', i, mn);
        else
            stackNorm(:,:,i) = (layer - mn) / rng;
        end
    end
end
