#!/bin/bash

echo "Cleaning LaTeX auxiliary files recursively..."

# Count files before deletion
COUNT=$(find . -type f \( -name "*.aux" -o -name "*.log" -o -name "*.out" -o -name "*.toc" -o -name "*.lof" -o -name "*.lot" -o -name "*.fls" -o -name "*.fdb_latexmk" -o -name "*.synctex.gz" -o -name "*.bbl" -o -name "*.blg" -o -name "*.bcf" -o -name "*.run.xml" -o -name "*.nav" -o -name "*.snm" -o -name "*.vrb" \) | wc -l)

echo "Found $COUNT auxiliary files to delete"

# Delete the files
find . -type f \( \
    -name "*.aux" -o \
    -name "*.log" -o \
    -name "*.out" -o \
    -name "*.toc" -o \
    -name "*.lof" -o \
    -name "*.lot" -o \
    -name "*.fls" -o \
    -name "*.fdb_latexmk" -o \
    -name "*.synctex.gz" -o \
    -name "*.bbl" -o \
    -name "*.blg" -o \
    -name "*.bcf" -o \
    -name "*.run.xml" -o \
    -name "*.nav" -o \
    -name "*.snm" -o \
    -name "*.vrb" \
\) -delete

echo "✓ Cleaned $COUNT LaTeX auxiliary files"
