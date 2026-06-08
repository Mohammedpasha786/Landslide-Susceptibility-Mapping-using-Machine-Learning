function saveMetricsCSV(metrics, outFile)
% SAVEMETRICSCSV  Write model performance metrics to a CSV file.
%
%   saveMetricsCSV(metrics, outFile)
%
%   Inputs:
%     metrics  - struct from evaluateModel() or computeMetrics()
%     outFile  - full path for output CSV file

    % Ensure output directory exists
    [outDir, ~, ~] = fileparts(outFile);
    if ~isfolder(outDir), mkdir(outDir); end

    fields = {'auc', 'accuracy', 'sensitivity', 'specificity', ...
              'precision', 'F1', 'kappa', 'threshold'};
    prettyNames = {'AUC-ROC', 'Accuracy', 'Sensitivity (Recall)', 'Specificity', ...
                   'Precision', 'F1 Score', "Cohen's Kappa", 'Decision Threshold'};

    fid = fopen(outFile, 'w');
    fprintf(fid, 'Metric,Value\n');
    for i = 1:numel(fields)
        if isfield(metrics, fields{i})
            fprintf(fid, '%s,%.6f\n', prettyNames{i}, metrics.(fields{i}));
        end
    end

    % Confusion matrix values
    if isfield(metrics, 'C')
        C = metrics.C;
        fprintf(fid, 'TP,%d\n', C(2,2));
        fprintf(fid, 'TN,%d\n', C(1,1));
        fprintf(fid, 'FP,%d\n', C(1,2));
        fprintf(fid, 'FN,%d\n', C(2,1));
    elseif isfield(metrics, 'TP')
        fprintf(fid, 'TP,%d\n', metrics.TP);
        fprintf(fid, 'TN,%d\n', metrics.TN);
        fprintf(fid, 'FP,%d\n', metrics.FP);
        fprintf(fid, 'FN,%d\n', metrics.FN);
    end

    fclose(fid);
    fprintf('  Metrics CSV saved: %s\n', outFile);
end
