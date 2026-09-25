# Exploratory analysis of simulated physiology, ionomics, and metabolomics data.
required_packages <- c("dplyr", "tidyr", "ggplot2", "readr")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(missing_packages) > 0) {
  stop("Install missing packages: ", paste(missing_packages, collapse = ", "))
}
suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(readr)
})

data_dir <- file.path("data", "raw")
output_dir <- file.path("data", "processed")
figure_dir <- "figures"
report_dir <- "reports"
metadata <- c("sample_id", "bloque", "tratamiento", "genotipo")

read_layer <- function(filename) {
  path <- file.path(data_dir, filename)
  if (!file.exists(path)) stop("Missing input file: ", path)
  data <- read_csv(
    path,
    na = c("", "NA", "N/A", "-9999"),
    show_col_types = FALSE
  )
  if (nrow(problems(data)) > 0) stop("Parsing problems in: ", path)
  missing_metadata <- setdiff(metadata, names(data))
  if (length(missing_metadata) > 0) {
    stop("Missing metadata in ", filename, ": ", paste(missing_metadata, collapse = ", "))
  }
  if (anyNA(data[metadata])) stop("Missing metadata in: ", filename)
  if (anyDuplicated(data$sample_id)) stop("Repeated sample_id in: ", filename)
  data
}

physiology <- read_layer("physiology_simulated.csv")
ionomics <- read_layer("ionomics_simulated.csv")
metabolomics <- read_layer("metabolomics_simulated.csv")

check_alignment <- function(reference, candidate, layer_name) {
  if (!setequal(reference$sample_id, candidate$sample_id)) {
    stop("sample_id differs in ", layer_name)
  }
  unmatched_metadata <- anti_join(
    select(reference, all_of(metadata)),
    select(candidate, all_of(metadata)),
    by = metadata
  )
  if (nrow(unmatched_metadata) > 0) stop("Metadata differs in ", layer_name)
}
check_alignment(physiology, ionomics, "ionomics")
check_alignment(physiology, metabolomics, "metabolomics")

integrated <- physiology %>%
  left_join(select(ionomics, -all_of(metadata[-1])),
            by = "sample_id", relationship = "one-to-one") %>%
  left_join(select(metabolomics, -all_of(metadata[-1])),
            by = "sample_id", relationship = "one-to-one")

measurement_cols <- setdiff(names(integrated), c(metadata, "tipo_dato"))
nonnumeric_cols <- measurement_cols[
  !vapply(integrated[measurement_cols], is.numeric, logical(1))
]
if (length(nonnumeric_cols) > 0) {
  stop("Measurements must be numeric: ", paste(nonnumeric_cols, collapse = ", "))
}

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(report_dir, recursive = TRUE, showWarnings = FALSE)
write_csv(integrated, file.path(output_dir, "dataset_integrado_simulado.csv"), na = "NA")

variable_layers <- data.frame(
  variable = c(
    setdiff(names(physiology), metadata),
    setdiff(names(ionomics), metadata),
    setdiff(names(metabolomics), c(metadata, "tipo_dato"))
  ),
  layer = c(
    rep("Fisiología", length(setdiff(names(physiology), metadata))),
    rep("Ionómica", length(setdiff(names(ionomics), metadata))),
    rep("Metabolómica", length(setdiff(names(metabolomics), c(metadata, "tipo_dato"))))
  )
)
long_data <- integrated %>%
  pivot_longer(all_of(measurement_cols), names_to = "variable", values_to = "value") %>%
  left_join(variable_layers, by = "variable", relationship = "many-to-one")
write_csv(long_data, file.path(output_dir, "dataset_largo_simulado.csv"), na = "NA")

design_counts <- integrated %>% count(genotipo, tratamiento, name = "n_muestras")
missing_summary <- long_data %>%
  group_by(layer, variable) %>%
  summarise(
    n_total = n(),
    n_missing = sum(is.na(value)),
    percent_missing = round(100 * n_missing / n_total, 1),
    .groups = "drop"
  ) %>%
  arrange(desc(n_missing), layer, variable)

summarize_distribution <- function(data, groups) {
  data %>%
    group_by(across(all_of(groups))) %>%
    summarise(
      n = sum(!is.na(value)),
      n_missing = sum(is.na(value)),
      mean = if (n > 0) mean(value, na.rm = TRUE) else NA_real_,
      sd = if (n > 1) sd(value, na.rm = TRUE) else NA_real_,
      median = if (n > 0) median(value, na.rm = TRUE) else NA_real_,
      q1 = if (n > 0) as.numeric(quantile(value, 0.25, na.rm = TRUE)) else NA_real_,
      q3 = if (n > 0) as.numeric(quantile(value, 0.75, na.rm = TRUE)) else NA_real_,
      .groups = "drop"
    ) %>%
    mutate(across(c(mean, sd, median, q1, q3), ~ round(.x, 2)))
}

summary_treatment <- summarize_distribution(
  long_data, c("layer", "variable", "tratamiento")
)
summary_genotype <- summarize_distribution(
  long_data, c("layer", "variable", "tratamiento", "genotipo")
)
relative_change <- long_data %>%
  group_by(layer, variable, tratamiento) %>%
  summarise(
    mean = if (all(is.na(value))) NA_real_ else mean(value, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_wider(names_from = tratamiento, values_from = mean) %>%
  mutate(percent_change = if_else(
    is.na(Control) | is.na(Calor) | Control == 0,
    NA_real_,
    round(100 * (Calor - Control) / Control, 1)
  )) %>%
  mutate(across(c(Control, Calor), ~ round(.x, 2)))

spearman_or_na <- function(x, y) {
  complete <- complete.cases(x, y)
  if (sum(complete) < 3 || n_distinct(x[complete]) < 2 ||
      n_distinct(y[complete]) < 2) return(NA_real_)
  round(cor(x[complete], y[complete], method = "spearman"), 2)
}
correlations <- integrated %>%
  group_by(tratamiento) %>%
  summarise(
    n_A_K = sum(complete.cases(A_net, K_mg_g)),
    rho_A_K = spearman_or_na(A_net, K_mg_g),
    n_A_Prolina = sum(complete.cases(A_net, Prolina)),
    rho_A_Prolina = spearman_or_na(A_net, Prolina),
    .groups = "drop"
  )

write_csv(design_counts, file.path(report_dir, "eda_diseno.csv"))
write_csv(missing_summary, file.path(report_dir, "eda_faltantes.csv"))
write_csv(summary_treatment, file.path(report_dir, "eda_resumen_tratamiento.csv"), na = "NA")
write_csv(summary_genotype, file.path(report_dir, "eda_resumen_genotipo.csv"), na = "NA")
write_csv(relative_change, file.path(report_dir, "eda_cambios_relativos.csv"), na = "NA")
write_csv(correlations, file.path(report_dir, "eda_correlaciones.csv"), na = "NA")

cat("SIMULATED DATA: descriptive EDA only\n")
cat("Integrated data:", nrow(integrated), "samples,", ncol(integrated),
    "columns,", length(measurement_cols), "numeric measurements\n")
cat("Samples by genotype and treatment:\n")
print(design_counts, n = Inf)
cat("Missing values in the full table:", sum(is.na(integrated)), "\n")
cat("Selected descriptive statistics by treatment:\n")
print(
  summary_treatment %>%
    filter(variable %in% c("A_net", "K_mg_g", "Prolina")) %>%
    select(variable, tratamiento, n, mean, sd, median, q1, q3),
  n = Inf
)
cat("Exploratory Spearman correlations within treatment:\n")
print(correlations)
cat("Selected relative changes (heat versus control):\n")
print(relative_change %>%
        filter(variable %in% c("A_net", "K_mg_g", "Prolina")) %>%
        select(variable, Control, Calor, percent_change))

key_labels <- c(
  A_net = "Fotosíntesis (umol CO2 m-2 s-1)",
  K_mg_g = "Potasio (mg/g)",
  Prolina = "Prolina (AU)"
)
treatment_colors <- c(Control = "#0072B2", Calor = "#D55E00")
key_data <- long_data %>%
  filter(variable %in% names(key_labels)) %>%
  mutate(
    variable = factor(variable, levels = names(key_labels), labels = unname(key_labels)),
    tratamiento = factor(tratamiento, levels = c("Control", "Calor"))
  )

distribution_plot <- ggplot(
  key_data, aes(x = genotipo, y = value, fill = tratamiento)
) +
  geom_boxplot(width = 0.6, alpha = 0.75, outlier.shape = NA,
               position = position_dodge(width = 0.75)) +
  geom_point(shape = 21, color = "#222222", size = 1.5, alpha = 0.8,
             position = position_jitterdodge(jitter.width = 0.08,
                                             dodge.width = 0.75, seed = 42)) +
  facet_wrap(~ variable, scales = "free_y", nrow = 1) +
  scale_fill_manual(values = treatment_colors) +
  labs(
    title = "Tres capas bajo control y calor",
    subtitle = "Datos simulados; puntos = muestras individuales",
    x = "Genotipo", y = "Valor (unidad indicada en cada panel)",
    fill = "Tratamiento",
    caption = "Cajas: mediana y rango intercuartílico; cuatro muestras por combinación."
  ) +
  theme_bw(base_size = 11) +
  theme(legend.position = "bottom", panel.grid.minor = element_blank(),
        plot.title = element_text(face = "bold"))

relationship_plot <- ggplot(
  integrated, aes(x = A_net, y = Prolina, color = genotipo)
) +
  geom_point(size = 2.4, alpha = 0.85) +
  facet_wrap(~ tratamiento) +
  scale_color_manual(values = c(
    G1 = "#0072B2", G2 = "#D55E00", G3 = "#009E73",
    G4 = "#CC79A7", G5 = "#E69F00"
  )) +
  labs(
    title = "Fotosíntesis y prolina por tratamiento",
    subtitle = "Relación exploratoria entre fisiología y metabolómica",
    x = "Fotosíntesis neta (umol CO2 m-2 s-1)",
    y = "Prolina (abundancia relativa, AU)",
    color = "Genotipo",
    caption = "Datos simulados; la asociación no implica causalidad."
  ) +
  theme_bw(base_size = 11) +
  theme(legend.position = "bottom", panel.grid.minor = element_blank(),
        plot.title = element_text(face = "bold"))

ggsave(file.path(figure_dir, "eda_multicapa.pdf"), distribution_plot,
       width = 11, height = 4.8, units = "in", device = grDevices::pdf,
       timestamp = FALSE)
ggsave(file.path(figure_dir, "eda_relacion_capas.pdf"), relationship_plot,
       width = 8, height = 4.8, units = "in", device = grDevices::pdf,
       timestamp = FALSE)
cat("Figures saved to figures/eda_multicapa.pdf and figures/eda_relacion_capas.pdf\n")
