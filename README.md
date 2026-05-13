# Herramientas de Desarrollo — `~/bin`

Colección de scripts Bash para tareas comunes de Git, gestión de archivos y contenedores Docker.

## Herramientas

| Herramienta | Descripción |
|---|---|
| [`deleteFileIntheProyect.sh`](docs/deleteFileIntheProyect.md) | Elimina archivos de un proyecto a partir de una lista |
| [`duplicidadCodigo.sh`](docs/duplicidadCodigo.md) | Detecta duplicación interna de código entre dos commits |
| [`GetRutasCommits.sh`](docs/GetRutasCommits.md) | Lista archivos de commits/trees/blobs con metadata detallada |
| [`GetRutasCommitsLimpio.sh`](docs/GetRutasCommitsLimpio.md) | Extrae rutas de archivos de commits de forma limpia |
| [`popGitLisArchivos.sh`](docs/popGitLisArchivos.md) | Exporta archivos desde una rama de Git a un directorio local |
| [`sqlServer`](docs/sqlServer.md) | Inicia contenedores Docker de SQL Server por versión |

## Estructura

```
~/bin/
├── deleteFileIntheProyect.sh
├── duplicidadCodigo.sh
├── GetRutasCommits.sh
├── GetRutasCommitsLimpio.sh
├── popGitLisArchivos.sh
├── sqlServer
├── docs/                        # Documentación de cada herramienta
└── Inputs&Ouputs/               # Archivos de entrada/salida de ejemplo
    ├── idcommits                # Lista de hashes de ejemplo
    └── listado.txt              # Salida generada por los scripts de Git
```

## Requisitos

- `bash` >= 4.0
- `git`
- `docker` / `docker compose` — solo para `sqlServer`
- `fzf` — opcional, mejora la selección interactiva en `sqlServer`
- `yq` — requerido por `sqlServer`
