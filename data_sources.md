# Data Sources & Download Guide

This document describes how to obtain all input data required to run the LSM pipeline for the Muş, Turkey study area.

---

## Study Area Bounding Box (Muş, Turkey)

```
North:  39.1°N
South:  38.4°N
East:   42.0°E
West:   41.0°E
```

UTM Zone: **38N** (EPSG: 32638)  
Target resolution: **30 × 30 m**

---

## 1. Digital Elevation Model (DEM)

**Source:** USGS EarthExplorer — SRTM 1 Arc-Second (30m)

**Steps:**
1. Go to https://earthexplorer.usgs.gov/
2. Search coordinates: `38.75°N, 41.5°E`
3. Select: *Data Sets → Digital Elevation → SRTM → SRTM 1 Arc-Second Global*
4. Download tile `N38E041.hgt` and `N38E042.hgt`
5. Convert to GeoTIFF and clip to study extent:
```matlab
% In MATLAB:
[dem, R] = geotiffread('N38E041.hgt');
```

**Derived from DEM** (computed automatically by `computeTopographicIndices.m`):
- `slope.tif`
- `aspect.tif`
- `curvature.tif`, `plan_curv.tif`, `profile_curv.tif`
- `twi.tif`, `spi.tif`
- `tri.tif`, `tpi.tif`
- `flow_accum.tif`

Save base DEM as: `data/raw/mus_turkey/elevation.tif`

---

## 2. Geological Faults & Anticlines

**Source:** USGS Quaternary Fault and Fold Database (for global coverage)  
https://www.usgs.gov/natural-hazards/earthquake-hazards/faults

**Alternative (Turkey-specific):** AFAD (Disaster and Emergency Management Authority)  
https://tdth.afad.gov.tr/

**Steps:**
1. Download fault shapefile for eastern Turkey
2. In MATLAB or QGIS, rasterize to 30m grid (binary: 1=fault, 0=background):
```matlab
% Rasterize with rasterize or via GDAL
% gdal_rasterize -burn 1 -tr 30 30 faults.shp faults_binary.tif
```

Save as:
- `data/raw/mus_turkey/faults_binary.tif`
- `data/raw/mus_turkey/anticlines_binary.tif`

Distance transforms computed automatically by `computeDistanceTransforms.m`.

---

## 3. Hydrological Features (Streams)

**Source A:** OpenStreetMap via Overpass API  
https://overpass-turbo.eu/  
Query: `way["waterway"~"river|stream"](38.4,41.0,39.1,42.0)`

**Source B:** USGS NHD-equivalent for Turkey — HydroSHEDS  
https://www.hydrosheds.org/

Save rasterized stream network as:
- `data/raw/mus_turkey/streams_binary.tif`

---

## 4. Road Network

**Source:** OpenStreetMap (OSM)  
Download via: https://download.geofabrik.de/asia/turkey.html

```bash
# Extract road layer with ogr2ogr
ogr2ogr -f "ESRI Shapefile" roads.shp turkey.osm.pbf lines -sql "SELECT * FROM lines WHERE highway IS NOT NULL"
```

Save rasterized roads as:
- `data/raw/mus_turkey/roads_binary.tif`

---

## 5. Land Use / Land Cover

**Source:** ESA WorldCover 10m (2021)  
https://viewer.esa-worldcover.org/worldcover/

Or: CORINE Land Cover (Europe/Turkey)  
https://land.copernicus.eu/en/products/corine-land-cover

Resample to 30m:
```matlab
lulc = geotiffread('ESA_WorldCover_T38SMJ.tif');
lulc_30m = imresize(lulc, [rows cols], 'nearest');
geotiffwrite('data/raw/mus_turkey/land_use.tif', lulc_30m, R);
```

---

## 6. NDVI (Normalized Difference Vegetation Index)

**Source:** USGS Landsat-8 / Landsat-9 Collection 2  
https://earthexplorer.usgs.gov/

Band selection:
- Band 4 (Red): 0.64–0.67 µm
- Band 5 (NIR): 0.85–0.88 µm

```matlab
red = double(geotiffread('LC08_B4.TIF')) * 2.75e-5 - 0.2;
nir = double(geotiffread('LC08_B5.TIF')) * 2.75e-5 - 0.2;
ndvi = (nir - red) ./ (nir + red + eps);
geotiffwrite('data/raw/mus_turkey/ndvi.tif', ndvi, R);
```

---

## 7. Soil Type

**Source:** FAO Harmonized World Soil Database v1.2  
https://www.fao.org/soils-portal/soil-survey/soil-maps-and-databases/harmonized-world-soil-database-v12/en/

Or: SoilGrids 250m  
https://soilgrids.org/

---

## 8. Rainfall (Annual Mean)

**Source:** CHELSA Climate v2.1  
https://chelsa-climate.org/

Variable: `CHELSA_pr_1981-2010_V.2.1.tif` (annual precipitation)

Or: WorldClim v2.1  
https://www.worldclim.org/data/worldclim21.html

---

## 9. Seismic Intensity

**Source:** USGS Global Seismic Hazard Assessment Program (GSHAP)  
https://www.gfz-potsdam.de/en/section/seismic-hazard-and-risk-dynamics/projects/gshap/

Or: AFAD seismic hazard maps for Turkey  
https://deprem.afad.gov.tr/

---

## 10. Lithology

**Source:** GLiM — Global Lithological Map  
https://www.geo.uni-hamburg.de/en/geologie/forschung/geochemie/glim.html

Or: Turkey 1:25,000 geological maps (MTA)  
https://www.mta.gov.tr/

---

## Landslide Inventory

**Primary:** Global Landslide Catalog (NASA)  
https://catalog.data.gov/dataset/global-landslide-catalog-export

**Turkey-specific:** AFAD Landslide Inventory  
https://www.afad.gov.tr/

Rasterize point/polygon inventory as binary raster:
- `data/raw/mus_turkey/landslide_inventory.tif`

---

## File Naming Conventions

All rasters must be:
1. Saved as GeoTIFF (`.tif`)
2. Projected to **UTM Zone 38N** (EPSG:32638)
3. Resampled to **30m × 30m** resolution
4. Clipped to the study bounding box

| Variable | Filename |
|----------|----------|
| Elevation | `elevation.tif` |
| Slope | `slope.tif` (auto-derived) |
| Aspect | `aspect.tif` (auto-derived) |
| Curvature | `curvature.tif` (auto-derived) |
| Plan curvature | `plan_curv.tif` (auto-derived) |
| Profile curvature | `profile_curv.tif` (auto-derived) |
| TWI | `twi.tif` (auto-derived) |
| SPI | `spi.tif` (auto-derived) |
| Distance to streams | `dist_streams.tif` (auto-derived) |
| Distance to faults | `dist_faults.tif` (auto-derived) |
| Distance to roads | `dist_roads.tif` (auto-derived) |
| Lithology | `lithology.tif` |
| Land use/cover | `land_use.tif` |
| NDVI | `ndvi.tif` |
| Rainfall | `rainfall.tif` |
| Seismic intensity | `seismic.tif` |
| Drainage density | `drainage_density.tif` |
| Fault density | `fault_density.tif` |
| Road density | `road_density.tif` |
| TRI | `tri.tif` (auto-derived) |
| TPI | `tpi.tif` (auto-derived) |
| Flow accumulation | `flow_accum.tif` (auto-derived) |
| Soil type | `soil_type.tif` |
| Distance to anticlines | `dist_anticlines.tif` (auto-derived) |
| Landslide inventory | `landslide_inventory.tif` |
