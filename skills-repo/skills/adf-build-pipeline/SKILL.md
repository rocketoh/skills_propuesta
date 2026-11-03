---
name: adf-build-pipeline
description: Usa esta skill cuando el usuario quiera CREAR un pipeline de Azure Data Factory desde su proyecto (p. ej. "crea un pipeline que extraiga del servidor A al datalake az1", "arma un Copy de tal origen a tal destino") y dejarlo en una rama de Git para verlo en ADF Studio. Genera el JSON del pipeline (y sus datasets) con el formato y la carpeta que ADF espera, y lo sube SOLO a la rama de desarrollo que el usuario indique. No despliega a producción ni publica; solo escribe artefactos en una rama para que el dev los revise en ADF Studio.
status: experimental
owner: orlando.herrera
tools: [claude-code]
---

# Construir un pipeline de Azure Data Factory

Esta skill ayuda a un **dev** a crear un pipeline de ADF más rápido: genera el JSON
(y los datasets que necesite) con el formato correcto, lo coloca en la carpeta que ADF usa
en el repo y lo sube **a la rama de dev que el usuario indique**. Luego el dev lo verifica
abriendo **ADF Studio** y seleccionando esa rama.

**Qué NO hace esta skill (límites duros):**
- No despliega ni "publica" (no toca la rama de colaboración ni genera ARM templates).
- No hace `push --force` ni toca `main` / `develop` / la rama de colaboración.
- No escribe secretos: referencia linked services que ya existen; nunca credenciales ni cadenas de conexión.

## Información que debes reunir antes de construir

Si el usuario no la dio, pregúntala en una sola tanda (no inventes valores):

1. **Rama de destino** (obligatoria). Ej. `dev_proyecto001`. Nunca asumas la rama actual.
2. **Origen (source)**: el *linked service* y la tabla/archivo de origen. Ej. servidor `A`, tabla `dbo.clientes`.
3. **Destino (sink)**: el *linked service* del datalake y la ruta/contenedor. Ej. datalake `az1`, contenedor `raw/clientes`.
4. **Nombre del pipeline**: si no lo da, propón uno con convención `PL_<acción>_<origen>_<destino>`.

> La skill **referencia** linked services por su nombre (p. ej. `LS_servidor_a`, `LS_datalake_az1`);
> asume que ya están creados en ADF. Si el usuario no sabe el nombre exacto, pídeselo o deja un
> placeholder claro y avísale que debe ajustarlo — nunca inventes credenciales.

## Estructura de archivos de ADF en el repo

ADF guarda cada artefacto como un JSON en una carpeta por tipo (en la raíz del repo conectado):

```
pipeline/     PL_<nombre>.json
dataset/      DS_<nombre>.json
linkedService/ LS_<nombre>.json   <- normalmente ya existen; NO los crea esta skill
```

Crea el pipeline en `pipeline/` y los datasets que falten en `dataset/`.

## Esqueleto mínimo de un pipeline Copy (origen → datalake)

`pipeline/PL_extrae_a_az1.json`:

```json
{
  "name": "PL_extrae_a_az1",
  "properties": {
    "activities": [
      {
        "name": "CopyOrigenADatalake",
        "type": "Copy",
        "dependsOn": [],
        "policy": { "timeout": "0.12:00:00", "retry": 1, "retryIntervalInSeconds": 30 },
        "typeProperties": {
          "source": { "type": "SqlServerSource" },
          "sink": { "type": "ParquetSink", "storeSettings": { "type": "AzureBlobFSWriteSettings" } }
        },
        "inputs":  [ { "referenceName": "DS_origen_clientes", "type": "DatasetReference" } ],
        "outputs": [ { "referenceName": "DS_datalake_clientes", "type": "DatasetReference" } ]
      }
    ],
    "annotations": []
  }
}
```

Reglas del JSON:
- `name` del archivo y `name` dentro del JSON deben coincidir con el nombre del pipeline.
- Cada actividad: `name` único, `type`, `typeProperties`. Las actividades Copy llevan `policy` con `retry` y `timeout`.
- `inputs`/`outputs` referencian datasets por `referenceName`; cada dataset referenciado debe existir en `dataset/`.
- No incrustar secretos ni rutas con credenciales. El dataset apunta al linked service; el linked service guarda la conexión (en ADF, no en el JSON del pipeline).

## Flujo de Git (cómo subir a la rama indicada)

Ejecuta estos pasos **en orden** y confirma antes de commitear:

1. `git fetch`
2. Verifica la rama actual: `git branch --show-current`.
3. Cambia a la rama que el usuario indicó: `git checkout <rama>`.
   - Si la rama no existe, **pregunta** si crearla desde la de colaboración (ej. `git checkout -b <rama> origin/develop`). No la crees por tu cuenta.
4. Escribe los archivos JSON en `pipeline/` y `dataset/`.
5. Muestra al usuario qué vas a commitear (`git status`, lista de archivos).
6. `git add <archivos>` y `git commit -m "feat: <descripción>"`.
7. `git push origin <rama>`.
8. Dile al usuario: "Listo. Abre ADF Studio, selecciona la rama `<rama>` y verás el pipeline `<nombre>`."

**Prohibido:** `push --force`; commitear a `main`/`develop`/rama de colaboración; subir a una rama distinta de la indicada.
Si el nombre de la rama es ambiguo o no coincide con lo que pediste, **detente y pregunta**.

## Composición con otras skills

- Antes del commit, si está disponible `adf-validate-pipeline`, aplícala al JSON generado y corrige los hallazgos bloqueantes.

## Casos de prueba

**Caso 1 — Copy servidor → datalake, a rama de dev.**
Entrada: "Crea un pipeline que extraiga `dbo.clientes` del servidor A (linked service `LS_servidor_a`)
hacia el datalake az1, contenedor `raw/clientes` (linked service `LS_datalake_az1`), y súbelo al branch `dev_proyecto001`."
Comportamiento esperado:
- Genera `pipeline/PL_extrae_a_az1.json` + los datasets necesarios en `dataset/`.
- Hace checkout a `dev_proyecto001` (confirmando que existe), commit y push SOLO a esa rama.
- No crea linked services ni incrusta credenciales.
- Reporta la ruta de los archivos y recuerda verificar en ADF Studio seleccionando `dev_proyecto001`.
