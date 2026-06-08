function plotConfusionMatrix(C, cfg)
% PLOTCONFUSIONMATRIX  Plot and save a styled confusion matrix.
%
%   plotConfusionMatrix(C, cfg)
%
%   Inputs:
%     C    - [2x2] confusion matrix from confusionmat()
%     cfg  - config struct (for output path)

    fig = figure('Name', 'Confusion Matrix', 'Position', [300 300 480 420], 'Visible', 'off');

    labels = {'Non-Landslide (0)', 'Landslide (1)'};
    colors = {[0.88 0.93 0.97], [0.98 0.92 0.87]; ...
              [0.98 0.92 0.87], [0.88 0.95 0.88]};
    % TN=blue-ish, FP=orange-ish, FN=orange-ish, TP=green-ish

    n = sum(C(:));
    titles = {'TN', 'FP'; 'FN', 'TP'};

    for r = 1:2
        for c = 1:2
            ax = subplot(2, 2, (r-1)*2 + c);
            rectangle('Position', [0 0 1 1], 'FaceColor', colors{r,c}, ...
                      'EdgeColor', [0.6 0.6 0.6], 'LineWidth', 1.2);
            text(0.5, 0.60, num2str(C(r,c)), 'HorizontalAlignment', 'center', ...
                 'FontSize', 22, 'FontWeight', 'bold', 'Color', [0.15 0.15 0.15]);
            text(0.5, 0.30, sprintf('%.1f%%', C(r,c)/n*100), ...
                 'HorizontalAlignment', 'center', 'FontSize', 11, 'Color', [0.4 0.4 0.4]);
            text(0.5, 0.88, titles{r,c}, 'HorizontalAlignment', 'center', ...
                 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.3 0.3 0.3]);
            set(ax, 'XTick', [], 'YTick', [], 'XLim', [0 1], 'YLim', [0 1]);
            box on;
        end
    end

    % Row and column labels
    annotation(fig, 'textbox', [0.01 0.48 0.12 0.06], 'String', 'Predicted →', ...
               'EdgeColor', 'none', 'FontSize', 9, 'HorizontalAlignment', 'center', ...
               'Rotation', 90, 'VerticalAlignment', 'middle');
    annotation(fig, 'textbox', [0.25 0.95 0.5 0.05], 'String', 'Actual →', ...
               'EdgeColor', 'none', 'FontSize', 9, 'HorizontalAlignment', 'center');

    sgtitle(sprintf('Confusion Matrix  (n=%d)', n), 'FontSize', 12, 'FontWeight', 'bold');

    outFile = fullfile('..', 'results', 'figures', 'confusion_matrix.png');
    saveas(fig, outFile);
    fprintf('  Confusion matrix saved: %s\n', outFile);
    close(fig);
end
