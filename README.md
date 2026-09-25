# Proyecto trigo bajo estrés térmico

Proyecto del curso para explorar datos simulados inspirados en una tesis sobre respuestas de trigo duro (*Triticum durum*) al calor durante antesis.

## Dataset

El conjunto integra 40 muestras de cinco genotipos, dos tratamientos (`Control` y `Calor`) y cuatro bloques. Las tres tablas comparten `sample_id`:

- `data/raw/physiology_simulated.csv`: intercambio gaseoso, fluorescencia y rasgos foliares.
- `data/raw/ionomics_simulated.csv`: macro y micronutrientes.
- `data/raw/metabolomics_simulated.csv`: abundancias relativas simuladas de ocho metabolitos, en unidades arbitrarias.

Todos los valores son simulados para practicar; no son mediciones ni resultados de tesis. El script verifica que las muestras y sus metadatos coincidan, integra las tablas y guarda `data/processed/dataset_integrado_simulado.csv`.

## EDA

Abre `Proyecto_final_trigo.Rproj` en RStudio. El análisis usa `dplyr`, `tidyr`, `readr` y `ggplot2`; si faltan, instálalos una vez con `install.packages(c("dplyr", "tidyr", "readr", "ggplot2"))`. Luego ejecuta el script desde la raíz del proyecto:

```sh
Rscript scripts/01_eda.R
```

La ejecución se verificó con R 4.6.1, dplyr 1.2.1, tidyr 1.3.2, readr 2.2.0 y ggplot2 4.0.3.

El script valida los identificadores y metadatos de las tres capas, crea una tabla integrada y otra en formato largo, y comprueba la cantidad de muestras y datos ausentes. Produce resúmenes por tratamiento y genotipo (n, media, desviación estándar, mediana y cuartiles), cambios porcentuales frente al control y correlaciones exploratorias de Spearman dentro de cada tratamiento. Los resultados tabulares están en `reports/eda_*.csv`; la interpretación está en [`reports/eda_detallado.md`](reports/eda_detallado.md).

Las figuras [`figures/eda_multicapa.pdf`](figures/eda_multicapa.pdf) y [`figures/eda_relacion_capas.pdf`](figures/eda_relacion_capas.pdf) muestran las distribuciones de las tres capas y la relación entre fotosíntesis y prolina. Todo el análisis es descriptivo: los datos sintéticos no permiten conclusiones científicas.

## Estructura

```text
Proyecto_final_trigo/
├── Proyecto_final_trigo.Rproj
├── data/
│   ├── raw/          # Tablas simuladas por capa
│   └── processed/    # Tablas integrada y larga generadas por el script
├── figures/          # Figuras del EDA
├── reports/          # Resúmenes, interpretación y actividad semanal
└── scripts/          # Código reproducible en R
```
