#!/usr/bin/env bash
# Script para listar archivos/rutas de commits, trees o blobs

REF="main"
DEST_DIR=""
IDS_FILE=""

while getopts "r:d:f:" opt; do
  case $opt in
    r) REF="$OPTARG" ;;
    d) DEST_DIR="$OPTARG" ;;
    f) IDS_FILE="$OPTARG" ;;
    *) echo "Uso: $0 -r <rama> -d <destino> -f <archivo_hashes>" >&2; exit 1 ;;
  esac
done

# Validaciones
if [ -z "$DEST_DIR" ] || [ -z "$IDS_FILE" ]; then
  echo "ERROR: Debes indicar -d <destino> y -f <archivo_hashes>" >&2
  exit 1
fi
if [ ! -f "$IDS_FILE" ]; then
  echo "ERROR: El archivo con hashes no existe: $IDS_FILE" >&2
  exit 2
fi

OUT_FILE="$DEST_DIR/listado.txt"

# Crear destino si no existe
mkdir -p "$DEST_DIR"
: > "$OUT_FILE"

# Detectar repo
REPO_PATH=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_PATH" ]; then
  echo "ERROR: No estás dentro de un repositorio git" >&2
  exit 3
fi

# Recorrer hashes
while IFS= read -r hash || [ -n "$hash" ]; do
  [[ -z "$hash" ]] && continue
  [[ "$hash" =~ ^# ]] && continue

  echo "============================" >> "$OUT_FILE"
  echo "Hash: $hash" >> "$OUT_FILE"

  if ! git -C "$REPO_PATH" cat-file -e "$hash" 2>/dev/null; then
    echo "Tipo: NO ENCONTRADO" >> "$OUT_FILE"
    echo "" >> "$OUT_FILE"
    continue
  fi

  type=$(git -C "$REPO_PATH" cat-file -t "$hash")
  echo "Tipo: $type" >> "$OUT_FILE"

  case "$type" in
    commit)
      echo "" >> "$OUT_FILE"
      echo "=== Commit info ===" >> "$OUT_FILE"
      git -C "$REPO_PATH" show --no-patch \
        --pretty=format:"Commit: %H%nAuthor: %an <%ae>%nDate: %ad%nSubject: %s" "$hash" >> "$OUT_FILE"
      echo "" >> "$OUT_FILE"
      echo "=== Archivos (name-status) ===" >> "$OUT_FILE"
      git -C "$REPO_PATH" diff-tree --no-commit-id --name-status -r "$hash" >> "$OUT_FILE"
      ;;
    tree)
      echo "" >> "$OUT_FILE"
      echo "=== Contenido del tree (ruta/archivo) ===" >> "$OUT_FILE"
      git -C "$REPO_PATH" ls-tree -r --name-only "$hash" >> "$OUT_FILE"
      ;;
    blob)
      echo "" >> "$OUT_FILE"
      echo "=== Blob: buscar rutas que apuntan a este blob ===" >> "$OUT_FILE"
      paths=$(git -C "$REPO_PATH" rev-list --all --objects | awk -v h="$hash" '$1==h { $1=""; sub(/^ /,""); print }')
      if [ -n "$paths" ]; then
        echo "$paths" >> "$OUT_FILE"
      else
        echo "(no se encontró ruta para este blob en refs actuales)" >> "$OUT_FILE"
      fi
      ;;
  esac

  echo "" >> "$OUT_FILE"
done < "$IDS_FILE"

echo "✅ Listado generado en: $OUT_FILE"

#Ejemplo:
# ~/bin/GetRutasCommits.sh -r main -d ~/bin -f ~/bin/idComits.txt