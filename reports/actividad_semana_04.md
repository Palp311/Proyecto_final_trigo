# Actividad semanal 4

## 1. Dataset elegido

Para mi proyecto final trabajaré con un conjunto de datos de práctica simulado, inspirado en mi tesis sobre la respuesta del trigo duro (*Triticum durum*) al estrés térmico durante antesis. Integra 40 muestras de cinco genotipos, dos tratamientos (control y calor) y cuatro bloques. Incluye tres capas vinculadas por `sample_id`: fisiología (intercambio gaseoso, fluorescencia y rasgos foliares), ionómica (macro y micronutrientes) y metabolómica (ocho metabolitos con abundancias relativas en unidades arbitrarias). Todos los valores son simulados; no representan mediciones ni resultados de mi tesis.

## 2. Repositorio

Repositorio público: [Palp311/Proyecto_final_trigo](https://github.com/Palp311/Proyecto_final_trigo). Incluye un proyecto de RStudio y carpetas descriptivas para datos crudos, datos procesados, scripts, figuras e informes.

## 3. EDA

Ejecuté `Rscript scripts/01_eda.R`. La tabla integrada tiene 40 muestras y 28 columnas, con 23 mediciones numéricas; no contiene NA. El diseño tiene cuatro muestras por cada combinación de cinco genotipos y dos tratamientos. En calor, la media simulada de fotosíntesis neta fue 12,59 frente a 22,12 en control (−43,1 %); la de potasio fue 30,37 frente a 38,52 (−21,2 %); y la de prolina, 64,69 frente a 41,04 (+57,6 %). Las [distribuciones por genotipo](../figures/eda_multicapa.pdf) y la [relación entre fotosíntesis y prolina](../figures/eda_relacion_capas.pdf) complementan los [resúmenes tabulares](eda_detallado.md). Son patrones programados en datos simulados, sin valor como resultados científicos.

## 4. Datos ausentes

En las tablas simuladas no hay NA. En datos reales podría haber MCAR si se pierde al azar un archivo; MAR si un equipo falla más bajo el tratamiento de calor y ese tratamiento está registrado; y MNAR si un metabolito de muy baja abundancia queda bajo el límite de detección. No eliminaría automáticamente los datos ausentes: revisaría su causa y patrón, conservaría el motivo cuando se conozca y decidiría el tratamiento según el mecanismo plausible y el análisis.
