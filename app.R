# ============================================================
# INTERACTIVE DASHBOARD — Poverty Clustering in Central Sulawesi
# PCA + Average Linkage | i-JaMCSIIX 2023 Gold Medal
# ============================================================

library(shiny)
library(ggplot2)
library(cluster)
library(factoextra)
library(DT)
library(ggrepel)

# ── DATA ─────────────────────────────────────────────────────
raw <- data.frame(
  Regency_City = c("Banggai Kepulauan","Banggai","Morowali","Poso",
                   "Donggala","Toli-Toli","Buol","Parigi Moutong",
                   "Tojo Una-Una","Sigi","Banggai Laut",
                   "Morowali Utara","Palu"),
  X1 = c(16.07,28.55,15.86,40.78,50.22,30.61,21.84,74.60,
          25.33,29.94,10.32,17.49,26.75),
  X2 = c(1.79,1.20,2.03,2.40,2.82,0.153,1.79,3.84,
          2.80,2.01,2.23,2.18,0.94),
  X3 = c(66.08,71.08,72.55,71.93,66.25,66.76,68.72,66.26,
          65.54,69.05,66.22,68.97,82.02),
  X4 = c(0.280,0.315,0.285,0.256,0.280,0.295,0.266,0.279,
          0.250,0.265,0.247,0.269,0.355),
  X5 = c(0.35,0.28,0.54,0.66,0.72,0.30,0.34,1.37,
          0.78,0.48,0.61,0.65,0.25),
  X6 = c(1.48,3.09,3.20,1.68,2.84,3.31,3.07,1.71,
          3.05,3.02,3.60,2.25,6.15),
  stringsAsFactors = FALSE
)

var_labels <- c(
  X1 = "Number of Poor People (thousand)",
  X2 = "Poverty Depth Index",
  X3 = "Human Development Index (HDI)",
  X4 = "Gini Ratio",
  X5 = "Poverty Severity Index",
  X6 = "Open Unemployment Rate (%)"
)

# Pre-compute clustering
Data       <- raw[, -1]
scaled     <- scale(Data)
pca_res    <- prcomp(Data, scale. = TRUE)
pca_scores <- as.data.frame(pca_res$x[, 1:2])
pca_scores$Regency_City <- raw$Regency_City

hier_ave   <- hclust(dist(scaled), method = "average")
k2_labels  <- cutree(hier_ave, k = 2)
pca_scores$Cluster <- factor(k2_labels,
                              labels = c("Cluster 1 — High Poverty",
                                         "Cluster 2 — Low Poverty"))
raw$Cluster <- pca_scores$Cluster

cluster_colors <- c("Cluster 1 — High Poverty" = "#E74C3C",
                    "Cluster 2 — Low Poverty"  = "#27AE60")

# ── UI ───────────────────────────────────────────────────────
ui <- fluidPage(

  tags$head(tags$style(HTML("
    body { font-family: 'Segoe UI', sans-serif; background: #f8f9fa; }
    .header-box { background: #1a3a5c; color: white; padding: 20px 30px;
                  border-radius: 8px; margin-bottom: 20px; }
    .header-box h2 { margin: 0 0 4px; font-size: 22px; }
    .header-box p  { margin: 0; font-size: 13px; opacity: .8; }
    .medal-badge { background: #f39c12; color: white; padding: 4px 12px;
                   border-radius: 20px; font-size: 12px; font-weight: bold;
                   display: inline-block; margin-top: 8px; }
    .stat-box { background: white; border-radius: 8px; padding: 14px 18px;
                border-left: 4px solid #1a3a5c; margin-bottom: 12px;
                box-shadow: 0 1px 4px rgba(0,0,0,.08); }
    .stat-num { font-size: 28px; font-weight: 700; color: #1a3a5c; }
    .stat-lbl { font-size: 12px; color: #666; }
    .nav-tabs .nav-link.active { background: #1a3a5c !important;
                                  color: white !important; border-color: #1a3a5c; }
    .nav-tabs .nav-link { color: #1a3a5c; }
  "))),

  # Header
  div(class = "header-box",
    h2("Poverty Clustering — Central Sulawesi Province (2022)"),
    p("PCA + Average Linkage Hierarchical Clustering | BPS Data"),
    div(class = "medal-badge", "🥇 Gold Medal — i-JaMCSIIX 2023, Universiti Teknologi MARA, Malaysia")
  ),

  # KPI strip
  fluidRow(
    column(3, div(class = "stat-box",
      div(class = "stat-num", "13"),
      div(class = "stat-lbl", "Regencies / Cities analyzed"))),
    column(3, div(class = "stat-box",
      div(class = "stat-num", "6"),
      div(class = "stat-lbl", "Poverty indicator variables"))),
    column(3, div(class = "stat-box",
      div(class = "stat-num", "82.67%"),
      div(class = "stat-lbl", "Variance explained by PC1 + PC2"))),
    column(3, div(class = "stat-box",
      div(class = "stat-num", "2"),
      div(class = "stat-lbl", "Optimal clusters (silhouette)")))
  ),

  # Tabs
  tabsetPanel(

    # Tab 1: Cluster Plot
    tabPanel("Cluster Visualization",
      br(),
      fluidRow(
        column(9, plotOutput("clusterPlot", height = "480px")),
        column(3,
          h5("Filter Cluster"),
          checkboxGroupInput("clust_filter", NULL,
            choices  = c("Cluster 1 — High Poverty",
                         "Cluster 2 — Low Poverty"),
            selected = c("Cluster 1 — High Poverty",
                         "Cluster 2 — Low Poverty")),
          hr(),
          h6("Cluster 1 — High Poverty (12 regencies)"),
          p(style="font-size:12px;color:#555;",
            paste(raw$Regency_City[raw$Cluster=="Cluster 1 — High Poverty"],
                  collapse=", ")),
          hr(),
          h6("Cluster 2 — Low Poverty (1 city)"),
          p(style="font-size:12px;color:#27AE60;font-weight:bold;","Palu City")
        )
      )
    ),

    # Tab 2: Dendrogram
    tabPanel("Dendrogram",
      br(),
      plotOutput("dendroPlot", height = "520px")
    ),

    # Tab 3: Variable Comparison
    tabPanel("Variable Analysis",
      br(),
      fluidRow(
        column(4,
          selectInput("var_select", "Select Variable:",
            choices = setNames(names(var_labels), var_labels))
        )
      ),
      plotOutput("varPlot", height = "420px")
    ),

    # Tab 4: Data Table
    tabPanel("Data Table",
      br(),
      DTOutput("dataTable")
    ),

    # Tab 5: PCA Info
    tabPanel("PCA Results",
      br(),
      fluidRow(
        column(6, plotOutput("screePlot", height = "380px")),
        column(6, plotOutput("biplotPlot", height = "380px"))
      ),
      br(),
      tableOutput("pcaTable")
    )
  )
)

# ── SERVER ────────────────────────────────────────────────────
server <- function(input, output, session) {

  filtered <- reactive({
    pca_scores[pca_scores$Cluster %in% input$clust_filter, ]
  })

  # Cluster scatter plot
  output$clusterPlot <- renderPlot({
    df <- filtered()
    if (nrow(df) == 0) return(NULL)

    ggplot(df, aes(x = PC1, y = PC2, color = Cluster, fill = Cluster)) +
      stat_ellipse(geom = "polygon", alpha = 0.08, linetype = 2) +
      geom_point(size = 4, alpha = .9) +
      geom_text_repel(aes(label = Regency_City), size = 3.5,
                      max.overlaps = 20, show.legend = FALSE) +
      scale_color_manual(values = cluster_colors) +
      scale_fill_manual(values  = cluster_colors) +
      labs(
        title    = "PCA + Average Linkage Clustering",
        subtitle = "Central Sulawesi Province — Poverty Level 2022",
        x = paste0("PC1 (", round(summary(pca_res)$importance[2,1]*100,1), "% variance)"),
        y = paste0("PC2 (", round(summary(pca_res)$importance[2,2]*100,1), "% variance)"),
        color = "Cluster", fill = "Cluster"
      ) +
      theme_minimal(base_size = 13) +
      theme(legend.position = "bottom",
            plot.title    = element_text(face = "bold"),
            plot.subtitle = element_text(color = "grey40"))
  })

  # Dendrogram
  output$dendroPlot <- renderPlot({
    par(mar = c(6, 4, 4, 2))
    plot(hier_ave,
         labels = raw$Regency_City,
         hang   = -1,
         col    = "steelblue",
         main   = "Dendrogram — Average Linkage Clustering\nPoverty Level in Central Sulawesi (2022)",
         xlab   = "Regency / City",
         ylab   = "Euclidean Distance",
         cex    = 0.9,
         cex.main = 1.2)
    rect.hclust(hier_ave, k = 2, border = c("#E74C3C", "#27AE60"))
    legend("topright", legend = c("Cluster 1 (High Poverty)", "Cluster 2 (Low Poverty)"),
           fill = c("#E74C3C", "#27AE60"), cex = 0.85)
  })

  # Variable bar chart
  output$varPlot <- renderPlot({
    vname <- input$var_select
    df_plot <- data.frame(
      Regency  = raw$Regency_City,
      Value    = raw[[vname]],
      Cluster  = raw$Cluster
    )
    df_plot <- df_plot[order(df_plot$Value, decreasing = TRUE), ]
    df_plot$Regency <- factor(df_plot$Regency, levels = df_plot$Regency)

    ggplot(df_plot, aes(x = Regency, y = Value, fill = Cluster)) +
      geom_col(alpha = .85, width = .7) +
      geom_text(aes(label = round(Value, 2)), hjust = -0.15, size = 3.5) +
      coord_flip() +
      scale_fill_manual(values = cluster_colors) +
      labs(
        title    = var_labels[vname],
        subtitle = "Central Sulawesi Province — 2022",
        x = NULL, y = var_labels[vname], fill = "Cluster"
      ) +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(face = "bold"),
            legend.position = "bottom") +
      expand_limits(y = max(df_plot$Value) * 1.12)
  })

  # Data table
  output$dataTable <- renderDT({
    df_tbl <- raw
    names(df_tbl) <- c("Regency/City",
                        "Poor People", "Poverty Depth",
                        "HDI", "Gini Ratio",
                        "Poverty Severity", "Unemployment %",
                        "Cluster")
    datatable(df_tbl,
      options  = list(pageLength = 13, dom = "t"),
      rownames = FALSE,
      class    = "stripe hover compact"
    ) %>%
      formatStyle("Cluster",
        backgroundColor = styleEqual(
          c("Cluster 1 — High Poverty", "Cluster 2 — Low Poverty"),
          c("#FADBD8", "#D5F5E3")
        )
      )
  })

  # Scree plot
  output$screePlot <- renderPlot({
    fviz_eig(pca_res, addlabels = TRUE, ylim = c(0, 70),
             main = "Scree Plot — Variance per Component") +
      theme_minimal(base_size = 12)
  })

  # Biplot
  output$biplotPlot <- renderPlot({
    fviz_pca_biplot(pca_res,
      repel     = TRUE,
      col.var   = "#1a3a5c",
      col.ind   = cluster_colors[as.character(raw$Cluster)],
      label     = "var",
      title     = "PCA Biplot — Variables & Observations"
    ) + theme_minimal(base_size = 12)
  })

  # PCA summary table
  output$pcaTable <- renderTable({
    imp <- summary(pca_res)$importance
    df  <- as.data.frame(t(imp))
    df  <- df[1:6, ]
    df$Component <- paste0("PC", 1:6)
    df$`Eigenvalue` <- round(pca_res$sdev[1:6]^2, 4)
    df$`Std Dev` <- round(pca_res$sdev[1:6], 4)
    df$`Proportion of Variance (%)` <- round(imp[2,1:6]*100, 2)
    df$`Cumulative Variance (%)` <- round(imp[3,1:6]*100, 2)
    df$Selected <- ifelse(pca_res$sdev[1:6]^2 > 1, "✓ Selected", "")
    df[, c("Component","Eigenvalue","Proportion of Variance (%)","Cumulative Variance (%)","Selected")]
  }, striped = TRUE, hover = TRUE, bordered = TRUE)
}

# ── RUN ───────────────────────────────────────────────────────
shinyApp(ui = ui, server = server)
