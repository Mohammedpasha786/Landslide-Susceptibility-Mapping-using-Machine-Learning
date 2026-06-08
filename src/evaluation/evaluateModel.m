function metrics = evaluateModel(net, testX, testY, cfg)
% EVALUATEMODEL  Comprehensive model evaluation for landslide susceptibility.
%
%   metrics = evaluateModel(net, testX, testY, cfg)
%
%   Inputs:
%     net    - trained cascadeforwardnet
%     testX  - [nVars x nTest] test feature matrix
%     testY  - [1 x nTest] binary test labels
%     cfg    - configuration struct (for output paths)
%
%   Output:
%     metrics - struct with fields:
%                 auc, accuracy, sensitivity, specificity,
%                 precision, F1, kappa, threshold, C (confusion matrix)

    %% ── Predictions ──────────────────────────────────────────────────────
    scores = net(testX);
    scores = scores(:)';

    %% ── Optimal threshold (Youden's J) ───────────────────────────────────
    [tpr_vec, fpr_vec, thresholds, auc] = perfcurve(testY, scores, 1);
    J = tpr_vec - fpr_vec;
    [~, bestIdx] = max(J);
    threshold = thresholds(bestIdx);
    pred = double(scores >= threshold);

    %% ── Confusion matrix ─────────────────────────────────────────────────
    C = confusionmat(testY, pred);
    % C(1,1)=TN  C(1,2)=FP
    % C(2,1)=FN  C(2,2)=TP
    TP = C(2,2); TN = C(1,1);
    FP = C(1,2); FN = C(2,1);

    %% ── Metrics ──────────────────────────────────────────────────────────
    metrics.auc         = auc;
    metrics.threshold   = threshold;
    metrics.accuracy    = (TP + TN) / (TP + TN + FP + FN);
    metrics.sensitivity = TP / (TP + FN + eps);   % recall / TPR
    metrics.specificity = TN / (TN + FP + eps);   % TNR
    metrics.precision   = TP / (TP + FP + eps);
    metrics.F1          = 2 * metrics.precision * metrics.sensitivity / ...
                              (metrics.precision + metrics.sensitivity + eps);
    metrics.C           = C;

    % Cohen's Kappa
    n   = TP + TN + FP + FN;
    po  = (TP + TN) / n;
    pe  = ((TP+FP)/n * (TP+FN)/n) + ((TN+FN)/n * (TN+FP)/n);
    metrics.kappa = (po - pe) / (1 - pe + eps);

    %% ── Plots ────────────────────────────────────────────────────────────
    plotROC(tpr_vec, fpr_vec, auc, cfg);
    plotConfusionMatrix(C, cfg);

    %% ── Save metrics CSV ─────────────────────────────────────────────────
    saveMetricsCSV(metrics, fullfile('..', 'results', 'metrics', 'performance_metrics.csv'));

    fprintf('  ✓ Evaluation complete\n');
end
