# GetRutasCommitsLimpio.sh

Extrae rutas de archivos de objetos Git (commits, trees, blobs) y genera un listado limpio sin metadata. La salida es apta para ser usada directamente como insumo de otros scripts, como `popGitLisArchivos.sh` o `deleteFileIntheProyect.sh`.

## Uso

```bash
./GetRutasCommitsLimpio.sh -d <destino> -f <archivo_hashes> [-r <rama>]
```

## Parámetros

| Flag | Descripción | Requerido | Default |
|---|---|---|---|
| `-d` | Directorio de destino donde se genera `listado.txt` | Sí | — |
| `-f` | Archivo de texto con hashes Git (uno por línea) | Sí | — |
| `-r` | Rama de referencia del repositorio | No | `main` |

## Formato del archivo de hashes

Una línea por hash. Soporta comentarios con `#` y líneas vacías:

```
# Mis commits
9733b34b5cd56a76fa2a26466ab4cc786b5831e5
d88f3e6fb264eadf1e17b15b8e58bce0273a4172
```

## Tipos de objeto soportados

| Tipo | Información extraída |
|---|---|
| `commit` | Rutas de los archivos modificados en el commit |
| `tree` | Rutas de todos los archivos dentro del árbol |
| `blob` | Ruta del archivo en el historial que referencia ese blob |

## Ejemplo

```bash
./GetRutasCommitsLimpio.sh \
  -r main \
  -d "$HOME/bin/Inputs&Ouputs/" \
  -f "$HOME/bin/Inputs&Ouputs/idcommits"
```

**Contenido de `listado.txt` generado:**

```
src/controllers/authController.ts
src/models/user.ts
src/services/userService.ts
src/utils/helpers.ts
```

## Comportamiento adicional

- Crea el directorio de destino si no existe.
- Elimina duplicados y ordena el resultado alfabéticamente (`sort -u`).
- Omite hashes inválidos silenciosamente.

## Diferencia con `GetRutasCommits.sh`

| | `GetRutasCommitsLimpio.sh` | `GetRutasCommits.sh` |
|---|---|---|
| Formato de salida | Solo rutas de archivos | Detallado con metadata |
| Duplicados | Eliminados (`sort -u`) | Se conservan |
| Uso ideal | Insumo para otros scripts | Auditoría manual |
