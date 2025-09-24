#!/bin/bash
i=1
# listamos en orden cronológico y leemos línea completa como nombre de archivo
ls -tr Screenshot*.png | while IFS= read -r file; do
  mv "$file" "pagina_$i.png"
  ((i++))
done
