# Ruta de tareas — Organización de skills de IA

Archivo de trabajo del equipo. Vamos marcando `[x]` lo realizado.
No forma parte del repo de skills; es nuestro seguimiento interno.
Convención: nombres de archivos y carpetas en inglés, contenido en español.

Última actualización: 2026-11-02 (Fase 2 completada)

---

## Fase 0 — Alinear ideas

- [x] Revisar el deck "Organización de Skills de IA"
- [x] Decidir modelo: **un repo con `status` dentro del SKILL.md** (no repo-por-estado)
- [x] Elegir los 4 principios base para empezar (nombres, una carpeta por skill, estado en SKILL.md, owner)
- [x] Definir regla de seguridad no negociable (sin credenciales ni datos de cliente en el repo)
- [x] Contemplar futuro multi-LLM (Claude Code, Codex; luego posible Gemini CLI / Copilot)
- [x] Acordar convención de prefijos: `adf-` (Data Factory), `synapse-` (Synapse)
- [x] Aclarar que NO hay estándar de "N letras"; longitud libre, prefijo corto y estable
- [x] Acordar idioma: nombres de archivos/carpetas en inglés, contenido en español

## Fase 1 — Estructura y skills de prueba

- [x] Crear estructura del repo (`skills-repo/` con `skills/`, `INDEX.md`, `CODEOWNERS`, `README.md`)
- [x] Crear 3 skills de prueba con estados distintos:
  - [x] `adf-validate-pipeline` (experimental)
  - [x] `sql-format-query` (stable)
  - [x] `synapse-generate-notebook` (production)
- [x] Documentar convención de nombres y tabla de prefijos en el README

## Fase 2 — Puerta de entrada para agentes

- [x] Crear `CLAUDE.md` (stub de pocas líneas que apunta al README)
- [x] Crear `AGENTS.md` (stub idéntico en intención, para Codex)
- [ ] (Futuro, solo cuando entre Gemini) Crear `GEMINI.md`

## Fase 3 — Subir a GitHub

- [ ] `git init` + primer commit
- [ ] Crear repo **privado** en GitHub
- [ ] Reemplazar handles de ejemplo en `CODEOWNERS` por los reales
- [ ] Push

## Fase 4 — Probar el flujo real (valida la idea de "descargar y aprovisionar")

- [ ] Clonar el repo en una ubicación de prueba
- [ ] Copiar a mano una skill a un proyecto de ejemplo (`.claude/skills/`)
- [ ] Confirmar que el agente la detecta y la usa
- [ ] Anotar fricciones encontradas

## Fase 5 — Automatización (solo cuando copiar a mano empiece a doler)

- [ ] Definir `skills.txt` por proyecto (análogo a `requirements.txt`)
- [ ] Script de aprovisionamiento que lee `skills.txt`, comprueba `status` y copia
- [ ] Decidir: ¿script propio o mecanismo nativo de cada herramienta?

## Fase 6 — Calidad (futuro)

- [ ] Definir qué significa "testing" para una skill
- [ ] Validación automática en CI (pipeline)

---

## Decisiones tomadas (registro rápido)

- Modelo de estado: campo `status` en el SKILL.md, la skill nunca cambia de carpeta.
- Estados: `experimental` → `stable` → `production`.
- Prefijos: `adf-`, `synapse-`. Nuevos dominios se agregan por PR al README.
- Idioma: archivos y carpetas en inglés; contenido en español. La acción del nombre es verbo en inglés (`validate`, `format`, `generate`).
- Multi-LLM: README como única fuente de verdad; cada agente tiene un stub que apunta a él.
- Seguridad: nada de secretos ni datos de cliente en el repo.

## Preguntas abiertas / por decidir

- ¿Script de sync propio o camino nativo de Claude Code / Codex? (revisar en Fase 5)
- Handles reales de GitHub para `CODEOWNERS`.
- ¿Qué es un "test" de skill y cómo se automatiza? (Fase 6)
