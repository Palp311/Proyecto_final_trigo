# Reflexión sobre datos ausentes

Las tablas de práctica están simuladas y actualmente no contienen valores ausentes. En datos reales de fisiología, ionómica o metabolómica podrían aparecer por distintas razones:

- **MCAR:** se pierde al azar un archivo de una muestra durante una transferencia, sin relación con el genotipo, tratamiento, bloque o magnitud de las mediciones.
- **MAR:** faltan más lecturas de intercambio gaseoso en días de calor porque el equipo se interrumpe con mayor frecuencia bajo esas condiciones. El patrón depende del tratamiento observado.
- **MNAR:** un metabolito de concentración muy baja queda bajo el límite de detección, o una hoja severamente dañada no puede medirse. La probabilidad de ausencia depende del propio valor no observado.

Un `0` es un dato válido cuando representa una medición real; no equivale a una celda vacía ni a `NA`. Registraría los faltantes como `NA` y conservaría una columna de motivo si se conoce la causa. No eliminaría automáticamente las filas incompletas: primero resumiría los faltantes por variable, tratamiento, genotipo, bloque y lote analítico. La decisión de excluir, imputar o modelar los NA dependería de la causa, el mecanismo plausible y el análisis posterior. El mecanismo no se puede determinar solo mirando el patrón de NA.
