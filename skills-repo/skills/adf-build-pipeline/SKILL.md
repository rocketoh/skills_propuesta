---
name: adf-build-pipeline
description: Usa esta skill cuando el usuario quiera CREAR un pipeline de Azure Data Factory desde su proyecto (p. ej. "crea un pipeline que extraiga del servidor A al datalake az1", "arma un Copy de tal origen a tal destino") y dejarlo en una rama de Git para verlo en ADF Studio. Genera el JSON del pipeline (y sus datasets) con el formato y la carpeta que ADF espera, y lo sube SOLO a la rama de desarrollo que el usuario indique. No despliega a producción ni publica; solo escribe artefactos en una rama para que el dev los revise en ADF Studio.
status: stable
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
- No hace `push --force` ni toca la rama de colaboración (p. ej. `dev`) ni `adf_publish`.
- **No crea ramas.** Solo trabaja sobre una rama que YA existe y que el dev indica explícitamente.
- No escribe secretos: referencia linked services que ya existen; nunca credenciales ni cadenas de conexión.

## Información que debes reunir antes de construir

Si el usuario no la dio, pregúntala en una sola tanda (no inventes valores):

1. **Rama de destino** (obligatoria). Ej. `b9_orlando`. Debe existir ya; nunca asumas la rama actual ni crees una.
2. **Origen (source)**: el *linked service* y la tabla/archivo de origen. Ej. servidor `A`, tabla `dbo.clientes`.
3. **Destino (sink)**: el *linked service* del datalake y la ruta/contenedor. Ej. datalake `az1`, contenedor `raw/clientes`.
4. **Nombre del pipeline**: si no lo da, propón uno con convención `PL_<acción>_<origen>_<destino>`.

## Descubrir los linked services disponibles

El dev **no tiene que memorizar** los nombres de los linked services: ya existen como archivos
en el repo clonado. Cuando el usuario pregunte "¿qué linked services tengo?" o no sepa cuál usar:

1. Lista los archivos de la carpeta `linkedService/` del repo (`ls linkedService/`).
2. Si ayuda, agrúpalos por tipo leyendo el campo `type` de cada JSON
   (p. ej. `SqlServer` / `AzureSqlDatabase` para orígenes; `AzureBlobFS` / `AzureDataLakeStore` para destinos).
3. Muéstrale la lista y pídele que elija cuál es el **origen** y cuál el **destino**.

> La skill **solo referencia** linked services por su nombre; nunca los crea ni edita, ni toca sus credenciales.
> Si el usuario nombra uno que no está en `linkedService/`, avísale y detente — no inventes el nombre.

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

## Flujo de Git (solo sobre la rama que el dev indique)

**Regla central: esta skill NO crea ramas.** Trabaja únicamente sobre una rama que ya existe
y que el dev nombró explícitamente. Si esa rama no existe, se detiene y le pide al dev que la cree
(en ADF Studio o con git) antes de continuar.

Ejecuta estos pasos **en orden** y confirma antes de commitear:

1. `git fetch` (si aparece el error "some local refs could not be updated", corre `git remote prune origin` y reintenta).
2. Confirma que la rama indicada **existe**: `git branch -a --list "*<rama>*"`.
   - Si no existe (ni local ni en `origin`), **detente**: dile al dev que la cree primero. No la crees tú.
3. Cambia a esa rama: `git checkout <rama>` y sincronízala: `git pull --ff-only`.
4. Verifica que estás en la rama correcta: `git branch --show-current` debe imprimir `<rama>`.
   Si imprime otra cosa, **detente**.
5. Escribe los archivos JSON en `pipeline/` y `dataset/`.
6. Muestra al usuario qué vas a commitear (`git status -s`, lista de archivos).
7. `git add <archivos>` y `git commit -m "feat: <descripción>"`.
8. `git push origin <rama>`.
9. Dile al usuario: "Listo. Abre ADF Studio, selecciona la rama `<rama>` y verás el pipeline `<nombre>`."

**Prohibido:** crear ramas (`git checkout -b`, `git branch`); `push --force`; commitear o hacer push
a la rama de colaboración (`dev`), a `adf_publish`, o a cualquier rama distinta de la que el dev indicó.
Si el nombre de la rama es ambiguo o no coincide con lo que el dev dijo, **detente y pregunta**.

## Composición con otras skills

- Antes del commit, si está disponible `adf-validate-pipeline`, aplícala al JSON generado y corrige los hallazgos bloqueantes.

## Casos de prueba

**Caso 1 — Copy servidor → datalake, a una rama existente.**
Entrada: "Crea un pipeline que extraiga `dbo.clientes` del servidor A (linked service `LS_servidor_a`)
hacia el datalake az1, contenedor `raw/clientes` (linked service `LS_datalake_az1`), y súbelo al branch `b9_orlando`."
Comportamiento esperado:
- Confirma que `b9_orlando` **existe**; hace checkout a esa rama y `git pull --ff-only`.
- Genera `pipeline/PL_extrae_a_az1.json` + los datasets necesarios en `dataset/`.
- Commit y push SOLO a `b9_orlando`. No crea ramas, no toca `dev` ni `adf_publish`.
- No crea linked services ni incrusta credenciales.
- Reporta la ruta de los archivos y recuerda verificar en ADF Studio seleccionando `b9_orlando`.

**Caso 2 — Preguntar por los linked services disponibles.**
Entrada: "¿Qué linked services tengo para usar como origen?"
Comportamiento esperado:
- Lista los archivos de `linkedService/` y los agrupa por `type` (orígenes vs. destinos).
- Pide al dev que elija; no inventa nombres ni crea linked services.

**Caso 3 — Rama inexistente (freno de seguridad).**
Entrada: "…súbelo al branch `rama_que_no_existe`."
Comportamiento esperado:
- Detecta que la rama no existe (ni local ni en `origin`) y **se detiene**, pidiendo al dev que la cree primero.
- No crea la rama ni commitea nada.
