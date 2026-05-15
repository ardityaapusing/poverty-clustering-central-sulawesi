# 🗺️ Poverty Clustering in Central Sulawesi Province
### PCA + Average Linkage Hierarchical Clustering
### 🥇 Gold Medal — i-JaMCSIIX 2023, Universiti Teknologi MARA, Malaysia

---

## Overview
This research groups **13 regencies and cities** in Central Sulawesi Province
based on poverty level in 2022 using **Average Linkage Hierarchical Clustering**
combined with **Principal Component Analysis (PCA)** to handle multicollinearity.

| Metric | Result |
|--------|--------|
| Data | 13 regencies/cities, Central Sulawesi 2022 |
| Variables | 6 poverty indicators (X1–X6) |
| PCA | PC1 + PC2 explain **82.67%** of total variance |
| Clusters | **2 clusters** (Silhouette method) |
| Method comparison | Average Linkage has highest cophenetic correlation |

---

## 🥇 Award
Awarded **Gold Medal** at the  
**International Jasin Multimedia and Computer Science Invention and Innovation Exhibition (i-JaMCSIIX) 2023**  
Universiti Teknologi MARA (UiTM) Cawangan Melaka, Malaysia — November 8, 2023

---

## Research Team
| Name | Role |
|------|------|
| Paskal Immanuel Kontoro | Team Member |
| Virga Damayanti | Team Member |
| **Arditya Sulistya Ningsih Apusing** | Team Member |
| Alsya Putri Sigandhia | Team Member |
| Nurul Fiskia Gamayanti | Supervisor |

**Institution:** Tadulako University, Palu, Indonesia

---

## Variables
| Variable | Description | Unit |
|----------|-------------|------|
| X1 | Number of poor people | Thousand persons |
| X2 | Poverty Depth Index | — |
| X3 | Human Development Index (HDI) | Score |
| X4 | Gini Ratio | 0–1 |
| X5 | Poverty Severity Index | — |
| X6 | Open Unemployment Rate | % |

---

## Methodology
```
Raw Data (13 regions × 6 variables)
    ↓
Standardization (Z-Score)
    ↓
KMO Test → 0.68 (representative sample ✓)
    ↓
Bartlett's Test → p < 0.05 (multicollinearity exists)
    ↓
PCA → PC1 + PC2 (82.67% variance explained)
    ↓
Euclidean Distance Matrix
    ↓
Average Linkage Hierarchical Clustering
    ↓
Silhouette Method → k = 2 optimal
    ↓
2 Clusters identified
```

---

## Key Results

### Cluster 1 — High Poverty (12 Regencies)
Banggai Kepulauan, Banggai Laut, Tojo Una-Una, Buol, Morowali Utara,
Parigi Moutong, Banggai, Poso, Donggala, Toli-Toli, Morowali, Sigi

> These regencies share characteristics of higher poverty rates,
> lower HDI scores, and lower unemployment (more agriculture-dependent).

### Cluster 2 — Low Poverty (1 City)
**Palu City**

> Palu stands apart with significantly higher HDI (82.02),
> higher Gini ratio (0.355), and highest unemployment rate (6.15%),
> reflecting an urban economy with greater income inequality.

---

## Repository Structure
```
poverty-clustering-central-sulawesi/
├── app.R                          ← Interactive R Shiny dashboard
├── analysis.R                     ← Full statistical analysis script
├── data/
│   └── DATA_KEMISKINAN_LOMBA.csv  ← Poverty dataset (BPS 2022)
├── paper/
│   └── iJaMCSIIX2023_Extended_Abstract.pdf  ← Published paper
└── README.md
```

---

## How to Run

### Option 1: Interactive Dashboard (Recommended)
```r
# Install required packages
install.packages(c("shiny","ggplot2","cluster","factoextra","DT","ggrepel"))

# Run dashboard
shiny::runApp("app.R")
```

### Option 2: Full Analysis Script
```r
# Install required packages
install.packages(c("psych","GPArotation","clValid","ggplot2",
                   "cluster","factoextra","tidyverse","PerformanceAnalytics"))

# Run analysis
source("analysis.R")
```

---

## Dashboard Features
The interactive R Shiny dashboard includes:
- **Cluster Visualization** — PCA scatter plot with cluster ellipses
- **Dendrogram** — hierarchical clustering tree with cut-off at k=2
- **Variable Analysis** — bar chart comparison of each poverty indicator
- **Data Table** — full dataset with cluster assignments
- **PCA Results** — scree plot, biplot, and component summary

---

## Data Source
**Badan Pusat Statistik (BPS) — Central Statistics Agency of Indonesia**
Publication: *"Provinsi Sulawesi Tengah Dalam Angka 2023"*
Period: 2022 poverty data
URL: https://sulteng.bps.go.id

---

## Tools & Stack
`R 4.3` · `Shiny` · `ggplot2` · `factoextra` · `cluster` · `psych` · `DT` · `ggrepel`

---

## Citation
```
Kontoro, P.I., Damayanti, V., Apusing, A.S.N., Sigandhia, A.P., & Gamayanti, N.F. (2023).
Clustering Regencies/Cities in Central Sulawesi Province Based on Poverty Level
Using the Average Linkage Method with Principal Component Analysis (PCA).
Extended Abstract, International Jasin Multimedia and Computer Science Invention
and Innovation Exhibition (i-JaMCSIIX) 2023.
Gold Medal. UiTM Cawangan Melaka, Malaysia. November 8, 2023.
```

---

*Supervised by: Nurul Fiskia Gamayanti, S.Si., M.Stat.*  
*Faculty of Natural Science and Mathematics, Tadulako University, Palu, Indonesia*  
*Contact: ardityasulistya6@gmail.com | linkedin.com/in/ardityaapusing*
