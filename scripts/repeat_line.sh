#!/bin/bash

preambulo="Ponencias GRID 2025-01 ---"
where="/Users/esteban/git-repos/ht-latex/apendices/difusion/grid-2025-I.tex"
times=20

# Print numbers from 1 to num
for ((i=1; i<=times; i++)); do
    echo "\shadowfig{tablas-images/difusion/GRID-2025-01/$i.png}{$preambulo Diapositiva $i}" >> $where
done
