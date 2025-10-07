#!/bin/bash

# LaTeX Bibliography Compilation Script
# This script handles common bibliography compilation issues in LaTeX projects
# Author: Assistant
# Version: 1.0

# Note: Not using set -e because grep commands may return non-zero for no matches

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
MAIN_FILE="main"
CLEAN_ALL=false
VERBOSE=false
FORCE_REBUILD=false

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] [TEX_FILE]

This script compiles LaTeX documents with bibliography support and handles common issues.

OPTIONS:
    -h, --help          Show this help message
    -c, --clean         Clean all auxiliary files before compilation
    -v, --verbose       Show detailed compilation output
    -f, --force         Force complete rebuild (implies --clean)

ARGUMENTS:
    TEX_FILE            Name of the main .tex file (without extension, default: main)

EXAMPLES:
    $0                  # Compile main.tex with bibliography
    $0 -c               # Clean and compile main.tex
    $0 -v document      # Compile document.tex with verbose output
    $0 -f -v            # Force rebuild with verbose output

The script performs the following steps:
1. Checks for required files
2. Optionally cleans auxiliary files
3. Runs pdflatex to generate .aux file
4. Runs bibtex to process citations
5. Runs pdflatex twice more to resolve all references
6. Reports any remaining issues

EOF
}

# Function to clean auxiliary files
clean_files() {
    print_status "Cleaning auxiliary files..."

    local files_to_clean=(
        "${MAIN_FILE}.aux"
        "${MAIN_FILE}.bbl"
        "${MAIN_FILE}.blg"
        "${MAIN_FILE}.log"
        "${MAIN_FILE}.out"
        "${MAIN_FILE}.toc"
        "${MAIN_FILE}.lof"
        "${MAIN_FILE}.lot"
        "${MAIN_FILE}.fls"
        "${MAIN_FILE}.fdb_latexmk"
        "${MAIN_FILE}.synctex.gz"
    )

    local cleaned=0
    for file in "${files_to_clean[@]}"; do
        if [[ -f "$file" ]]; then
            rm "$file"
            ((cleaned++))
            [[ "$VERBOSE" == true ]] && echo "  Removed: $file"
        fi
    done

    if [[ "$cleaned" -gt 0 ]]; then
        print_success "Cleaned $cleaned auxiliary files"
    else
        print_status "No auxiliary files to clean"
    fi
}

# Function to check if required files exist
check_files() {
    print_status "Checking required files..."

    # Check main .tex file
    if [[ ! -f "${MAIN_FILE}.tex" ]]; then
        print_error "Main file ${MAIN_FILE}.tex not found!"
        exit 1
    fi

    # Check for bibliography file
    local bib_files=(*.bib)
    if [[ ! -f "${bib_files[0]}" ]]; then
        print_warning "No .bib file found. Bibliography compilation may fail."
    else
        print_status "Found bibliography file(s): ${bib_files[*]}"
    fi

    print_success "File check completed"
}

# Function to run pdflatex
run_pdflatex() {
    local pass_number=$1
    local description=$2

    print_status "Running pdflatex (Pass $pass_number): $description"

    local exit_code=0
    if [[ "$VERBOSE" == true ]]; then
        pdflatex "${MAIN_FILE}.tex"
        exit_code=$?
    else
        pdflatex "${MAIN_FILE}.tex" > /dev/null 2>&1
        exit_code=$?
    fi

    if [[ $exit_code -ne 0 ]]; then
        print_error "pdflatex failed on pass $pass_number"
        print_error "Check ${MAIN_FILE}.log for details"
        exit $exit_code
    fi
}

# Function to run bibtex
run_bibtex() {
    print_status "Running bibtex to process citations..."

    local exit_code=0
    if [[ "$VERBOSE" == true ]]; then
        bibtex "${MAIN_FILE}"
        exit_code=$?
    else
        bibtex "${MAIN_FILE}" > /dev/null 2>&1
        exit_code=$?
    fi

    if [[ $exit_code -ne 0 ]]; then
        print_error "bibtex failed"
        print_error "Check ${MAIN_FILE}.blg for details"
        exit $exit_code
    fi

    # Check bibtex output for issues
    if [[ -f "${MAIN_FILE}.blg" ]]; then
        local warnings=0
        local errors=0
        if grep -q "Warning" "${MAIN_FILE}.blg" 2>/dev/null; then
            warnings=$(grep -c "Warning" "${MAIN_FILE}.blg" 2>/dev/null)
        fi
        if grep -q "Error" "${MAIN_FILE}.blg" 2>/dev/null; then
            errors=$(grep -c "Error" "${MAIN_FILE}.blg" 2>/dev/null)
        fi

        if [[ "$errors" -gt 0 ]]; then
            print_error "BibTeX reported $errors error(s)"
            [[ "$VERBOSE" == true ]] && cat "${MAIN_FILE}.blg"
        elif [[ "$warnings" -gt 0 ]]; then
            print_warning "BibTeX reported $warnings warning(s)"
            [[ "$VERBOSE" == true ]] && grep "Warning" "${MAIN_FILE}.blg"
        else
            print_success "BibTeX completed successfully"
        fi
    fi
}

# Function to check for citation issues
check_citations() {
    print_status "Checking for citation issues..."

    if [[ -f "${MAIN_FILE}.log" ]]; then
        local undefined_citations=0
        local undefined_references=0
        if grep -q "Citation.*undefined" "${MAIN_FILE}.log" 2>/dev/null; then
            undefined_citations=$(grep -c "Citation.*undefined" "${MAIN_FILE}.log" 2>/dev/null)
        fi
        if grep -q "Reference.*undefined" "${MAIN_FILE}.log" 2>/dev/null; then
            undefined_references=$(grep -c "Reference.*undefined" "${MAIN_FILE}.log" 2>/dev/null)
        fi

        if [[ "$undefined_citations" -gt 0 ]]; then
            print_error "Found $undefined_citations undefined citation(s)"
            if [[ "$VERBOSE" == true ]]; then
                echo "Undefined citations:"
                grep "Citation.*undefined" "${MAIN_FILE}.log" | head -5
                [[ "$undefined_citations" -gt 5 ]] && echo "... and $((undefined_citations - 5)) more"
            fi
            return 1
        fi

        if [[ "$undefined_references" -gt 0 ]]; then
            print_warning "Found $undefined_references undefined reference(s)"
            if [[ "$VERBOSE" == true ]]; then
                echo "Undefined references:"
                grep "Reference.*undefined" "${MAIN_FILE}.log" | head -3
            fi
        fi
    fi

    return 0
}

# Function to show compilation summary
show_summary() {
    print_status "Compilation Summary:"
    echo "===================="

    # Check if PDF was generated
    if [[ -f "${MAIN_FILE}.pdf" ]]; then
        local pdf_size=$(ls -lh "${MAIN_FILE}.pdf" | awk '{print $5}')
        print_success "PDF generated successfully (${pdf_size})"
    else
        print_error "PDF was not generated"
        return 1
    fi

    # Count bibliography entries
    if [[ -f "${MAIN_FILE}.bbl" ]]; then
        local bib_entries=0
        if grep -q "bibitem" "${MAIN_FILE}.bbl" 2>/dev/null; then
            bib_entries=$(grep -c "bibitem" "${MAIN_FILE}.bbl" 2>/dev/null)
        fi
        print_success "Bibliography contains $bib_entries entries"
    fi

    # Check for any remaining warnings
    if [[ -f "${MAIN_FILE}.log" ]]; then
        local total_warnings=0
        if grep -q "Warning" "${MAIN_FILE}.log" 2>/dev/null; then
            total_warnings=$(grep -c "Warning" "${MAIN_FILE}.log" 2>/dev/null)
        fi
        if [[ "$total_warnings" -gt 0 ]]; then
            print_warning "Total warnings in compilation: $total_warnings"
        else
            print_success "No compilation warnings"
        fi
    fi

    echo "===================="
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -c|--clean)
            CLEAN_ALL=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -f|--force)
            FORCE_REBUILD=true
            CLEAN_ALL=true
            shift
            ;;
        -*)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
        *)
            MAIN_FILE=$1
            shift
            ;;
    esac
done

# Main execution
main() {
    echo "LaTeX Bibliography Compilation Script"
    echo "====================================="

    print_status "Target file: ${MAIN_FILE}.tex"
    [[ "$VERBOSE" == true ]] && print_status "Verbose mode enabled"
    [[ "$FORCE_REBUILD" == true ]] && print_status "Force rebuild mode enabled"

    # Check required files
    check_files

    # Clean files if requested
    if [[ "$CLEAN_ALL" == true ]]; then
        clean_files
    fi

    # Step 1: First pdflatex run to generate .aux with citations
    run_pdflatex 1 "Generate .aux file with citations"

    # Check if we have citations to process
    if [[ -f "${MAIN_FILE}.aux" ]] && grep -q "\\citation" "${MAIN_FILE}.aux"; then
        print_status "Found citations in .aux file, processing bibliography..."

        # Step 2: Run bibtex to process citations
        run_bibtex

        # Step 3: Second pdflatex run to incorporate bibliography
        run_pdflatex 2 "Incorporate bibliography"

        # Step 4: Third pdflatex run to resolve cross-references
        run_pdflatex 3 "Resolve cross-references"
    else
        print_warning "No citations found in .aux file, skipping bibliography processing"
        print_status "Running one more pdflatex pass..."
        run_pdflatex 2 "Final compilation"
    fi

    # Check for remaining issues
    if check_citations; then
        print_success "All citations resolved successfully"
    else
        print_warning "Some citation issues remain"
    fi

    # Show summary
    show_summary

    print_success "Compilation completed!"
}

# Run main function
main "$@"
