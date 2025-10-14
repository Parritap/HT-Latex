#!/bin/bash

preambulo="Ponencia para CEIFI 2025-02 --- "
where="/Users/esteban/git-repos/ht-latex/apendices/difusion/ceifi.tex"
times=28

# Print numbers from 1 to num
for ((i=1; i<=times; i++)); do
    echo "\shadowfig{tablas-images/difusion/CEIFI-2025-02/$i.png}{$preambulo diapositiva $i}" >> $where
done
