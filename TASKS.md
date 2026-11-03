# Ruta de tareas — Organización de skills de IA

Archivo de trabajo del equipo. Vamos marcando `[x]` lo realizado.
No forma parte del repo de skills; es nuestro seguimiento interno.
Convención: nombres de archivos y carpetas en inglés, contenido en español.

Última actualización: 2026-11-02 (sync-skills.sh construido y probado; investigaciones nativas completadas)

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
- [x] Actualizar el clon con `git pull` (simula al dev manteniendo el catálogo al día)
- [x] Copiar a mano una skill a un proyecto de ejemplo (`skills_propuesta_test_proyecto/.claude/skills/`)
- [ ] Confirmar que el agente la detecta y la usa (pendiente: lo valida el dev abriendo Claude Code en el proyecto)
- [x] Anotar fricciones encontradas (ver sección "Fricciones encontradas")

## Fase 5 — Automatización (solo cuando copiar a mano empiece a doler)

- [x] Definir `skills.txt` por proyecto (análogo a `requirements.txt`) — probado a mano
- [x] Simular el aprovisionamiento a mano (leer skills.txt, checar status, copiar solo las aptas)
- [x] Convertir fricciones en reglas de consumo documentadas en el README
- [x] Construir `sync-skills` propio como alternativa
  - [x] v1 en **bash** (`sync-skills.sh`) — lee skills.txt, checa status, copia aptas, crea `.claude` minúsculas. PROBADO ✓
  - [x] Descartado PowerShell (`.ps1`): bloqueado por política corporativa (UserPolicy=Restricted). Ver fricción #4.
- [x] Investigar mecanismo nativo de **Claude Code** (plugins + marketplaces de Git) — ver "Hallazgos de investigación"
- [x] Investigar mecanismo nativo de **Codex** (skills en `.agents/skills` + plugins + AGENTS.md) — ver "Hallazgos de investigación"
- [ ] Decidir: ¿script propio, nativo (plugins/marketplace), o híbrido? (ahora con datos para decidir)
- [ ] (Futuro) Probar el camino nativo de plugins/marketplace de Claude Code como comparación

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

4. **PowerShell está bloqueado por política corporativa** (GPO: UserPolicy=Restricted, sobrescribe
   incluso `-ExecutionPolicy Bypass`). Python también está restringido en estas máquinas. → El tooling
   debe ser **bash vía Git Bash** (todos lo tienen por usar GitHub). Por eso `sync-skills` es `.sh`, no `.ps1`.

## Hallazgos de investigación (nativo vs. propio) — 2026-11-02

**Claude Code (nativo):**
- SÍ tiene distribución nativa: **plugins + marketplaces de Git**. Un marketplace es un repo con
  `.claude-plugin/marketplace.json`. Se instala por proyecto con `--scope project`, dejando la selección
  versionada en `.claude/settings.json` (`enabledPlugins`, `extraKnownMarketplaces`).
- La granularidad nativa es el **plugin**, no la skill suelta. Para selección exacta por proyecto habría que
  empaquetar "un plugin por skill".
- NO tiene estados `experimental/stable/production` por skill. Lo más parecido: dos marketplaces por "canal"
  (ref stable vs. latest). Nuestro `status` en el frontmatter NO existe de forma nativa.
- NO hay comando que "sincronice a `.claude/skills/` lo declarado en un archivo" → eso es justo lo que hace nuestro script.

**Codex (nativo):**
- SÍ tiene skills nativas: carpeta con `SKILL.md` (frontmatter `name`+`description`, carga on-demand), igual que Claude.
  Pero viven en **`.agents/skills`** (no `.claude/skills`). También usa `AGENTS.md` jerárquico.
- Distribución entre proyectos/equipo: vía skills commiteadas en el repo o **plugins** de OpenAI.
- Los "custom prompts" quedaron **deprecados**; la unidad reutilizable oficial ahora es la skill.

**Estándar multi-herramienta:**
- `AGENTS.md` es un estándar abierto (Linux Foundation) adoptado por 25+ herramientas (Codex, Copilot, Cursor…).
  Claude Code recientemente lee `AGENTS.md` si falta `CLAUDE.md`. → Esto valida nuestros stubs.
- PERO el estándar es para el **archivo de instrucciones**, NO para el formato de "skill". Claude (`.claude/skills`)
  y Codex (`.agents/skills`) usan ambos `SKILL.md` con `name`+`description` (convergen), pero en rutas distintas.
  No existe aún distribución nativa única cross-tool para skills → un script/adaptador sigue teniendo sentido.

**Implicación para la propuesta:** nuestra elección de `SKILL.md` con `name`+`description` fue acertada
(es el formato común de facto). El `status` y la selección por `skills.txt` + script son valor añadido que
lo nativo no da hoy. Decisión pendiente: script propio (control, multi-LLM) vs. plugins/marketplace (nativo
Claude, sin status). Posible híbrido a futuro.

## Preguntas abiertas / por decidir

- ¿Script de sync propio o camino nativo de Claude Code / Codex? (revisar en Fase 5)
- Handles reales de GitHub para `CODEOWNERS`.
- ¿Qué es un "test" de skill y cómo se automatiza? (Fase 6)
