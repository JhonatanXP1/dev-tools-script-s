# deleteFileIntheProyect.sh

Elimina archivos de un proyecto a partir de una lista de rutas relativas.

## Uso

```bash
./deleteFileIntheProyect.sh <lista.txt> <directorio_proyecto>
```

## Parámetros

| Parámetro | Descripción |
|---|---|
| `<lista.txt>` | Archivo de texto con una ruta de archivo por línea |
| `<directorio_proyecto>` | Ruta absoluta o relativa al directorio raíz del proyecto |

## Comportamiento

- Lee el archivo de lista línea por línea.
- Ignora líneas vacías y líneas que comienzan con `#` (comentarios).
- Por cada ruta, construye la ruta completa: `<directorio_proyecto>/<ruta>`.
- Si el archivo existe, lo elimina e informa con `🗑️`.
- Si el archivo no existe, emite una advertencia con `⚠️`.

## Ejemplos

```bash
# Eliminar los archivos listados en "a_borrar.txt" del proyecto en ~/proyectos/miapp
./deleteFileIntheProyect.sh a_borrar.txt ~/proyectos/miapp
```

**Contenido de ejemplo para `lista.txt`:**

```
# Archivos temporales
src/temp/cache.js
build/output.min.css
logs/debug.log
```

## Errores

| Código | Causa |
|---|---|
| `1` | No se proporcionó el directorio del proyecto |
| `1` | El directorio del proyecto no existe |
| `1` | El archivo de lista no existe |
