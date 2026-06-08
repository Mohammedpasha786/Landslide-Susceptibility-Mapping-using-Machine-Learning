% =========================================================================
%  LANDSLIDE SUSCEPTIBILITY MAPPING — Main Pipeline Script
%  Reference: Abujayyab & Saleh (2020)
%
%  Usage:
%    >> main_LSM
%
%  Required Toolboxes:
%    - Deep Learning Toolbox
%    - Mapping Toolbox
%    - Statistics and Machine Learning Toolbox
%    - Image Processing Toolbox
% =========================================================================

clear all; clc; close all;
addpath(genpath(fileparts(mfilename('fullpath'))));

fprintf('=================================================\n');
fprintf('  Landslide Susceptibility Mapping (LSM)\n');
fprintf('  Cascade Forward Neural Network | trainlm\n');
fprintf('=================================================\n\n');

%% ── Configuration ────────────────────────────────────────────────────────

cfg.dataDir      = fullfile('..', 'data', 'raw', 'mus_turkey');
cfg.outputDir    = fullfile('..', 'results');
cfg.nVars        = 24;
cfg.trainRatio   = 0.70;
cfg.valRatio     = 0.15;
cfg.testRatio    = 0.15;
cfg.hiddenLayers = [16 8];
cfg.maxEpochs    = 1000;
cfg.lr           = 0.01;
cfg.randomSeed   = 42;
cfg.nClasses     = 5;   % susceptibility zones
cfg.pixelSize    = 30;  % metres

rng(cfg.randomSeed);

%% ── Stage 1: Load conditioning factors ──────────────────────────────────

fprintf('[Stage 1] Loading %d conditioning factors...\n', cfg.nVars);
[X_all, R, meta] = loadConditioningFactors(cfg.dataDir, cfg.nVars);
fprintf('  Loaded raster: %d x %d pixels\n', meta.rows, meta.cols);

%% ── Stage 2: Load landslide inventory & prepare dataset ─────────────────

fprintf('[Stage 2] Preparing training dataset...\n');
inventoryFile = fullfile(cfg.dataDir, 'landslide_inventory.tif');
[trainX, trainY, testX, testY, idx] = prepareDataset(X_all, inventoryFile, cfg);
fprintf('  Training samples: %d (50%% landslide / 50%% non-landslide)\n', size(trainX, 2));
fprintf('  Test samples    : %d\n', size(testX, 2));

%% ── Stage 3: Build & train cascade forward network ───────────────────────

fprintf('[Stage 3] Training CascadeForwardNet [%s]...\n', ...
        num2str(cfg.hiddenLayers));
[net, tr] = trainNetwork(trainX, trainY, cfg);
fprintf('  Best validation epoch: %d | MSE: %.6f\n', ...
        tr.best_epoch, min(tr.vperf));

%% ── Stage 4: Generate susceptibility map ────────────────────────────────

fprintf('[Stage 4] Generating susceptibility map...\n');
[susceptMap, classMap] = generateSusceptMap(net, X_all, meta);
outMapFile = fullfile(cfg.outputDir, 'maps', 'LSM_Mus_Turkey.tif');
geotiffwrite(outMapFile, classMap, R);
fprintf('  Map saved: %s\n', outMapFile);

%% ── Stage 5: Visualize ───────────────────────────────────────────────────

fprintf('[Stage 5] Visualizing results...\n');
visualizeLSM(classMap, R, susceptMap, 'Muş, Turkey — Landslide Susceptibility');
saveas(gcf, fullfile(cfg.outputDir, 'figures', 'LSM_map.png'));

%% ── Stage 6: Evaluate model ──────────────────────────────────────────────

fprintf('[Stage 6] Evaluating model performance...\n');
metrics = evaluateModel(net, testX, testY, cfg);

fprintf('\n── Performance Metrics ──────────────────────\n');
fprintf('  AUC-ROC     : %.4f\n', metrics.auc);
fprintf('  Accuracy    : %.2f%%\n', metrics.accuracy * 100);
fprintf('  Sensitivity : %.2f%%\n', metrics.sensitivity * 100);
fprintf('  Specificity : %.2f%%\n', metrics.specificity * 100);
fprintf('  F1 Score    : %.4f\n', metrics.F1);
fprintf('  Kappa       : %.4f\n', metrics.kappa);
fprintf('─────────────────────────────────────────────\n');

% Save metrics table
metricsFile = fullfile(cfg.outputDir, 'metrics', 'performance_metrics.csv');
saveMetricsCSV(metrics, metricsFile);

fprintf('\n✓ Pipeline complete. Outputs in: %s\n', cfg.outputDir);
