# duplicidadCodigo.sh

Detecta duplicación interna de código entre dos commits de Git. Compara el crecimiento de archivos entre un commit "sano" y uno "corrupto", e identifica si el contenido fue pegado dos veces (duplicación exacta o parcial).

## Uso

```bash
./duplicidadCodigo.sh [commit_sano] [commit_corrupto]
```

## Parámetros

| Parámetro | Descripción | Default |
|---|---|---|
| `commit_sano` | Commit donde el código estaba correcto | `HEAD~1` |
| `commit_corrupto` | Commit donde se sospecha duplicación | `HEAD` |

## Umbrales configurables

Edita las variables al inicio del script para ajustar la sensibilidad:

| Variable | Default | Descripción |
|---|---|---|
| `MIN_LINEAS_SANO` | `10` | Mínimo de líneas en el commit sano para analizar el archivo |
| `MIN_LINEAS_NUEVO` | `20` | Mínimo de líneas para analizar archivos nuevos |
| `RATIO_MIN` | `1.8` | Crecimiento mínimo (corrupto/sano) para considerar sospechoso |
| `SIM_PARCIAL_MAX` | `0.05` | Máx. porcentaje de diferencias entre mitades para declarar duplicación parcial (5%) |

## Lógica de detección

1. Lista todos los archivos de texto en `commit_corrupto`.
2. Para cada archivo que creció al menos `RATIO_MIN` veces respecto al commit sano:
   - Divide el archivo corrupto en dos mitades.
   - **Duplicación exacta**: las mitades son idénticas.
   - **Duplicación parcial**: las mitades difieren en menos del `SIM_PARCIAL_MAX` (5% por defecto).
3. Para archivos nuevos (que no existían en el commit sano), aplica la misma detección de mitades.

## Ejemplos

```bash
# Comparar los últimos dos commits (comportamiento por defecto)
./duplicidadCodigo.sh

# Comparar commits específicos
./duplicidadCodigo.sh abc1234 def5678

# Comparar un commit con el estado actual sin commitear
./duplicidadCodigo.sh HEAD
```

## Salida

```
🔍 DETECTOR DE DUPLICACIÓN INTERNA DE CÓDIGO
=============================================
Commit sano:     abc1234
Commit corrupto: def5678
=============================================

📄 ANALIZANDO: src/services/userService.ts
   📊 Crecimiento: 120 → 245 líneas (ratio: 2.04)
🚨 DUPLICACIÓN EXACTA: src/services/userService.ts
   📏 Líneas: 120 → 245
   🔍 El archivo contiene el mismo bloque repetido

=============================================
📊 RESUMEN:
   Archivos analizados: 5
   Archivos con duplicación exacta: 1
   Archivos con duplicación parcial: 0
=============================================
```

## Dependencias

`git`, `bash`, `file`, `diff`, `awk`, `wc`, `head`, `tail`
