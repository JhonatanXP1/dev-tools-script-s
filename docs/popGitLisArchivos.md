# popGitLisArchivos.sh

Exporta archivos desde una rama específica de Git a un directorio local, preservando la estructura de directorios. Soporta archivos individuales, directorios completos y listas de rutas desde un archivo de texto o desde `stdin`.

## Uso

```bash
# Desde un archivo de lista
./popGitLisArchivos.sh -r <rama> -d <destino> -f <lista.txt>

# Desde stdin (pipe)
cat lista.txt | ./popGitLisArchivos.sh -r <rama> -d <destino>
```

## Parámetros

| Flag | Descripción | Requerido | Default |
|---|---|---|---|
| `-r` | Rama (o ref) de Git de donde extraer los archivos | No | `main` |
| `-d` | Directorio de destino donde se copian los archivos | Sí | — |
| `-f` | Archivo de texto con una ruta por línea | No | stdin |

## Formato del archivo de lista

Una ruta por línea. Soporta comentarios con `#` y líneas vacías. Para indicar un directorio completo, terminar la ruta con `/`:

```
# Archivos individuales
src/controllers/authController.ts
src/models/user.ts

# Directorio completo (con slash al final)
src/utils/

# Sin slash: el script intenta detectar si es directorio
src/services
```

## Comportamiento de rutas

| Formato de ruta | Comportamiento |
|---|---|
| `archivo.ts` | Extrae ese archivo específico |
| `dir/` (con `/`) | Extrae todos los archivos dentro del directorio |
| `dir` (sin `/`) | Intenta como archivo; si falla, expande como directorio |

## Ejemplo

```bash
# Ejecutar desde dentro del repositorio objetivo
cd ~/proyectos/miapp

~/bin/popGitLisArchivos.sh \
  -r main \
  -d ~/Escritorio/Actualizar_Definitiva_Tareas \
  -f ~/Escritorio/archivos_modificados.txt
```

**Salida:**

```
✅ src/controllers/authController.ts
✅ src/models/user.ts
⚠️  No es archivo en ref: src/utils/obsoleto.ts
❌ No existe en 'main': config/viejo.json
🏁 Listo. Archivos extraídos en: ~/Escritorio/Actualizar_Definitiva_Tareas
```

## Flujo de trabajo típico

```
GetRutasCommitsLimpio.sh  →  listado.txt  →  popGitLisArchivos.sh
```

1. Usa `GetRutasCommitsLimpio.sh` para obtener las rutas de los archivos modificados en un conjunto de commits.
2. Usa `popGitLisArchivos.sh` con ese `listado.txt` para exportar los archivos a una carpeta local.

## Notas

- Debe ejecutarse desde dentro del repositorio Git que se quiere usar como fuente.
- La estructura de directorios de los archivos extraídos se replica dentro del directorio de destino.
- El directorio de destino se crea automáticamente si no existe.

## Errores

| Código | Causa |
|---|---|
| `1` | Falta el parámetro `-d` |
| `1` | La ref especificada con `-r` no existe en el repositorio |
| `1` | No se está dentro de un repositorio Git |
