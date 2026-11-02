---
name: synapse-generate-notebook
description: Usa esta skill cuando el usuario quiera generar el esqueleto inicial de un notebook de datos de Azure Synapse (o Databricks) con una estructura estándar de celdas, cuando pida "crea una plantilla de notebook", "arma el esqueleto del notebook de ingesta" o describa una tarea de ETL/análisis que arrancará desde un notebook en blanco.
status: production
owner: orlando.herrera
tools: [claude-code, codex]
---

# Generar plantilla de notebook de datos

Produce el esqueleto de un notebook con una estructura de celdas estándar del equipo.
Genera el contenido como celdas de código y markdown; no ejecuta nada.

## Estructura de celdas

1. **Markdown — Título y propósito**: nombre del notebook, autor, fecha, qué resuelve.
2. **Código — Parámetros**: widgets/variables de entrada (rutas, fechas, nombre de tabla).
3. **Código — Imports y configuración**: librerías y sesión (Spark u otra).
4. **Código — Extracción**: lectura de las fuentes declaradas en parámetros.
5. **Código — Transformación**: una celda por paso lógico, con un comentario de qué hace.
6. **Código — Validación**: conteos y chequeos mínimos de calidad (nulos, duplicados, rango de fechas).
7. **Código — Escritura**: destino, modo (append/overwrite) y partición.
8. **Markdown — Notas**: supuestos, pendientes y cómo reejecutar.

## Reglas

- Pregunta primero: motor (Databricks / Synapse / genérico), lenguaje (PySpark / SQL) y nombre de la tarea.
- Deja `TODO:` explícitos donde falte información del usuario; no inventes rutas ni nombres de tabla reales.
- Mantén las celdas de validación aunque el usuario no las pida: son parte del estándar.
