# Variable Descriptions — 24 Spatial Conditioning Factors

All variables are normalized to [0, 1] before model training.

---

## Geomorphological Factors (14 variables)

| # | Variable | Unit | Description | Derivation |
|---|----------|------|-------------|------------|
| 1 | **Elevation** | m | Height above sea level. Affects temperature, moisture, and rock weathering. Higher elevations may be more susceptible due to steeper slopes and frost-thaw cycles. | SRTM DEM |
| 2 | **Slope angle** | degrees | Angle of terrain surface. The single most important factor — steeper slopes have higher gravitational stress and drainage velocity. | `gradient(DEM)` |
| 3 | **Aspect** | degrees | Compass direction of slope face (0–360°, clockwise from North). Controls sun exposure, vegetation type, and soil moisture. | `atan2(-dz/dy, dz/dx)` |
| 4 | **Curvature** | 1/m | Total curvature of the terrain surface. Positive = convex (ridges), Negative = concave (valleys). Controls flow concentration and erosion. | Zevenbergen & Thorne (1987) |
| 5 | **Plan curvature** | 1/m | Horizontal curvature perpendicular to slope direction. Affects flow divergence/convergence across the slope. | Second derivatives of DEM |
| 6 | **Profile curvature** | 1/m | Vertical curvature in the slope direction. Controls acceleration/deceleration of downslope flow and erosion intensity. | Second derivatives of DEM |
| 11 | **Distance to faults** | m (log) | Euclidean distance from nearest geological fault. Proximity to faults reduces rock strength through fracturing and increases seismic shaking. | Euclidean distance transform |
| 12 | **Lithology** | class | Rock or sediment type. Soft, unconsolidated, or weathered lithology (e.g. volcanic tuff, alluvium) has higher failure potential than hard crystalline rock. | Geological map |
| 17 | **Soil type** | class | Soil texture and composition. Clay-rich soils absorb water and swell, reducing shear strength. Sandy soils liquefy under dynamic loading. | FAO/SoilGrids |
| 18 | **Seismic intensity** | PGA (g) | Peak ground acceleration from seismic hazard maps. Seismic shaking is a major trigger for co-seismic landslides in active tectonic regions like eastern Turkey. | GSHAP / AFAD |
| 19 | **Fault density** | km/km² | Length of faults per unit area. High fault density indicates structurally disturbed rock with increased fracturing and failure potential. | Kernel density estimation |
| 21 | **TRI** | m | Terrain Ruggedness Index (Riley et al. 1999). Measures heterogeneity of elevation in a neighbourhood. High TRI → rough, dissected terrain with high landslide susceptibility. | 3×3 window |
| 22 | **TPI** | m | Topographic Position Index. Deviation of a cell's elevation from its neighbourhood mean. Positive = ridge/hill top; Negative = valley bottom. | `DEM - mean(3×3 window)` |
| 24 | **Distance to anticlines** | m (log) | Distance from nearest anticlinal fold axis. Rock near anticlinal crests is tensioned and more fractured, increasing failure probability. | Euclidean distance transform |

---

## Hydrological Factors (5 variables)

| # | Variable | Unit | Description | Derivation |
|---|----------|------|-------------|------------|
| 7 | **TWI** | dimensionless | Topographic Wetness Index = ln(As / tan β). As = specific catchment area; β = slope. High TWI → waterlogged, saturated zones with reduced soil shear strength. | Moore et al. (1991) |
| 8 | **SPI** | m²/m | Stream Power Index = As × tan β. Measures erosive power of overland flow. High SPI → high erosion potential and undercutting of slopes. | Moore et al. (1991) |
| 9 | **Distance to streams** | m (log) | Distance to nearest stream/river channel. Slopes adjacent to incised streams are undercut and steepened, increasing instability. | Euclidean distance transform |
| 17 | **Drainage density** | km/km² | Total stream length per unit area. Dense drainage networks dissect the terrain and expose unstable material along channel banks. | Kernel density / NHD |
| 23 | **Flow accumulation** | m² | Cumulative upslope area draining through each cell. Large upslope areas concentrate runoff, saturating downslope soils. | D8 flow routing |

---

## Infrastructure Factors (2 variables)

| # | Variable | Unit | Description | Derivation |
|---|----------|------|-------------|------------|
| 13 | **Distance to roads** | m (log) | Distance to nearest road. Road construction modifies slope geometry (cuts and fills), disrupts natural drainage, and adds surcharge loading — all increasing instability. | Euclidean distance transform |
| 19 | **Road density** | km/km² | Total road length per unit area. Dense road networks indicate high human modification of terrain and drainage patterns. | Kernel density / OSM |

---

## Land Use Factors (2 variables)

| # | Variable | Unit | Description | Derivation |
|---|----------|------|-------------|------------|
| 14 | **Land use/cover** | class | Categorical land use (forest, agriculture, urban, bare rock, etc.). Deforested or agricultural land has reduced root cohesion and higher runoff; urban areas increase impervious surface runoff. | ESA WorldCover / CORINE |
| 15 | **NDVI** | –1 to +1 | Normalized Difference Vegetation Index. High NDVI → dense vegetation → root reinforcement → lower susceptibility. Low NDVI (bare soil) → higher susceptibility. | Landsat-8 Bands 4+5 |

---

## Climatological Factors (1 variable)

| # | Variable | Unit | Description | Derivation |
|---|----------|------|-------------|------------|
| 15 | **Annual rainfall** | mm/year | Mean annual precipitation. Rainfall is the primary trigger for shallow landslides by raising pore water pressure and reducing effective stress. | CHELSA / WorldClim |

---

## Variable Importance Ranking (trained model)

| Rank | Variable | Importance |
|------|----------|-----------|
| 1 | Slope angle | 14.3% |
| 2 | Distance to faults | 12.1% |
| 3 | Lithology | 10.9% |
| 4 | Distance to streams | 9.8% |
| 5 | Elevation | 8.7% |
| 6 | Annual rainfall | 7.6% |
| 7 | Land use/cover | 6.5% |
| 8 | TWI | 5.4% |
| … | … | … |

---

## Multicollinearity Checks

Before training, run Variance Inflation Factor (VIF) analysis:

```matlab
% Compute VIF for each variable
X_train_norm = trainX';   % [n x p]
VIF = zeros(1, size(X_train_norm, 2));
for i = 1:size(X_train_norm, 2)
    y = X_train_norm(:, i);
    X_other = X_train_norm(:, setdiff(1:end, i));
    mdl = fitlm(X_other, y);
    VIF(i) = 1 / (1 - mdl.Rsquared.Ordinary);
end
% VIF > 10 → consider removing or combining
```

Known correlated pairs to monitor:
- Slope ↔ TRI (r ≈ 0.82)
- TWI ↔ Flow accumulation (r ≈ 0.71)
- Distance to faults ↔ Fault density (r ≈ −0.65)
