# GetRutasCommits.sh

Lista archivos y rutas de objetos Git (commits, trees, blobs) con metadata detallada. La salida incluye información del autor, fecha, estado de los archivos y, en el caso de blobs, las rutas que apuntan a ese objeto.

Útil para auditar qué cambió en un conjunto de commits o para inspeccionar objetos Git arbitrarios.

## Uso

```bash
./GetRutasCommits.sh -d <destino> -f <archivo_hashes> [-r <rama>]
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
# Commits del sprint 3
9733b34b5cd56a76fa2a26466ab4cc786b5831e5
d88f3e6fb264eadf1e17b15b8e58bce0273a4172

# Blob específico
7ad71293d650fc4e2a9e827a76cafd253ebeb9fa
```

## Tipos de objeto soportados

| Tipo | Información extraída |
|---|---|
| `commit` | Hash, autor, fecha, subject, listado de archivos con estado (`A`/`M`/`D`) |
| `tree` | Rutas de todos los archivos dentro del árbol |
| `blob` | Rutas del historial completo que apuntan a ese blob |

## Ejemplo

```bash
./GetRutasCommits.sh -r main -d ~/bin -f ~/bin/Inputs\&Ouputs/idcommits
```

**Fragmento de `listado.txt` generado:**

```
============================
Hash: 9733b34b5cd56a76fa2a26466ab4cc786b5831e5
Tipo: commit

=== Commit info ===
Commit: 9733b34b5cd56a76fa2a26466ab4cc786b5831e5
Author: JhonatanEducapp <jhonatanxpx1@gmail.com>
Date:   Mon Dec 23 10:39:00 2024
Subject: UPDATE del commit anterior.

=== Archivos (name-status) ===
M       src/services/userService.ts
A       src/utils/helpers.ts
```

## Diferencia con `GetRutasCommitsLimpio.sh`

| | `GetRutasCommits.sh` | `GetRutasCommitsLimpio.sh` |
|---|---|---|
| Formato de salida | Detallado con metadata | Solo rutas de archivos |
| Uso ideal | Auditoría, revisión manual | Insumo para otros scripts |
| Duplicados | Se conservan | Se eliminan (`sort -u`) |
