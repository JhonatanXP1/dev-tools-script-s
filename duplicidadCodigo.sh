#!/usr/bin/env bash
# Detector de duplicación interna entre dos commits de Git
# - Corrige el bug del subshell en el while
# - Revisa también archivos NUEVOS en el commit "corrupto"
# - Usa umbrales configurables y similitud porcentual
# Dependencias: git, bash, file, diff, awk, wc, head, tail

set -uo pipefail

COMMIT_SANO=${1:-"HEAD~1"}     # Commit donde el código estaba bien
COMMIT_CORRUPTO=${2:-"HEAD"}   # Commit donde el contenido se duplicó

# Umbrales (ajústalos a tu repo)
MIN_LINEAS_SANO=10             # Mínimo de líneas en el sano para comparar con histórico
MIN_LINEAS_NUEVO=20            # Mínimo de líneas para revisar archivos nuevos
RATIO_MIN=1.8                  # Crecimiento mínimo (corrupto/sano) para sospechar duplicación
SIM_PARCIAL_MAX=0.05           # Máx. % de diferencias entre mitades para considerarlo “parcial” (5%)

echo "🔍 DETECTOR DE DUPLICACIÓN INTERNA DE CÓDIGO"
echo "============================================="
echo "Commit sano: $COMMIT_SANO"
echo "Commit corrupto: $COMMIT_CORRUPTO"
echo "============================================="

# Contadores
archivos_analizados=0
archivos_duplicados=0
archivos_sospechosos=0

detectar_duplicacion() {
  local archivo="$1"
  local contenido_sano="$2"
  local contenido_corrupto="$3"

  local lineas_sano lineas_corrupto
  lineas_sano=$(printf "%s" "$contenido_sano" | wc -l)
  lineas_corrupto=$(printf "%s" "$contenido_corrupto" | wc -l)

  local mitad
  mitad=$(( lineas_corrupto / 2 ))
  (( mitad == 0 )) && return 0

  local primera_mitad segunda_mitad
  primera_mitad=$(printf "%s" "$contenido_corrupto" | head -n "$mitad")
  segunda_mitad=$(printf "%s" "$contenido_corrupto" | tail -n "$mitad")

  if [[ "$primera_mitad" == "$segunda_mitad" ]]; then
    echo "🚨 DUPLICACIÓN EXACTA: $archivo"
    echo "   📏 Líneas: $lineas_sano → $lineas_corrupto"
    echo "   🔍 El archivo contiene el mismo bloque repetido"
    return 2
  fi

  local difflines porc
  difflines=$(diff -u <(printf "%s" "$primera_mitad") <(printf "%s" "$segunda_mitad") | wc -l)
  porc=$(awk -v d="$difflines" -v m="$mitad" 'BEGIN{ if(m==0) print 1; else printf("%.6f", d/m) }')

  if awk -v p="$porc" -v max="$SIM_PARCIAL_MAX" 'BEGIN{exit !(p<=max)}'; then
    echo "⚠️  DUPLICACIÓN PARCIAL: $archivo"
    echo "   📏 Líneas: $lineas_sano → $lineas_corrupto  (diff_rel: $porc)"
    echo "   🔍 Mitades muy similares (posible pegado duplicado con leves cambios)"
    return 1
  fi

  return 0
}

while IFS= read -r archivo; do

  if git show "$COMMIT_CORRUPTO:$archivo" 2>/dev/null | file -b - | grep -qi "text"; then

    if git cat-file -e "$COMMIT_SANO:$archivo" 2>/dev/null; then
      contenido_sano=$(git show "$COMMIT_SANO:$archivo" 2>/dev/null || true)
      contenido_corrupto=$(git show "$COMMIT_CORRUPTO:$archivo" 2>/dev/null || true)

      lineas_sano=$(printf "%s" "$contenido_sano" | wc -l)
      lineas_corrupto=$(printf "%s" "$contenido_corrupto" | wc -l)

      if (( lineas_sano > MIN_LINEAS_SANO )) && (( lineas_corrupto > lineas_sano )); then
        if awk -v c="$lineas_corrupto" -v s="$lineas_sano" -v r="$RATIO_MIN" 'BEGIN{exit !(c/s >= r)}'; then
          ((archivos_analizados++))
          ratio_str=$(awk -v c="$lineas_corrupto" -v s="$lineas_sano" 'BEGIN{printf("%.2f", c/s)}')
          echo ""
          echo "📄 ANALIZANDO: $archivo"
          echo "   📊 Crecimiento: $lineas_sano → $lineas_corrupto líneas (ratio: $ratio_str)"

          detectar_duplicacion "$archivo" "$contenido_sano" "$contenido_corrupto"
          case $? in
            2) ((archivos_duplicados++)) ;;
            1) ((archivos_sospechosos++)) ;;
          esac
        fi
      fi

    else
      contenido_corrupto=$(git show "$COMMIT_CORRUPTO:$archivo" 2>/dev/null || true)
      lineas_corrupto=$(printf "%s" "$contenido_corrupto" | wc -l)
      if (( lineas_corrupto >= MIN_LINEAS_NUEVO )); then
        ((archivos_analizados++))
        echo ""
        echo "📄 ANALIZANDO (nuevo): $archivo"
        echo "   📊 Líneas (nuevo): $lineas_corrupto"

        detectar_duplicacion "$archivo" "" "$contenido_corrupto"
        case $? in
          2) ((archivos_duplicados++)) ;;
          1) ((archivos_sospechosos++)) ;;
        esac
      fi
    fi
  fi
done < <(git ls-tree -r --name-only "$COMMIT_CORRUPTO")

echo ""
echo "============================================="
echo "📊 RESUMEN:"
echo "   Archivos analizados: $archivos_analizados"
echo "   Archivos con duplicación exacta: $archivos_duplicados"
echo "   Archivos con duplicación parcial: $archivos_sospechosos"
echo "============================================="