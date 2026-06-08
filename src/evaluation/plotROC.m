function plotROC(tpr, fpr, auc, cfg)
% PLOTROC  Plot and save the ROC curve for landslide susceptibility model.
%
%   plotROC(tpr, fpr, auc, cfg)
%
%   Inputs:
%     tpr  - true positive rate vector (from perfcurve)
%     fpr  - false positive rate vector (from perfcurve)
%     auc  - area under the curve value
%     cfg  - config struct (for output path)

    fig = figure('Name', 'ROC Curve', 'Position', [200 200 600 550], 'Visible', 'off');

    %% Main ROC curve
    plot(fpr, tpr, 'b-', 'LineWidth', 2.5, 'DisplayName', ...
         sprintf('Cascade NN (AUC = %.4f)', auc));
    hold on;

    %% Random classifier baseline
    plot([0 1], [0 1], 'k--', 'LineWidth', 1.2, 'DisplayName', 'Random (AUC = 0.500)');

    %% Optimal threshold marker (closest to top-left corner)
    dist = sqrt(fpr.^2 + (1 - tpr).^2);
    [~, optIdx] = min(dist);
    scatter(fpr(optIdx), tpr(optIdx), 80, 'r', 'filled', ...
            'DisplayName', sprintf('Optimal threshold (%.2f, %.2f)', fpr(optIdx), tpr(optIdx)));

    %% Shaded AUC region
    area(fpr, tpr, 'FaceColor', [0.2 0.4 0.8], 'FaceAlpha', 0.08, 'EdgeColor', 'none', ...
         'HandleVisibility', 'off');

    %% Labels and formatting
    xlabel('False Positive Rate (1 − Specificity)', 'FontSize', 11);
    ylabel('True Positive Rate (Sensitivity)',       'FontSize', 11);
    title(sprintf('ROC Curve — Landslide Susceptibility\nAUC = %.4f', auc), ...
          'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'southeast', 'FontSize', 9);
    xlim([0 1]); ylim([0 1]);
    grid on; box on;
    set(gca, 'FontSize', 10);

    %% Save
    outFile = fullfile('..', 'results', 'figures', 'ROC_curve.png');
    saveas(fig, outFile);
    fprintf('  ROC curve saved: %s\n', outFile);
    close(fig);
end
