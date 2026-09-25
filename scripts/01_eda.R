# Integrate the simulated omics tables and run a descriptive EDA.
data_dir <- file.path("data", "raw")
output_dir <- file.path("data", "processed")
figure_dir <- "figures"

physiology <- read.csv(
  file.path(data_dir, "physiology_simulated.csv"),
  na.strings = c("", "NA", "N/A", "-9999"),
  stringsAsFactors = FALSE
)
ionomics <- read.csv(
  file.path(data_dir, "ionomics_simulated.csv"),
  na.strings = c("", "NA", "N/A", "-9999"),
  stringsAsFactors = FALSE
)
metabolomics <- read.csv(
  file.path(data_dir, "metabolomics_simulated.csv"),
  na.strings = c("", "NA", "N/A", "-9999"),
  stringsAsFactors = FALSE
)

metadata <- c("sample_id", "bloque", "tratamiento", "genotipo")
stopifnot(all(metadata %in% names(physiology)))
stopifnot(all(metadata %in% names(ionomics)))
stopifnot(all(metadata %in% names(metabolomics)))
stopifnot(!anyDuplicated(physiology$sample_id))
stopifnot(!anyDuplicated(ionomics$sample_id))
stopifnot(!anyDuplicated(metabolomics$sample_id))
stopifnot(setequal(physiology$sample_id, ionomics$sample_id))
stopifnot(setequal(physiology$sample_id, metabolomics$sample_id))

ionomics <- ionomics[match(physiology$sample_id, ionomics$sample_id), ]
metabolomics <- metabolomics[match(physiology$sample_id, metabolomics$sample_id), ]
for (field in metadata) {
  stopifnot(identical(physiology[[field]], ionomics[[field]]))
  stopifnot(identical(physiology[[field]], metabolomics[[field]]))
}

integrated <- cbind(
  physiology,
  ionomics[setdiff(names(ionomics), metadata)],
  metabolomics[setdiff(names(metabolomics), metadata)]
)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(
  integrated,
  file.path(output_dir, "dataset_integrado_simulado.csv"),
  row.names = FALSE,
  na = "NA"
)

cat("SIMULATED DATA: descriptive EDA only\n")
cat("Integrated dimensions:", nrow(integrated), "samples x", ncol(integrated), "variables\n")
cat("Samples by genotype and treatment:\n")
print(with(integrated, table(genotipo, tratamiento)))
cat("Missing values by variable:\n")
print(colSums(is.na(integrated)))

means <- aggregate(
  cbind(A_net, K_mg_g, Prolina) ~ tratamiento,
  data = integrated,
  FUN = function(x) round(mean(x, na.rm = TRUE), 2)
)
cat("Descriptive means by treatment (simulated values):\n")
print(means, row.names = FALSE)

group <- interaction(
  integrated$genotipo,
  factor(integrated$tratamiento, levels = c("Control", "Calor")),
  sep = " | ",
  drop = TRUE
)
group_colors <- ifelse(grepl("Calor", levels(group)), "#E69F00", "#56B4E9")
plot_data <- transform(integrated, grupo = group)

pdf(file.path(figure_dir, "eda_multicapa.pdf"), width = 13, height = 6)
par(mfrow = c(1, 3), mar = c(9, 4, 3, 1))
boxplot(
  A_net ~ grupo,
  data = plot_data,
  col = group_colors,
  las = 2,
  ylab = "A_net",
  xlab = "",
  main = "Fisiología: fotosíntesis"
)
boxplot(
  K_mg_g ~ grupo,
  data = plot_data,
  col = group_colors,
  las = 2,
  ylab = "K (mg/g)",
  xlab = "",
  main = "Ionomía: potasio"
)
boxplot(
  Prolina ~ grupo,
  data = plot_data,
  col = group_colors,
  las = 2,
  ylab = "Abundancia relativa (AU)",
  xlab = "",
  main = "Metabolómica: prolina"
)
invisible(dev.off())
cat("Figure saved to figures/eda_multicapa.pdf\n")
