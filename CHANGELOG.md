# Changelog

All notable changes to this project are documented here.

---

## [1.0.0] — 2024-01-01

### Added
- Complete MATLAB pipeline: data loading → preprocessing → training → mapping → evaluation
- `cascadeforwardnet` with Levenberg-Marquardt (`trainlm`) training
- 24 spatial conditioning factors for Muş, Turkey
- Jenks Natural Breaks classification into 5 susceptibility zones
- Publication-quality map rendering via Mapping Toolbox (`geoshow`)
- Full evaluation suite: AUC-ROC, confusion matrix, F1, Kappa
- Unit test suite (`tests/test_pipeline.m`)
- Data sources guide (`docs/data_sources.md`)
- Methodology documentation (`docs/methodology.md`)
- Variable descriptions (`docs/variable_descriptions.md`)
