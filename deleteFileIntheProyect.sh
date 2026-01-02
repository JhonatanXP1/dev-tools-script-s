
dirName="$1"
dirObjetivo="$2"

LISTA="$dirName"
BASE_DIR="$dirObjetivo"

if [ -z "$BASE_DIR" ]; then
    echo "❌ Debe proporcionar el directorio del proyecto."
    echo "Uso: $0 lista.txt /ruta/al/proyecto"
    exit 1
fi

if [ ! -d "$BASE_DIR" ]; then
    echo "❌ No existe el directorio del proyecto: $BASE_DIR"
    exit 1
fi

if [ ! -f "$LISTA" ]; then
    echo "❌ No existe el archivo: $LISTA"
    exit 1
fi

while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    [[ "$file" =~ ^# ]] && continue

    FULL_PATH="$BASE_DIR/$file"

    if [ -f "$FULL_PATH" ]; then
        echo "🗑️ Eliminando: $FULL_PATH"
        rm -- "$FULL_PATH"
    else
        echo "⚠️ No existe: $FULL_PATH"
    fi

done < "$LISTA"