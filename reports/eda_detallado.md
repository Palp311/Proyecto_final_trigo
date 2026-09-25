# Análisis exploratorio de las tres capas

El conjunto es **simulado** y sirve para practicar un flujo reproducible de análisis. Los patrones descritos no son resultados de la tesis ni evidencia de una respuesta biológica real.

## Integridad y diseño

El script comprobó que las tres tablas compartieran los mismos `sample_id` y metadatos, sin identificadores duplicados. La tabla integrada contiene 40 muestras, 28 columnas y 23 mediciones numéricas. Hay cinco genotipos, dos tratamientos y cuatro muestras por combinación genotipo–tratamiento. No se detectaron valores ausentes en la tabla actual. El detalle está en `eda_diseno.csv` y `eda_faltantes.csv`.

## Distribuciones y contraste descriptivo

| Medición | Control, media ± DE (n = 20) | Calor, media ± DE (n = 20) | Cambio relativo |
| --- | ---: | ---: | ---: |
| Fotosíntesis neta, A_net | 22,12 ± 1,96 | 12,59 ± 4,39 | −43,1 % |
| Potasio, K_mg_g | 38,52 ± 1,30 | 30,37 ± 3,60 | −21,2 % |
| Prolina | 41,04 ± 2,75 | 64,69 ± 5,22 | +57,6 % |

Los porcentajes son `(media_calor − media_control) / media_control × 100`; son comparaciones descriptivas. La [figura de distribuciones](../figures/eda_multicapa.pdf) conserva los puntos individuales y muestra que la variabilidad también difiere entre grupos. Bajo calor, la media simulada de A_net es 17,62 en G1 y 17,90 en G3, frente a 8,79–9,38 en G2, G4 y G5. Hay solo cuatro muestras por genotipo y tratamiento, por lo que esta comparación debe leerse con cautela. Los valores completos, incluidos mediana y cuartiles para las 23 mediciones, están en `eda_resumen_tratamiento.csv`, `eda_resumen_genotipo.csv` y `eda_cambios_relativos.csv`.

## Relaciones entre capas

Dentro del tratamiento de calor, la correlación de Spearman entre A_net y potasio fue ρ = 0,61 (n = 20), y entre A_net y prolina fue ρ = −0,35 (n = 20). En control fueron −0,17 y −0,02, respectivamente. La [figura de relación](../figures/eda_relacion_capas.pdf) permite inspeccionar los puntos por genotipo. Estas asociaciones pueden reflejar diferencias programadas entre genotipos y no establecen causalidad; no se aplicaron pruebas de hipótesis ni se reportan valores p. La tabla reproducible está en `eda_correlaciones.csv`.

## Próximos pasos analíticos

Con datos reales habría que revisar unidades, rangos plausibles, valores bajo el límite de detección y el mecanismo de ausencia antes de transformar o imputar. También convendría verificar cómo se asignaron los bloques y tratamientos antes de plantear modelos inferenciales. En este ejercicio, el objetivo es practicar integración, control de calidad, resumen y visualización.
