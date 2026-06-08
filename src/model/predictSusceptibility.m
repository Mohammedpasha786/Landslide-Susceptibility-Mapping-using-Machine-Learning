function scores = predictSusceptibility(net, X_all, batchSize)
% PREDICTSUSCEPTIBILITY  Apply trained network to entire raster feature matrix.
%   Processes in batches to avoid memory overflow for large rasters.
%
%   scores = predictSusceptibility(net, X_all, batchSize)
%
%   Inputs:
%     net        - trained cascadeforwardnet object
%     X_all      - [nVars x nPixels] full feature matrix
%     batchSize  - pixels per batch (default: 50000)
%
%   Output:
%     scores     - [1 x nPixels] susceptibility probability in [0, 1]

    if nargin < 3, batchSize = 50000; end

    nPixels = size(X_all, 2);
    scores  = zeros(1, nPixels, 'single');

    nBatches = ceil(nPixels / batchSize);
    fprintf('  Predicting susceptibility (%d batches)...\n', nBatches);

    for b = 1:nBatches
        startIdx = (b-1) * batchSize + 1;
        endIdx   = min(b * batchSize, nPixels);
        batch    = X_all(:, startIdx:endIdx);
        scores(startIdx:endIdx) = net(batch);
        fprintf('    Batch %d/%d complete\n', b, nBatches);
    end

    scores = double(scores);
    scores = max(0, min(1, scores));   % clamp to [0,1]

    fprintf('  ✓ Susceptibility scores: min=%.4f, max=%.4f, mean=%.4f\n', ...
            min(scores), max(scores), mean(scores));
end
