#!/usr/bin/env bash
#
# sync-skills.sh
#
# Aprovisiona skills del catálogo a un proyecto, según su skills.txt y el status de cada skill.
#
# Este script VIVE EN EL CATÁLOGO (se distribuye con el repo clonado) y se EJECUTA DESDE/CONTRA
# un proyecto. Hace automáticamente lo que antes hacíamos a mano:
#
#   1. Lee <proyecto>/skills.txt  (una skill por línea; ignora líneas vacías y las que empiezan con #).
#   2. Busca cada skill en este catálogo (carpeta skills/<nombre>/SKILL.md).
#   3. Lee su campo 'status' en el frontmatter.
#   4. Copia a <proyecto>/.claude/skills/ SOLO las que están en 'stable' o 'production'.
#      Las 'experimental' se omiten con aviso (resuelve la fricción #1).
#   5. Crea la carpeta destino '.claude' SIEMPRE en minúsculas (resuelve la fricción #3).
#
# No borra skills que ya no estén en skills.txt (v1: simple y predecible).
#
# Uso:
#   # parado dentro del proyecto:
#   /ruta/al/catalogo/skills-repo/sync-skills.sh
#   # o indicando el proyecto:
#   ./sync-skills.sh /ruta/al/proyecto
#
# En Windows se ejecuta con Git Bash (no requiere permisos de PowerShell).

set -euo pipefail

# El catálogo es la carpeta donde vive este script.
CATALOG_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_ROOT="$CATALOG_ROOT/skills"

# Estados aptos para aprovisionar. Lo demás (experimental, desconocido) se omite.
ALLOWED_STATUS=("stable" "production")

# Proyecto destino: primer argumento, o el directorio actual.
PROJECT_PATH="${1:-$(pwd)}"
SKILLS_FILE="$PROJECT_PATH/skills.txt"

# --- Validaciones ------------------------------------------------------------

if [[ ! -f "$SKILLS_FILE" ]]; then
  echo "ERROR: no se encontró 'skills.txt' en: $PROJECT_PATH" >&2
  echo "Crea el archivo con una skill por línea (el nombre exacto de su carpeta en el catálogo)." >&2
  exit 1
fi

if [[ ! -d "$SKILLS_ROOT" ]]; then
  echo "ERROR: no se encontró la carpeta 'skills/' en el catálogo: $CATALOG_ROOT" >&2
  echo "¿Estás ejecutando el script desde dentro del repo clonado?" >&2
  exit 1
fi

# Carpeta destino SIEMPRE en minúsculas.
DEST_ROOT="$PROJECT_PATH/.claude/skills"
mkdir -p "$DEST_ROOT"

echo "Catalogo:  $CATALOG_ROOT"
echo "Proyecto:  $PROJECT_PATH"
echo "Destino:   $DEST_ROOT"
echo ""

# --- Helpers -----------------------------------------------------------------

is_allowed() {
  local status="$1"
  for s in "${ALLOWED_STATUS[@]}"; do
    [[ "$s" == "$status" ]] && return 0
  done
  return 1
}

# --- Procesamiento -----------------------------------------------------------

copied=0; skipped=0; missing=0
skipped_list=(); missing_list=()

while IFS= read -r line || [[ -n "$line" ]]; do
  # Limpia espacios al inicio/fin y el posible retorno de carro de Windows (CRLF).
  name="$(echo "$line" | tr -d '\r' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
  [[ -z "$name" || "$name" == \#* ]] && continue   # ignora vacías y comentarios

  skill_dir="$SKILLS_ROOT/$name"
  skill_md="$skill_dir/SKILL.md"

  if [[ ! -f "$skill_md" ]]; then
    missing=$((missing+1)); missing_list+=("$name")
    echo "  [x] $name  -- no existe en el catalogo (¿typo en skills.txt?)"
    continue
  fi

  # Lee el status del frontmatter (primera línea 'status: ...').
  status="$(grep -m1 '^status:' "$skill_md" | sed 's/^status:[[:space:]]*//; s/[[:space:]]*$//' || true)"
  [[ -z "$status" ]] && status="desconocido"

  if is_allowed "$status"; then
    # Reemplazo limpio: si ya existía, se borra y se vuelve a copiar (idempotente).
    rm -rf "${DEST_ROOT:?}/$name"
    cp -R "$skill_dir" "$DEST_ROOT/"
    copied=$((copied+1))
    echo "  [v] $name  -- copiada ($status)"
  else
    skipped=$((skipped+1)); skipped_list+=("$name ($status)")
    echo "  [!] $name  -- omitida: status '$status' no apto para aprovisionar"
  fi
done < "$SKILLS_FILE"

# --- Resumen -----------------------------------------------------------------

echo ""
echo "Resumen:"
echo "  Copiadas: $copied   Omitidas: $skipped   No encontradas: $missing"

if (( skipped > 0 )); then
  echo ""
  echo "  Omitidas por status (no aptas aun):"
  for s in "${skipped_list[@]}"; do echo "    - $s"; done
fi
if (( missing > 0 )); then
  echo ""
  echo "  No encontradas en el catalogo (revisa skills.txt):"
  for m in "${missing_list[@]}"; do echo "    - $m"; done
fi
