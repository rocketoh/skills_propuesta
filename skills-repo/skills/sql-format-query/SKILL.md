---
name: sql-format-query
description: Usa esta skill cuando el usuario quiera dar formato, ordenar o estandarizar una consulta SQL, por ejemplo cuando pegue un query desordenado y pida "formatea este SQL", "ordena esta consulta", "aplica nuestro estilo SQL" o pida dejar un query legible antes de guardarlo o abrir un PR.
status: stable
owner: luis.gomez
tools: [claude-code, codex]
---

# Formatear una consulta SQL

Reescribe un query SQL aplicando un estilo consistente, sin cambiar su semántica.

## Reglas de estilo

- Palabras clave en MAYÚSCULAS (`SELECT`, `FROM`, `WHERE`, `JOIN`, `GROUP BY`).
- Un campo por línea en el `SELECT`, con la coma al inicio de línea.
- `JOIN` y su `ON` en líneas separadas, indentados bajo el `FROM`.
- Alias de tabla cortos y en minúsculas; usar `AS` explícito para alias de columna.
- Indentación de 4 espacios. Sin tabs.
- Una línea en blanco entre bloques lógicos (CTEs, subconsultas).

## Reglas duras

- **No alteres la lógica**: mismos campos, mismos filtros, mismo orden de resultados.
- No agregues ni quites columnas.
- Si el SQL tiene un error de sintaxis que impide formatearlo, no adivines: señala la línea y pide aclaración.
- Devuelve el query formateado en un bloque de código y, debajo, una lista breve de los cambios de formato aplicados.
