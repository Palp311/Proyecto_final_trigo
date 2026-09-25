# Actividad semanal 4

## 1. Dataset elegido

Para mi proyecto final trabajaré con un conjunto de datos de práctica simulado, inspirado en mi tesis sobre la respuesta del trigo duro (*Triticum durum*) al estrés térmico durante antesis. Integra 40 muestras de cinco genotipos, dos tratamientos (control y calor) y cuatro bloques. Incluye tres capas vinculadas por `sample_id`: fisiología (intercambio gaseoso, fluorescencia y rasgos foliares), ionómica (macro y micronutrientes) y metabolómica (ocho metabolitos con abundancias relativas en unidades arbitrarias). Todos los valores son simulados; no representan mediciones ni resultados de mi tesis.

## 2. Repositorio

Repositorio público: [Palp311/Proyecto_final_trigo](https://github.com/Palp311/Proyecto_final_trigo). Incluye un proyecto de RStudio y carpetas descriptivas para datos crudos, datos procesados, scripts, figuras e informes.

## 3. EDA

Ejecuté `Rscript scripts/01_eda.R`. La tabla integrada tiene 40 muestras y 28 variables; no contiene NA. Cada promedio usa 20 muestras por tratamiento. Los promedios simulados de fotosíntesis neta fueron 22,12 en control y 12,59 en calor; los de potasio, 38,52 y 30,37; y los de prolina, 41,04 y 64,69, respectivamente. El script crea [una figura exploratoria](../figures/eda_multicapa.pdf) que muestra una variable de cada capa por genotipo y tratamiento. Estos valores son descriptivos y simulados; no se deben interpretar como resultados científicos.

## 4. Datos ausentes

En las tablas simuladas no hay NA. En datos reales podría haber MCAR si se pierde al azar un archivo; MAR si un equipo falla más bajo el tratamiento de calor y ese tratamiento está registrado; y MNAR si un metabolito de muy baja abundancia queda bajo el límite de detección. No eliminaría automáticamente los datos ausentes: revisaría su causa y patrón, conservaría el motivo cuando se conozca y decidiría el tratamiento según el mecanismo plausible y el análisis.
