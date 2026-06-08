function [net, tr] = trainNetwork(trainX, trainY, cfg)
% TRAINNETWORK  Build and train a CascadeForwardNet for landslide susceptibility.
%
%   [net, tr] = trainNetwork(trainX, trainY, cfg)
%
%   Inputs:
%     trainX  - [nVars x nSamples] feature matrix
%     trainY  - [1 x nSamples] binary labels (1=landslide, 0=stable)
%     cfg     - configuration struct (see main_LSM.m)
%
%   Outputs:
%     net     - trained network object
%     tr      - training record (performance curves, best epoch, etc.)

    nInputs = size(trainX, 1);

    %% Build network
    net = buildCascadeNetwork(nInputs, cfg.hiddenLayers, cfg);

    %% Train
    fprintf('  Training network...\n');
    tic;
    [net, tr] = train(net, trainX, trainY);
    elapsed = toc;

    %% Report
    fprintf('  ✓ Training complete in %.1f seconds\n', elapsed);
    fprintf('    Best epoch       : %d\n',   tr.best_epoch);
    fprintf('    Final train MSE  : %.6f\n', tr.perf(end));
    fprintf('    Best val MSE     : %.6f\n', min(tr.vperf));

    %% Plot training performance
    fig = figure('Name', 'Training Performance', 'Visible', 'off');
    semilogy(tr.perf,  'b-',  'LineWidth', 1.5, 'DisplayName', 'Train');
    hold on;
    semilogy(tr.vperf, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Validation');
    semilogy(tr.tperf, 'g:',  'LineWidth', 1.2, 'DisplayName', 'Test');
    xline(tr.best_epoch, 'k--', 'LineWidth', 1, 'DisplayName', 'Best epoch');
    xlabel('Epoch'); ylabel('MSE (log scale)');
    title('Cascade Neural Network — Training Curve');
    legend('Location', 'northeast');
    grid on;
    saveas(fig, fullfile('..', 'results', 'figures', 'training_curve.png'));
    close(fig);
end
