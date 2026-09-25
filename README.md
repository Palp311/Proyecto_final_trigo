# EDA de trigo bajo estrés térmico

Proyecto del curso para explorar datos simulados inspirados en una tesis sobre respuestas de trigo duro (*Triticum durum*) al calor durante antesis.

## Dataset

El conjunto integra 40 muestras de cinco genotipos, dos tratamientos (`Control` y `Calor`) y cuatro bloques. Las tres tablas comparten `sample_id`:

- `data/raw/physiology_simulated.csv`: intercambio gaseoso, fluorescencia y rasgos foliares.
- `data/raw/ionomics_simulated.csv`: macro y micronutrientes.
- `data/raw/metabolomics_simulated.csv`: abundancias relativas simuladas de ocho metabolitos, en unidades arbitrarias.

Todos los valores son simulados para practicar; no son mediciones ni resultados de tesis. El script verifica que las muestras y sus metadatos coincidan, integra las tablas y guarda `data/processed/dataset_integrado_simulado.csv`.

## EDA

Con R base, ejecuta desde la carpeta raíz:

```sh
Rscript scripts/01_eda.R
```

El script muestra dimensiones, valores ausentes y promedios de fotosíntesis neta, potasio y prolina por tratamiento. También guarda una figura exploratoria en `figures/eda_multicapa.pdf`. Los gráficos son descriptivos; no se hacen inferencias estadísticas con estos datos sintéticos.

## Estructura

```text
curso-eda-trigo/
├── data/
│   ├── raw/          # Tablas simuladas por capa
│   └── processed/    # Tabla integrada generada por el script
├── figures/          # Figura del EDA
├── reports/          # Reflexión de datos ausentes y texto para la actividad
└── scripts/          # Código reproducible en R
```
