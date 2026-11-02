---
name: adf-validate-pipeline
description: Usa esta skill cuando el usuario quiera revisar o validar la definición JSON de un pipeline de Azure Data Factory antes de desplegarlo, por ejemplo cuando comparta un archivo de pipeline ADF, pida "validar este pipeline", "revisar el ADF" o pregunte si la configuración de actividades y dependencias es correcta.
status: experimental
owner: ana.ruiz
tools: [claude-code]
---

# Validar pipeline de Azure Data Factory

Revisa la definición de un pipeline de ADF (JSON) y reporta problemas antes del despliegue.
Esta skill NO ejecuta nada contra Azure: solo analiza el JSON que el usuario proporciona.

## Qué revisar

1. **Actividades**: cada actividad tiene `name`, `type` y `typeProperties`. Nombres únicos dentro del pipeline.
2. **Dependencias**: cada `dependsOn` referencia una actividad que existe y no genera ciclos.
3. **Parámetros y variables**: todo `@pipeline().parameters.X` usado está declarado en `parameters`.
4. **Linked services / datasets**: las referencias (`referenceName`) no están vacías.
5. **Reintentos y timeouts**: las actividades críticas (Copy, Databricks, Stored Procedure) declaran `policy` con `retry` y `timeout`.

## Cómo responder

- Lista los hallazgos en tres niveles: **Bloqueante**, **Advertencia**, **Sugerencia**.
- Para cada hallazgo indica la actividad afectada y la línea o propiedad.
- Si no hay problemas bloqueantes, dilo explícitamente.
- No inventes propiedades: si falta información para juzgar algo, señálalo como "no verificable con el JSON dado".
