#!/usr/bin/env bash
# Script para extraer rutas de archivos a partir de commits, trees o blobs
# Uso:
#   ~/bin/popGitLisArchivos.sh -r main -d ~/Escritorio/Actualizar_Definitiva_Tareas -f ~/Escritorio/hashes.txt

REF="main"
DEST_DIR=""
IDS_FILE=""

# Parseo de parámetros
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

  if ! git -C "$REPO_PATH" cat-file -e "$hash" 2>/dev/null; then
    continue
  fi

  type=$(git -C "$REPO_PATH" cat-file -t "$hash")

  case "$type" in
    commit)
      git -C "$REPO_PATH" diff-tree --no-commit-id --name-only -r "$hash" >> "$OUT_FILE"
      ;;
    tree)
      git -C "$REPO_PATH" ls-tree -r --name-only "$hash" >> "$OUT_FILE"
      ;;
    blob)
      git -C "$REPO_PATH" rev-list --all --objects | awk -v h="$hash" '$1==h { $1=""; sub(/^ /,""); print }' >> "$OUT_FILE"
      ;;
  esac

done < "$IDS_FILE"

# Eliminar duplicados y ordenar (opcional)
sort -u "$OUT_FILE" -o "$OUT_FILE"

echo "✅ Listado generado en: $OUT_FILE"

#Ejemplo:
# ~/bin/GetRutasCommitsLimpio.sh -r main -d ~/bin -f ~/bin/idComits.txt