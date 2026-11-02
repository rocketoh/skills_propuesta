# Instrucciones para el agente (Claude Code)

Este repositorio es el **catálogo central de skills** del equipo.

Antes de crear, modificar o promover una skill, **lee `README.md`**: ahí viven la convención
de nombres, los prefijos acordados, el ciclo de vida (`experimental` → `stable` → `production`)
y la regla de seguridad. El `README.md` es la única fuente de verdad; este archivo solo te
indica por dónde empezar.

Recordatorios rápidos:
- Cada skill vive en `skills/<prefijo>-<acción>/SKILL.md`. Nombres de carpeta en inglés, minúsculas y guiones.
- El `name` del frontmatter debe ser idéntico al nombre de la carpeta.
- Nunca escribas credenciales, llaves ni datos de clientes en el repo.
