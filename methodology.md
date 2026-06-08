# Methodology

## Overview

This project implements the three-stage methodology from Abujayyab & Saleh (2020) using a **Cascade Forward Neural Network (CascadeForwardNet)** trained with the **Levenberg-Marquardt** algorithm to produce a Landslide Susceptibility Map (LSM).

---

## Stage 1 — Data Preparation

### 1.1 Spatial data acquisition
- 24 conditioning factor rasters collected from USGS, ESA, OpenStreetMap, AFAD, and CHELSA
- All layers resampled to **30m × 30m** resolution
- Co-registered to a common extent and UTM Zone 38N (EPSG:32638)

### 1.2 Landslide inventory
- Binary raster: 1 = historical landslide pixel, 0 = stable
- Source: NASA Global Landslide Catalog + AFAD Turkey database
- **4,218 total samples** (2,109 landslide + 2,109 non-landslide, balanced)

### 1.3 Spatial sampling
- Stratified random sampling: equal positive/negative pixels
- 70% training / 15% validation / 15% test split

---

## Stage 2 — Feature Engineering & Preprocessing

### 2.1 Topographic indices (auto-derived from DEM)
```
Slope, Aspect, Curvature, Plan curvature, Profile curvature,
TWI, SPI, TRI, TPI, Flow accumulation
```

### 2.2 Distance transforms
```
Distance to faults, roads, streams, anticlines
→ bwdist() × 30m → log1p() to reduce skew
```

### 2.3 Normalization
- Min-max scaling to [0, 1] per variable
- Preserves relative spatial variation

### 2.4 Multicollinearity check
- Variance Inflation Factor (VIF) computed for all 24 variables
- Variables with VIF > 10 flagged for review

---

## Stage 3 — Cascade Neural Network

### Architecture
```
Input layer    : 24 neurons (one per conditioning factor)
Hidden layer 1 : 16 neurons, tansig activation
Hidden layer 2 :  8 neurons, tansig activation
Output layer   :  1 neuron,  logsig activation → [0, 1]

Cascade connections: Input layer feeds ALL subsequent layers
                     (not just the adjacent hidden layer)
```

### Why cascade forward?
Unlike standard feedforward networks, cascade connections allow:
- Input features to directly influence deeper layers
- Stronger gradient flow during backpropagation
- Better performance on spatially correlated data

### Training algorithm: Levenberg-Marquardt (trainlm)
LM combines gradient descent and Gauss-Newton methods:
```
Δw = -(J'J + μI)⁻¹ J'e
```
- `J` = Jacobian matrix of network errors
- `μ` = damping parameter (adapts between GD and GN)
- Converges faster than standard backpropagation for medium-sized networks

### Hyperparameters
| Parameter | Value |
|-----------|-------|
| Hidden layers | [16, 8] |
| Activation (hidden) | tansig |
| Activation (output) | logsig |
| Max epochs | 1000 |
| Learning rate | 0.01 |
| Mu initial | 0.001 |
| Early stopping (max_fail) | 10 epochs |
| MSE goal | 1×10⁻⁶ |

---

## Stage 4 — Map Generation

1. Apply trained network to **all pixels** in the study extent (batch processing)
2. Reshape 1D score vector to 2D susceptibility raster
3. Classify into 5 zones using **Jenks Natural Breaks** (Fisher algorithm):
   - Minimizes within-class variance
   - Maximizes between-class variance
4. Render geo-referenced choropleth map with `geoshow()`
5. Export as GeoTIFF with spatial metadata preserved

### Susceptibility Classes
| Class | Label | Colour |
|-------|-------|--------|
| 1 | Very Low | Blue |
| 2 | Low | Green |
| 3 | Moderate | Amber |
| 4 | High | Orange-Red |
| 5 | Very High | Dark Red |

---

## Stage 5 — Validation

### Metrics
- **AUC-ROC**: Area under the Receiver Operating Characteristic curve (primary metric)
- **Accuracy**: (TP+TN)/(TP+TN+FP+FN)
- **Sensitivity**: TP/(TP+FN) — correctly identified landslide pixels
- **Specificity**: TN/(TN+FP) — correctly identified stable pixels
- **F1 Score**: Harmonic mean of precision and recall
- **Cohen's Kappa**: Agreement adjusted for chance

### Benchmark comparisons
- Support Vector Machine (SVM) with RBF kernel
- Random Forest (100 trees, max depth 10)

---

## References

1. Abujayyab, S. K. M., & Saleh, A. (2020). Landslides Risk Prediction Using Cascade Neural Networks Model at Muş In Turkey.
2. Vakhshoori, V., et al. (2019). Landslide Susceptibility Mapping Using GIS-Based Data Mining Algorithms. *Water*, 11(11), 2292.
3. Zevenbergen, L.W., & Thorne, C.R. (1987). Quantitative analysis of land surface topography. *Earth Surface Processes and Landforms*, 12(1), 47–56.
4. Moore, I.D., Grayson, R.B., & Ladson, A.R. (1991). Digital terrain modelling. *Hydrological Processes*, 5(1), 3–30.
5. Riley, S.J., DeGloria, S.D., & Elliot, R. (1999). A Terrain Ruggedness Index. *Intermountain Journal of Sciences*, 5(1–4), 23–27.
