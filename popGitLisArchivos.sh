#!/usr/bin/env bash
set -euo pipefail

REF="main"
DEST=""
LIST_FILE=""

while getopts ":r:d:f:" opt; do
  case "$opt" in
    r) REF="$OPTARG" ;;
    d) DEST="$OPTARG" ;;
    f) LIST_FILE="$OPTARG" ;;
    *) echo "Uso: $0 -r <ref> -d <dest> [-f <lista>]"; exit 1 ;;
  esac
done

if [[ -z "${DEST}" ]]; then
  echo "Error: falta -d <dest>"; exit 1
fi

# 1) Verificaciones
git -C . rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "Error: ejecuta este script dentro de un repositorio Git."; exit 1;
}

git rev-parse --verify "${REF}" >/dev/null 2>&1 || {
  echo "Error: la ref '${REF}' no existe."; exit 1;
}

mkdir -p "$DEST"

# 2) Función para procesar cada ruta
process_path() {
  local p="$1"

  # Ignora líneas vacías o comentarios
  [[ -z "$p" ]] && return 0
  [[ "$p" =~ ^# ]] && return 0

  # Si termina en '/', trátalo como prefijo de directorio (listamos archivos)
  if [[ "$p" == */ ]]; then
    # Lista blobs dentro de ese directorio en la ref
    while IFS= read -r f; do
      [[ -z "$f" ]] && continue
      mkdir -p "${DEST}/$(dirname "$f")"
      if git cat-file -e "${REF}:${f}^{blob}" 2>/dev/null; then
        git show "${REF}:${f}" > "${DEST}/${f}"
        echo "✅ ${f}"
      else
        echo "⚠️  No es archivo en ref: ${f}"
      fi
    done < <(git ls-tree -r --name-only "${REF}" -- "$p")
    return 0
  fi

  # Caso archivo concreto
  if git cat-file -e "${REF}:${p}^{blob}" 2>/dev/null; then
    mkdir -p "${DEST}/$(dirname "$p")"
    git show "${REF}:${p}" > "${DEST}/${p}"
    echo "✅ ${p}"
  else
    # Si no es blob, puede que sea directorio sin slash; intentamos expandirlo
    if git ls-tree -d "${REF}" -- "$p" >/dev/null 2>&1; then
      while IFS= read -r f; do
        [[ -z "$f" ]] && continue
        mkdir -p "${DEST}/$(dirname "$f")"
        git show "${REF}:${f}" > "${DEST}/${f}"
        echo "✅ ${f}"
      done < <(git ls-tree -r --name-only "${REF}" -- "$p")
    else
      echo "❌ No existe en '${REF}': ${p}"
    fi
  fi
}
chmod +x ~/bin/popGitLisArchivos.sh
# 3) Leer lista (archivo o stdin)
if [[ -n "$LIST_FILE" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    process_path "$line"
  done < "$LIST_FILE"
else
  while IFS= read -r line || [[ -n "$line" ]]; do
    process_path "$line"
  done
fi

echo "🏁 Listo. Archivos extraídos en: $DEST"


#Se debe ejecutar cuando la terminal este dentro del repositorio que deseas aplicar este script
# -r -> es la rama de que deseas extraer.
# -d ->la carpeta en donde depositara los archivos. (Nota, la creara si no existe).
# -f -> Es el archivo .txt con la lista de los archivos.

# ejemplo -> ~/bin/popGitLisArchivos.sh -r main -d ~/Escritorio/Actualizar_Definitiva_Tareas -f ~/Escritorio/archivos_modificados2.txt

