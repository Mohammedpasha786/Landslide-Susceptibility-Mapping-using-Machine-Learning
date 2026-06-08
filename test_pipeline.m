% =========================================================================
%  TEST_PIPELINE.M — Unit tests for LSM pipeline functions
%  Run from the /tests/ directory or project root.
%
%  Usage:
%    >> cd tests
%    >> test_pipeline
% =========================================================================

addpath(genpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src')));

fprintf('=================================================\n');
fprintf('  LSM Pipeline — Unit Tests\n');
fprintf('=================================================\n\n');

nPass = 0; nFail = 0;

%% ── Helper ───────────────────────────────────────────────────────────────
function assertEq(label, actual, expected, tol)
    if nargin < 4, tol = 1e-6; end
    if abs(actual - expected) <= tol
        fprintf('  ✓ PASS: %s\n', label);
        nPass = nPass + 1;
    else
        fprintf('  ✗ FAIL: %s  (got %.6f, expected %.6f)\n', label, actual, expected);
        nFail = nFail + 1;
    end
end

%% ── Test 1: normalizeFeatures ────────────────────────────────────────────
fprintf('[Test 1] normalizeFeatures\n');
stack = rand(50, 50, 3);
stack(:,:,1) = stack(:,:,1) * 500;   % elevation-like range
norm = normalizeFeatures(stack);
assertEq('min of layer 1 = 0', min(min(norm(:,:,1))), 0, 1e-9);
assertEq('max of layer 1 = 1', max(max(norm(:,:,1))), 1, 1e-9);
assertEq('min of layer 3 = 0', min(min(norm(:,:,3))), 0, 1e-9);

%% ── Test 2: computeTopographicIndices ────────────────────────────────────
fprintf('[Test 2] computeTopographicIndices\n');
dem_test = peaks(64) * 200 + 1000;
idx_test = computeTopographicIndices(dem_test, 30);
assertEq('slope size rows', size(idx_test.slope, 1), 64, 0);
assertEq('slope size cols', size(idx_test.slope, 2), 64, 0);
assertEq('slope non-negative', min(idx_test.slope(:)) >= 0, 1, 0);
assertEq('TWI is finite',  all(isfinite(idx_test.twi(:))), 1, 0);

%% ── Test 3: classifyZones ────────────────────────────────────────────────
fprintf('[Test 3] classifyZones\n');
smap = rand(100, 100);
cmap = classifyZones(smap, 5);
assertEq('min class = 1', double(min(cmap(:))), 1, 0);
assertEq('max class = 5', double(max(cmap(:))), 5, 0);
assertEq('no zeros in classMap', any(cmap(:) == 0), 0, 0);

%% ── Test 4: computeMetrics ────────────────────────────────────────────────
fprintf('[Test 4] computeMetrics\n');
rng(42);
true_labels = [ones(1,100), zeros(1,100)];
scores_perfect = [ones(1,100), zeros(1,100)];
m_perfect = computeMetrics(scores_perfect, true_labels);
assertEq('perfect accuracy = 1',    m_perfect.accuracy,    1.0, 1e-9);
assertEq('perfect sensitivity = 1', m_perfect.sensitivity, 1.0, 1e-9);
assertEq('perfect specificity = 1', m_perfect.specificity, 1.0, 1e-9);
assertEq('perfect F1 = 1',          m_perfect.F1,          1.0, 1e-6);
assertEq('perfect kappa = 1',       m_perfect.kappa,       1.0, 1e-6);

%% ── Test 5: buildCascadeNetwork ──────────────────────────────────────────
fprintf('[Test 5] buildCascadeNetwork\n');
cfg_test.maxEpochs  = 10;
cfg_test.lr         = 0.01;
cfg_test.trainRatio = 0.70;
cfg_test.valRatio   = 0.15;
cfg_test.testRatio  = 0.15;
net_test = buildCascadeNetwork(24, [8 4], cfg_test);
assertEq('network has correct input size',  net_test.inputs{1}.size, 24, 0);
assertEq('output layer is logsig', strcmp(net_test.layers{end}.transferFcn, 'logsig'), 1, 0);

%% ── Test 6: predictSusceptibility ────────────────────────────────────────
fprintf('[Test 6] predictSusceptibility\n');
rng(42);
X_dummy = rand(24, 200);
Y_dummy = double(rand(1, 200) > 0.5);
cfg_quick = cfg_test; cfg_quick.maxEpochs = 5;
net_quick = buildCascadeNetwork(24, [4 2], cfg_quick);
net_quick.trainParam.showCommandLine = false;
[net_quick, ~] = train(net_quick, X_dummy, Y_dummy);
s = predictSusceptibility(net_quick, X_dummy, 100);
assertEq('scores in [0,1]', all(s >= 0 & s <= 1), 1, 0);
assertEq('correct number of scores', numel(s), 200, 0);

%% ── Summary ──────────────────────────────────────────────────────────────
fprintf('\n=================================================\n');
fprintf('  Results: %d passed | %d failed\n', nPass, nFail);
fprintf('=================================================\n');
if nFail == 0
    fprintf('  ✅ All tests passed.\n');
else
    fprintf('  ❌ %d test(s) failed — review output above.\n', nFail);
end
