# Landslide Susceptibility Mapping (LSM) using Cascade Neural Networks

[![MATLAB](https://img.shields.io/badge/MATLAB-R2022b%2B-orange?logo=mathworks)](https://www.mathworks.com/)
[![Deep Learning Toolbox](https://img.shields.io/badge/Deep%20Learning%20Toolbox-required-blue)](https://www.mathworks.com/products/deep-learning.html)
[![Mapping Toolbox](https://img.shields.io/badge/Mapping%20Toolbox-required-green)](https://www.mathworks.com/products/mapping.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> A complete MATLAB implementation of Landslide Susceptibility Mapping using a **Cascade Forward Neural Network (CascadeForwardNet)** trained with the Levenberg–Marquardt algorithm. Generates geo-referenced risk maps color-coded with 5 susceptibility classes across 24 spatial conditioning factors.

## Study Regions

| Region | Country | Recorded Events | Area | Status |
|--------|---------|----------------|------|--------|
| Muş | Turkey | 47 | ~386 km² |  Primary |
| Bandar Torkaman | Iran | 31 | ~290 km² | Available |
| Trabzon | Turkey | 89 | ~622 km² |  Available |

---

## Methodology

This project implements the **three-stage methodology** described in Abujayyab & Saleh (2020):

```
┌─────────────────────────────────────────────────────────────────┐
│  Stage 1: Data Preparation                                      │
│  → 24 spatial rasters @ 30m · co-registration · NoData handling │
├─────────────────────────────────────────────────────────────────┤
│  Stage 2: Feature Engineering & Preprocessing                   │
│  → Normalization · Distance transforms · VIF analysis           │
├─────────────────────────────────────────────────────────────────┤
│  Stage 3: CascadeForwardNet Training (trainlm)                  │
│  → Architecture: 24→[16,8]→1 · tansig/logsig · 1000 epochs     │
├─────────────────────────────────────────────────────────────────┤
│  Stage 4: Map Generation (Mapping Toolbox)                      │
│  → Full raster prediction · 5-class Jenks classification        │
├─────────────────────────────────────────────────────────────────┤
│  Stage 5: Validation                                            │
│  → AUC-ROC · Confusion matrix · Kappa · F1                      │
└─────────────────────────────────────────────────────────────────┘

## Requirements

### MATLAB Toolboxes
| Toolbox | Usage |
|---------|-------|
| **Deep Learning Toolbox** | `cascadeforwardnet`, `trainlm` |
| **Mapping Toolbox** | `geotiffread`, `geoshow`, `geotiffwrite` |
| **Statistics & ML Toolbox** | `perfcurve`, `confusionmat`, `kappa` |
| **Image Processing Toolbox** | `bwdist`, `imresize`, spatial preprocessing |

### MATLAB Version
- Minimum: R2020b
- Recommended: R2022b or newer
## Quick Start

### 1. Clone the repository
```bash
git clone https://github.com/yourusername/lsm-project.git
cd lsm-project
```

### 2. Download input data
See [`docs/data_sources.md`](docs/data_sources.md) for download instructions. Place GeoTIFFs in `data/raw/mus_turkey/`.

### 3. Run the pipeline
```matlab
% In MATLAB
cd lsm-project
addpath(genpath('src'))
main_LSM
```

### 4. Outputs
- `results/maps/LSM_Mus_Turkey.tif` — classified susceptibility map
- `results/figures/ROC_curve.png`
- `results/metrics/performance_metrics.csv`


## Results

| Model | AUC-ROC | Accuracy | Sensitivity | Specificity | Kappa |
|-------|---------|----------|------------|------------|-------|
| **Cascade NN** | **0.942** | **91.4%** | **92.1%** | **90.7%** | **0.828** |
| SVM | 0.874 | 85.2% | 84.7% | 85.6% | 0.704 |
| Random Forest | 0.918 | 89.6% | 90.3% | 88.9% | 0.792 |


## 24 Conditioning Factors

| Category | Variables |
|----------|-----------|
| **Geomorphological** | Elevation, Slope angle, Aspect, Curvature, Profile curvature, Plan curvature, Lithology, Soil type, Distance to faults, Fault density, Seismic intensity, TRI, TPI, Distance to anticlines |
| **Hydrological** | TWI, SPI, Distance to streams, Drainage density, Flow accumulation |
| **Infrastructure** | Distance to roads, Road density |
| **Land use** | Land use/cover, NDVI |
| **Climatological** | Annual rainfall |

##  References

1. Abujayyab, S. K. M., & Saleh, A. (2020). *Landslides Risk Prediction Using Cascade Neural Networks Model at Muş In Turkey.*
2. Vakhshoori, V., et al. (2019). Landslide Susceptibility Mapping Using GIS-Based Data Mining Algorithms. *Water*, 11(11), 2292. https://doi.org/10.3390/w11112292
3. USGS Landslide Hazards Program: https://www.usgs.gov/natural-hazards/landslide-hazards

##  License

MIT License — see [LICENSE](LICENSE) for details.
