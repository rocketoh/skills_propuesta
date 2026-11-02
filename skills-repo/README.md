# skills-repo (prueba)

Catálogo central de skills agénticas del equipo. Repositorio de **prueba** para acordar
estructura, nomenclatura y ciclo de vida antes de llevarlo a lo real.

## Principios base (los 4 que acordamos para empezar)

1. **Convención de nombres** — `<prefijo>-<acción>` (ej. `adf-validate-pipeline`). El prefijo agrupa por herramienta o dominio. Sin carpetas anidadas.
2. **Una carpeta por skill, una sola ubicación** — cada skill vive siempre en `skills/<nombre>/`, en cualquier estado.
3. **Estado dentro del `SKILL.md`** — el campo `status` declara la etapa (`experimental` → `stable` → `production`). La skill no cambia de carpeta al promoverse.
4. **Responsable por skill** — el campo `owner` y el archivo `CODEOWNERS` dicen quién aprueba los cambios.

### Convención de nombres (detalle)

Formato: **`<prefijo>-<acción>`**, todo en minúsculas y con guiones.
Nombres de archivos y carpetas **en inglés** (convención global); el contenido de los archivos va en español.
La acción es un verbo en inglés: `validate`, `format`, `generate`.

**Reglas técnicas (obligatorias — si no se cumplen, la skill no carga en Claude Code):**
- Solo minúsculas, números y guiones (`a-z`, `0-9`, `-`). Sin espacios, mayúsculas, acentos ni `_`.
- El `name` del frontmatter debe ser **idéntico** al nombre de la carpeta.
- Máximo 64 caracteres (es un tope; no hay un número fijo de letras obligatorio).

**Convención del equipo (lo decidimos nosotros):**
- El prefijo es **corto, estable y en minúsculas**. No tiene que medir lo mismo en todas las skills.
- Una vez publicado, **no se renombra** (rompería los `skills.txt` de los proyectos que la usan).

**Prefijos acordados:**

| Dominio | Prefijo | Nota |
|---|---|---|
| Azure Data Factory | `adf-` | abreviatura estándar y reconocida |
| Azure Synapse | `synapse-` | Microsoft no tiene acrónimo corto oficial; usamos la palabra completa por claridad |

> ¿Nuevo dominio? Se agrega un prefijo a esta tabla en un PR, para que no haya dos prefijos para lo mismo.

### Regla de seguridad (no negociable)

Nunca entran al repo: contraseñas, API keys, cadenas de conexión ni datos de clientes.
El repo describe *qué hace* una skill, no guarda secretos.

## Estructura

```
skills-repo/
├── README.md        # este archivo
├── INDEX.md         # catálogo: skill | herramienta | status | owner
├── CODEOWNERS       # quién aprueba cambios de cada skill
└── skills/
    └── <prefijo>-<acción>/
        └── SKILL.md # frontmatter (name, description, status, owner, tools) + instrucciones
```

## Anatomía de un SKILL.md

```yaml
---
name: sql-format-query             # == nombre de la carpeta; minúsculas y guiones
description: Usa esta skill cuando... # lo que el modelo lee para decidir si aplica
status: stable                      # experimental | stable | production
owner: luis.gomez                   # responsable
tools: [claude-code, codex]         # agentes con los que está validada
---

# Instrucciones de la skill (tool-neutral)
```

- **`name` y `description`** son los únicos campos que el modelo usa para elegir la skill. El resto es gobierno nuestro y no le estorba.
- El **cuerpo** se escribe de forma neutral: instrucciones que cualquier agente pueda seguir, sin atarlas a una herramienta concreta.

## Portabilidad entre herramientas (a futuro)

Hoy el equipo usa **Claude Code** y **Codex**, y más adelante podrían entrar **Gemini CLI** o **Copilot**.
No existe aún un formato de "skill" portable entre todos. La estrategia:

- **Una fuente de verdad neutral**: este repo, en formato `SKILL.md`.
- **Un adaptador por herramienta cuando haga falta** — por ejemplo, exportar a `AGENTS.md` para Codex. El campo `tools:` indica a qué agentes apunta cada skill.

No construimos adaptadores todavía. Se enuncia aquí para que la estructura ya lo contemple.

## Cómo se usará (más adelante)

Cuando copiar skills a mano empiece a doler, cada proyecto declarará las que necesita
(un `skills.txt`, como un `requirements.txt`) y un script las aprovisionará desde este catálogo
comprobando su `status`. **Eso aún no se automatiza**: primero validamos estructura y hábitos.
