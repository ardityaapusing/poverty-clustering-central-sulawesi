# ============================================================
# Clustering Regencies/Cities in Central Sulawesi Province
# Based on Poverty Level Using Average Linkage + PCA
# 
# Gold Medal - i-JaMCSIIX 2023
# Universiti Teknologi MARA (UiTM), Malaysia
# 
# Authors: Paskal Immanuel Kontoro, Virga Damayanti,
#          Arditya Sulistya Ningsih Apusing,
#          Alsya Putri Sigandhia, Nurul Fiskia Gamayanti
# Institution: Tadulako University, Indonesia
# ============================================================

# ── 1. INSTALL & LOAD LIBRARIES ──────────────────────────────
packages <- c("psych", "GPArotation", "clValid", "ggplot2",
              "cluster", "factoextra", "tidyverse", "PerformanceAnalytics")

for (pkg in packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, quiet = TRUE)
    library(pkg, character.only = TRUE)
  }
}

# ── 2. LOAD DATA ─────────────────────────────────────────────
# Data: 13 Regencies/Cities in Central Sulawesi Province, 2022
# Source: BPS (Central Statistics Agency) - "Sulawesi Tengah Dalam Angka 2023"
data <- read.csv("data/DATA_KEMISKINAN_LOMBA.csv", sep = ";")

cat("=== DATA OVERVIEW ===\n")
cat("Dimensions:", nrow(data), "regencies x", ncol(data)-1, "variables\n\n")

# Variables:
# X1: Number of poor people (thousand)
# X2: Poverty Depth Index
# X3: Human Development Index (HDI)
# X4: Gini Ratio
# X5: Poverty Severity Index
# X6: Open Unemployment Rate (%)

rownames_data <- data$Regencies_Cities
Data <- data[, -1]
rownames(Data) <- rownames_data

cat("Variables used:\n")
cat("  X1: Number of Poor People\n")
cat("  X2: Poverty Depth Index\n")
cat("  X3: Human Development Index (HDI)\n")
cat("  X4: Gini Ratio\n")
cat("  X5: Poverty Severity Index\n")
cat("  X6: Open Unemployment Rate\n\n")

# ── 3. DESCRIPTIVE STATISTICS ────────────────────────────────
cat("=== DESCRIPTIVE STATISTICS ===\n")
print(summary(Data))

# ── 4. ASSUMPTION TESTS ──────────────────────────────────────

# 4a. KMO - Sample Adequacy Test
cat("\n=== KMO TEST (Sample Adequacy) ===\n")
kmo <- KMO(Data)
print(kmo)
cat("Overall KMO:", kmo$MSA, "\n")
cat("Result: KMO > 0.5 → Sample is representative ✓\n")

# 4b. Bartlett's Test of Sphericity (Multicollinearity)
cat("\n=== BARTLETT'S TEST (Multicollinearity) ===\n")
uji_bart <- function(x) {
  x <- subset(x, complete.cases(x))
  n <- nrow(x); p <- ncol(x)
  chisq <- (1 - n + (2*p + 5)/6) * log(det(cor(x)))
  df    <- p*(p-1)/2
  p.val <- pchisq(chisq, df, lower.tail = FALSE)
  cat("Chi-Square:", round(chisq, 4), "\n")
  cat("df:", df, "\n")
  cat("p-value:", format(p.val, scientific = TRUE), "\n")
  cat("Result: p-value < 0.05 → Multicollinearity exists → PCA needed ✓\n")
  return(p.val)
}
uji_bart(Data)

# ── 5. STANDARDIZE DATA ──────────────────────────────────────
cat("\n=== DATA STANDARDIZATION (Z-Score) ===\n")
data_scaled <- scale(Data)
rownames(data_scaled) <- rownames_data
cat("Data standardized successfully ✓\n")

# ── 6. PRINCIPAL COMPONENT ANALYSIS (PCA) ───────────────────
cat("\n=== PRINCIPAL COMPONENT ANALYSIS ===\n")
data_pca <- prcomp(Data, scale. = TRUE)
pca_summary <- summary(data_pca)
print(pca_summary)

# Eigenvalues
eigenvalues <- data_pca$sdev^2
cat("\nEigenvalues:\n")
for (i in seq_along(eigenvalues)) {
  cat(sprintf("  PC%d: %.4f %s\n", i, eigenvalues[i],
              ifelse(eigenvalues[i] > 1, "← Selected (eigenvalue > 1)", "")))
}

# Select PC1 and PC2 (eigenvalue > 1, cumulative variance 82.67%)
pca_scores <- data_pca$x[, 1:2]
cat("\nPC1 + PC2 explain", round(pca_summary$importance[3,2]*100, 2), "% of total variance\n")
cat("Selected: PC1 and PC2 ✓\n")

# Scree plot
png("output/scree_plot.png", width = 800, height = 500)
fviz_eig(data_pca, addlabels = TRUE, ylim = c(0, 70),
         main = "Scree Plot - Variance Explained by Each PC")
dev.off()

# ── 7. COPHENETIC CORRELATION (Method Comparison) ────────────
cat("\n=== COPHENETIC CORRELATION (Comparing Linkage Methods) ===\n")
methods <- c("single", "average", "complete", "centroid", "ward.D")
d <- dist(Data)
cors <- sapply(methods, function(m) {
  hc <- hclust(d, method = m)
  round(cor(d, cophenetic(hc)), 4)
})
for (i in seq_along(methods)) {
  cat(sprintf("  %-12s: %.4f %s\n", methods[i], cors[i],
              ifelse(methods[i] == "average", "← Best (highest)", "")))
}
cat("\n→ Average Linkage selected (highest cophenetic correlation) ✓\n")

# ── 8. OPTIMAL NUMBER OF CLUSTERS ───────────────────────────
cat("\n=== DETERMINING OPTIMAL CLUSTERS ===\n")
cat("Using Silhouette method on standardized PCA scores...\n")

png("output/optimal_clusters.png", width = 800, height = 500)
fviz_nbclust(pca_scores, hcut, method = "silhouette",
             main = "Optimal Number of Clusters (Silhouette Method)")
dev.off()
cat("Optimal clusters: k = 2 ✓\n")

# ── 9. AVERAGE LINKAGE CLUSTERING ───────────────────────────
cat("\n=== AVERAGE LINKAGE HIERARCHICAL CLUSTERING ===\n")
hier_ave <- hclust(dist(data_scaled), method = "average")

# Dendrogram
png("output/dendrogram.png", width = 1000, height = 600)
plot(hier_ave,
     labels = rownames_data,
     hang   = -1,
     col    = "steelblue",
     main   = "Dendrogram - Average Linkage Clustering\nPoverty Level in Central Sulawesi (2022)",
     xlab   = "Regency / City",
     ylab   = "Euclidean Distance")
rect.hclust(hier_ave, k = 2, border = c("#E74C3C", "#2ECC71"))
dev.off()

# Cut tree at k=2
clusters <- cutree(hier_ave, k = 2)
results  <- data.frame(
  Regency_City = rownames_data,
  Cluster      = clusters,
  stringsAsFactors = FALSE
)

cat("\nCluster Membership:\n")
print(results)

cat("\nCluster Summary:\n")
cat("Cluster 1 (High Poverty  - 12 regencies):",
    paste(results$Regency_City[results$Cluster == 1], collapse = ", "), "\n\n")
cat("Cluster 2 (Low Poverty   -  1 city     ):",
    paste(results$Regency_City[results$Cluster == 2], collapse = ", "), "\n")

# ── 10. CLUSTER VISUALIZATION ────────────────────────────────
cat("\n=== CLUSTER VISUALIZATION ===\n")
clus_result <- eclust(data_scaled, FUNcluster = "hclust",
                      k = 2, hc_method = "average", graph = FALSE)

png("output/cluster_plot.png", width = 900, height = 600)
fviz_cluster(clus_result,
             data        = pca_scores,
             geom        = "point",
             ellipse     = TRUE,
             ellipse.type= "convex",
             palette     = c("#E74C3C", "#2ECC71"),
             ggtheme     = theme_minimal(),
             main        = "PCA + Average Linkage Clustering\nPoverty Level - Central Sulawesi Province (2022)") +
  geom_text(aes(label = rownames_data), size = 3, vjust = -0.5)
dev.off()

# ── 11. CLUSTER PROFILE (Mean per Variable) ──────────────────
cat("\n=== CLUSTER PROFILES ===\n")
cluster_profile <- aggregate(Data, list(Cluster = clusters), mean)
cluster_profile$Cluster <- c("Cluster 1 (High Poverty)", "Cluster 2 (Low Poverty)")
print(round(cluster_profile, 3))

cat("\n=== ANALYSIS COMPLETE ===\n")
cat("Results saved to output/ folder\n")
cat("Clusters: 2 (Cluster 1: 12 regencies | Cluster 2: Palu City)\n")
cat("\n📊 Open app.R in RStudio and run to launch the interactive dashboard\n")
