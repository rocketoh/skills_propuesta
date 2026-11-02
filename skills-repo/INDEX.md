# Índice de skills

Catálogo central. Cada skill vive en `skills/<nombre>/SKILL.md` y nunca cambia de carpeta:
su etapa se declara en el campo `status`, no en la ubicación.

| Skill | Herramienta | Status | Owner | Para qué sirve |
|-------|-------------|--------|-------|----------------|
| [adf-validate-pipeline](skills/adf-validate-pipeline/SKILL.md) | ADF | `experimental` | ana.ruiz | Valida el JSON de un pipeline de Azure Data Factory antes de desplegarlo. |
| [sql-format-query](skills/sql-format-query/SKILL.md) | SQL | `stable` | luis.gomez | Da formato estándar a una consulta SQL sin cambiar su lógica. |
| [synapse-generate-notebook](skills/synapse-generate-notebook/SKILL.md) | Synapse | `production` | orlando.herrera | Genera el esqueleto de un notebook de datos con la estructura del equipo. |

## Estados

| Status | Significa |
|--------|-----------|
| `experimental` | La usan 2-3 personas. La descripción aún se afina. No apta para procesos de cliente. |
| `stable` | Tests pasando, owner asignado, publicada aquí. Uso general. |
| `production` | Procesos que afectan a clientes. Cambios solo por PR aprobado por el owner. |

> Promover una skill = cambiar una palabra en su `status` y abrir un PR. No se mueve de carpeta ni de repo.
