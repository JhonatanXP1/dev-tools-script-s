# getFileCommit

Orquesta `GetRutasCommitsLimpio.sh` y `popGitLisArchivos.sh` en un solo flujo interactivo: selecciona commits con `fzf`, genera automáticamente `listado.txt` y exporta los archivos resultantes a una carpeta destino.

## Uso

```bash
# Ejecutar desde dentro del repositorio Git objetivo
cd ~/proyectos/miapp
~/bin/getFileCommit

# Forzar reconfigurar el directorio base de trabajo
~/bin/getFileCommit config
```

Para invocarlo globalmente como `getFileCommit`, instalar un **symlink** (no una copia) en el PATH:

```bash
sudo ln -s "$HOME/bin/getFileCommit" /usr/local/bin/getFileCommit
```

El script se autolocaliza: resuelve su propia ruta real (`readlink -f`) y busca ahí mismo a `GetRutasCommitsLimpio.sh`/`popGitLisArchivos.sh`, sin importar en qué carpeta esté clonado el repositorio ni el usuario que lo use. Por eso es importante usar `ln -s` y no `cp` — una copia rompe esa autolocalización porque deja de apuntar al repositorio real.

### Si ya lo instalaste con `cp` por error

El propio script lo detecta: al ejecutarlo, el bucle que verifica `GetRutasCommitsLimpio.sh`/`popGitLisArchivos.sh` falla con un error explícito ("¿Instalaste getFileCommit con 'cp' en vez de 'ln -s'?"), porque `BIN_DIR` termina apuntando a la carpeta donde quedó la copia (ej. `/usr/local/bin`) en vez de al repositorio real. Para corregirlo:

```bash
# 1. Borrar la copia
sudo rm /usr/local/bin/getFileCommit

# 2. Reinstalar como symlink apuntando al repo clonado
sudo ln -s "$HOME/bin/getFileCommit" /usr/local/bin/getFileCommit
```

Alternativa sin instalar nada en el PATH: invocarlo directo desde el repo clonado (`./getFileCommit`), donde también funciona porque no hay symlink que resolver.

## Requisitos

- `fzf` instalado.
- Debe ejecutarse desde dentro de un repositorio Git (usa la rama/ref actualmente activa).

## Flujo

1. **Primera vez**: pregunta la ruta absoluta del directorio base de trabajo (`WORK_DIR`) y la guarda en `~/.config/getFileCommit/config`. En corridas siguientes no vuelve a preguntar.
2. Muestra en `fzf` las ramas locales y remotas del repo (`git branch` + `git branch -r`) para elegir de cuál extraer. La rama local `main` aparece siempre primero en la lista si existe.
3. Muestra en `fzf` los archivos que ya existen en el nivel superior de `WORK_DIR` (ej. una lista `idcommits` pegada manualmente, marcada con el ícono 📄), más una entrada extra **"+ Nueva selección de commits (git log)"**:
   - Si eliges un archivo existente → se usa tal cual, sin tocarlo.
   - Si eliges la entrada nueva → abre el `git log` de la rama elegida en `fzf` (TAB para multi-seleccionar commits, con preview de `git show --stat`) y guarda los hashes en `<WORK_DIR>/<repo>_<timestamp>/idcommits.txt`.
4. Invoca automáticamente `GetRutasCommitsLimpio.sh -r <rama>` para generar `listado.txt` en `<WORK_DIR>/<repo>_<timestamp>/`.
5. Pregunta solo el **nombre** de la subcarpeta destino (no una ruta completa).
6. Invoca automáticamente `popGitLisArchivos.sh -r <rama>` para exportar los archivos a `<WORK_DIR>/<nombre>`. Como usa la rama (no el commit puntual), siempre trae la **última versión** de cada archivo en esa rama.

Tanto los archivos intermedios como el destino final quedan siempre dentro del mismo `WORK_DIR` configurado. Ejemplo, con `WORK_DIR=/home/jhoanxp/bin/Inputs&Ouputs` y reusando un `idcommits` pegado a mano:

```
Inputs&Ouputs/
├── idcommits                     <- lista de hashes pegada manualmente (paso 3, reutilizada)
├── miapp_20260714_101740/        <- generado automáticamente (paso 4)
│   └── listado.txt
└── actualizacion/                 <- lo que escribiste al pedirte el nombre (paso 5-6)
    ├── src/controllers/authController.ts
    └── ...
```

## Notas

- `listado.txt` (y `idcommits.txt` si se crea uno nuevo) quedan en una subcarpeta con timestamp por corrida, dentro de `WORK_DIR` — no se dejan en el árbol del repo.
- Los archivos de commits que pegues manualmente en `WORK_DIR` (nivel superior, sin bajar a subcarpetas) siempre aparecen como opción en el segundo `fzf`.
- El nombre de la carpeta destino no puede ser una ruta absoluta ni contener `..` — siempre se crea como subcarpeta directa de `WORK_DIR`.
- `config` como primer argumento borra la configuración guardada y vuelve a preguntar el directorio base de trabajo.
