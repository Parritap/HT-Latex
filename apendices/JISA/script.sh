#!/bin/bash
i=1
# Usamos find + sort para manejar espacios en nombres
find . -maxdepth 1 -type f -name "Screenshot*.png" -print0 |
  xargs -0 ls -tr |
  while IFS= read -r f; do
    mv "$f" "pagina_${i}.png"
    ((i++))
  done
