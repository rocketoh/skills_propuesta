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

## Cómo aprovisionar skills en tu proyecto

Esta sección es para el **dev que consume** skills (no para quien las crea).

1. Clona este catálogo una sola vez, fuera de tus proyectos, y actualízalo con `git pull`.
2. En la raíz de tu proyecto crea un archivo **`skills.txt`** con una skill por línea
   (el nombre exacto de su carpeta en el catálogo). Es el análogo a `requirements.txt`.
3. Ejecuta **`sync-skills.sh`** (ver abajo). Copia a `.claude/skills/` de tu proyecto cada skill
   listada que esté en `status` `stable` o `production`; las `experimental` se omiten con aviso.

### Cómo ejecutar `sync-skills.sh`

El script está escrito en **bash**, porque en equipos con Windows corporativo PowerShell suele estar
bloqueado por política (y Python restringido). Bash viene con Git, que ya tienes por usar GitHub.

**Forma recomendada — Git Bash (como lo haría un dev):**

1. En el Explorador de Windows, abre la carpeta de **tu proyecto**.
2. Clic derecho en un espacio vacío → **"Git Bash Here"** (o "Open Git Bash here").
3. En esa terminal (el prompt termina en `$`, no en `PS>`), ejecuta:
   ```bash
   bash /ruta/al/catalogo/skills-repo/sync-skills.sh
   ```
   Sin argumento, usa el directorio actual como proyecto. También puedes indicarlo:
   ```bash
   bash /ruta/al/catalogo/skills-repo/sync-skills.sh /c/ruta/a/tu/proyecto
   ```

**Alternativa — PowerShell o CMD** (si no quieres cambiar de terminal):

Llama al `bash.exe` de Git por su ruta completa. La ruta depende de dónde instalaste Git;
encuéntrala con `(Get-Command git).Source` en PowerShell (sube dos carpetas y entra a `bin\bash.exe`).

```powershell
# PowerShell (ajusta la ruta de bash.exe a tu instalación de Git):
& "C:\Program Files\Git\bin\bash.exe" /ruta/al/catalogo/skills-repo/sync-skills.sh /c/ruta/a/tu/proyecto
```
```bat
:: CMD (ajusta la ruta de bash.exe a tu instalación de Git):
"C:\Program Files\Git\bin\bash.exe" /ruta/al/catalogo/skills-repo/sync-skills.sh /c/ruta/a/tu/proyecto
```

> Dentro del comando, las rutas van en formato Git Bash (`/c/Dev/...`), no `C:\Dev\...`.

Al terminar, el script imprime un resumen (copiadas / omitidas / no encontradas). Verifica con `ls .claude/skills/`.

### Reglas que evitan errores comunes

- **El archivo debe llamarse exactamente `skills.txt`** (no `skills.txt.txt`). En Windows, activa
  *Ver → Extensiones de nombre de archivo* para no crear una doble extensión por accidente.
- **La carpeta destino se escribe en minúsculas: `.claude`** (no `.Claude`). En Windows funciona
  de cualquier forma, pero en Linux o en un contenedor (agente autónomo) solo se detecta en minúsculas.
- **Solo aprovisiona lo que el proyecto usa de verdad.** El catálogo puede crecer a N skills;
  tu proyecto solo copia las que declara en su `skills.txt`.

> El filtro de `status` lo aplica `sync-skills.sh` automáticamente: no tienes que revisar a mano
> si una skill está lista. Si una sigue en `experimental`, el script avisa y no la copia.
