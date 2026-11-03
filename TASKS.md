# Ruta de tareas — Organización de skills de IA

Archivo de trabajo del equipo. Vamos marcando `[x]` lo realizado.
No forma parte del repo de skills; es nuestro seguimiento interno.
Convención: nombres de archivos y carpetas en inglés, contenido en español.

Última actualización: 2026-11-02 (Fases 4 y 5 probadas a mano; 3 fricciones registradas)

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

- [x] `git init` + primer commit
- [x] Crear repo en GitHub y hacer push (cuenta personal: rocketoh/skills_propuesta)
- [ ] Reemplazar handles de ejemplo en `CODEOWNERS` por los reales
- [ ] (Pendiente/decisión) Repo quedó **Public** y con el proyecto completo (incluye deck y TASKS).
      Aceptado por ahora: es didáctico, sin credenciales. Cambiar a Private es 1 clic si se formaliza.
- [ ] (Futuro) Migrar a una GitHub Organization de Laureate cuando deje de ser prueba (Transfer ownership conserva el historial).

## Fase 4 — Probar el flujo real (valida la idea de "descargar y aprovisionar")

- [x] Clonar el repo en una ubicación de prueba (`skills_propuesta_repo_clonado`)
- [x] Copiar a mano una skill a un proyecto de ejemplo (`skills_propuesta_test_proyecto/.claude/skills/`)
- [ ] Confirmar que el agente la detecta y la usa (pendiente: lo valida el dev abriendo Claude Code en el proyecto)
- [x] Anotar fricciones encontradas (ver sección "Fricciones encontradas")

## Fase 5 — Automatización (solo cuando copiar a mano empiece a doler)

- [x] Definir `skills.txt` por proyecto (análogo a `requirements.txt`) — probado a mano
- [x] Simular el aprovisionamiento a mano (leer skills.txt, checar status, copiar solo las aptas)
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

## Fricciones encontradas (hallazgos de la prueba manual — Fases 4 y 5)

Estas son el verdadero resultado de probar el flujo. Cada una justifica una mejora futura:

1. **El aprovisionamiento manual no verifica el `status`.** Al copiar a mano, el criterio
   (no copiar skills en `experimental`) lo aplicó una persona con cuidado. Un dev con prisa
   copiaría la carpeta sin mirar el status. → Lo resuelve el script de la Fase 5.

2. **Nombres de archivo con doble extensión en Windows** (`skills.txt.txt`). Con las extensiones
   ocultas, es fácil crear mal el archivo y que el script luego no lo encuentre.
   → Mitigación: documentar "activar extensiones de archivo" y/o que el script avise si no halla `skills.txt`.

3. **La carpeta `.claude` debe ir en minúsculas.** Se creó como `.Claude` y en Windows funcionó
   por casualidad (no distingue mayúsculas), pero en Linux/contenedores (agente autónomo) fallaría.
   → Documentar la convención en el README; idealmente el script crea la carpeta con el nombre correcto.

## Preguntas abiertas / por decidir

- ¿Script de sync propio o camino nativo de Claude Code / Codex? (revisar en Fase 5)
- Handles reales de GitHub para `CODEOWNERS`.
- ¿Qué es un "test" de skill y cómo se automatiza? (Fase 6)
