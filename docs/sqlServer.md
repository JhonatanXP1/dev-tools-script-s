# sqlServer

Inicia contenedores Docker de SQL Server de forma interactiva, permitiendo seleccionar la versión a levantar sin necesidad de navegar manualmente entre directorios. Si `fzf` está disponible, ofrece selección fuzzy; de lo contrario, usa un menú numerado.

## Instalación global (opcional)

Para usar el comando `sqlServer` desde cualquier directorio:

```bash
sudo cp ~/bin/sqlServer /usr/local/bin/sqlServer
sudo chmod +x /usr/local/bin/sqlServer
```

## Uso

```bash
sqlServer <comando>
```

## Comandos

| Comando | Alias | Descripción |
|---|---|---|
| `init` | `start`, `run` | Selecciona e inicia un contenedor SQL Server |
| `ls` | `list`, `active` | Lista los contenedores Docker activos |

## Configuración

Edita la variable `ROUTESERVICE` al inicio del script para apuntar al directorio donde están las carpetas de cada versión de SQL Server:

```bash
ROUTESERVICE="$HOME/Documentos/net/sqlSever/"
```

**Estructura esperada del directorio:**

```
~/Documentos/net/sqlSever/
├── 2019/
│   └── docker-compose.yml
├── 2022/
│   └── docker-compose.yml
└── 2022-developer/
    └── docker-compose.yml
```

Cada subdirectorio debe contener un `docker-compose.yml` válido para iniciar el contenedor con `docker compose start`.

## Ejemplos

```bash
# Iniciar SQL Server (selección interactiva de versión)
sqlServer init

# Ver contenedores Docker activos
sqlServer ls
```

**Selección con `fzf`:**

```
Selecciona Version del Servicio de SQL-Server (flechas / escribe para filtrar):
> 2019
  2022
  2022-developer
  Salir
```

**Selección sin `fzf`:**

```
Selecciona Version del Servicio de SQL-Server:
1) 2019
2) 2022
3) 2022-developer
4) Salir
Selecciona una opción (1-4):
```

## Dependencias

| Herramienta | Requerido | Uso |
|---|---|---|
| `docker` / `docker compose` | Sí | Iniciar los contenedores |
| `yq` | Sí | Procesamiento de configuración (requerido en `main`) |
| `fzf` | No | Selección interactiva mejorada |
