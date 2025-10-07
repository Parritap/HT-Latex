#!/bin/bash

# LaTeX Bibliography Compilation Script
# This script handles common bibliography compilation issues in LaTeX projects
# Author: Assistant
# Version: 2.0

# Note: Not using set -e because grep commands may return non-zero for no matches

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
MAIN_FILE="main"
BUILD_DIR="build"
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
All output files are generated in the build/ directory.

OPTIONS:
    -h, --help          Show this help message
    -c, --clean         Clean all auxiliary files before compilation
    -v, --verbose       Show detailed compilation output
    -f, --force         Force complete rebuild (implies --clean)

ARGUMENTS:
    TEX_FILE            Name of the main .tex file (without extension, default: main)

EXAMPLES:
    $0                  # Compile main.tex with bibliography (output to build/)
    $0 -c               # Clean build/ and compile main.tex
    $0 -v document      # Compile document.tex with verbose output
    $0 -f -v            # Force rebuild with verbose output

The script performs the following steps:
1. Creates build/ directory if it doesn't exist
2. Copies bibliography files (.bib) and style files (.bst) to build/
3. Checks for required files
4. Optionally cleans auxiliary files in build/
5. Runs pdflatex to generate .aux file in build/
6. Runs bibtex to process citations
7. Runs pdflatex twice more to resolve all references
8. Reports any remaining issues

EOF
}

# Function to create build directory
create_build_dir() {
    if [[ ! -d "$BUILD_DIR" ]]; then
        mkdir -p "$BUILD_DIR"
        print_status "Created build directory: $BUILD_DIR"
    fi
}

# Function to copy bibliography and style files to build directory
copy_bib_files() {
    print_status "Copying bibliography and style files to build directory..."

    local copied=0

    # Copy .bib files
    for bib_file in *.bib; do
        if [[ -f "$bib_file" ]]; then
            cp "$bib_file" "$BUILD_DIR/"
            ((copied++))
            [[ "$VERBOSE" == true ]] && echo "  Copied: $bib_file to $BUILD_DIR/"
        fi
    done

    # Copy .bst files (bibliography style files)
    for bst_file in *.bst; do
        if [[ -f "$bst_file" ]]; then
            cp "$bst_file" "$BUILD_DIR/"
            ((copied++))
            [[ "$VERBOSE" == true ]] && echo "  Copied: $bst_file to $BUILD_DIR/"
        fi
    done

    if [[ "$copied" -gt 0 ]]; then
        print_success "Copied $copied bibliography and style file(s) to $BUILD_DIR"
    else
        print_warning "No bibliography or style files found to copy"
    fi
}

# Function to clean auxiliary files
clean_files() {
    print_status "Cleaning auxiliary files in $BUILD_DIR..."

    local files_to_clean=(
        "${BUILD_DIR}/${MAIN_FILE}.aux"
        "${BUILD_DIR}/${MAIN_FILE}.bbl"
        "${BUILD_DIR}/${MAIN_FILE}.blg"
        "${BUILD_DIR}/${MAIN_FILE}.log"
        "${BUILD_DIR}/${MAIN_FILE}.out"
        "${BUILD_DIR}/${MAIN_FILE}.toc"
        "${BUILD_DIR}/${MAIN_FILE}.lof"
        "${BUILD_DIR}/${MAIN_FILE}.lot"
        "${BUILD_DIR}/${MAIN_FILE}.fls"
        "${BUILD_DIR}/${MAIN_FILE}.fdb_latexmk"
        "${BUILD_DIR}/${MAIN_FILE}.synctex.gz"
        "${BUILD_DIR}/${MAIN_FILE}.pdf"
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
        print_success "Cleaned $cleaned auxiliary files from $BUILD_DIR"
    else
        print_status "No auxiliary files to clean in $BUILD_DIR"
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

    # Check for bibliography style file
    local bst_files=(*.bst)
    if [[ ! -f "${bst_files[0]}" ]]; then
        print_warning "No .bst file found. Bibliography compilation may fail."
    else
        print_status "Found bibliography style file(s): ${bst_files[*]}"
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
        pdflatex -output-directory="$BUILD_DIR" "${MAIN_FILE}.tex"
        exit_code=$?
    else
        pdflatex -output-directory="$BUILD_DIR" "${MAIN_FILE}.tex" > /dev/null 2>&1
        exit_code=$?
    fi

    if [[ $exit_code -ne 0 ]]; then
        print_error "pdflatex failed on pass $pass_number"
        print_error "Check ${BUILD_DIR}/${MAIN_FILE}.log for details"
        exit $exit_code
    fi
}

# Function to run bibtex
run_bibtex() {
    print_status "Running bibtex to process citations..."

    local exit_code=0
    # Change to build directory to run bibtex
    pushd "$BUILD_DIR" > /dev/null || exit
    if [[ "$VERBOSE" == true ]]; then
        bibtex "${MAIN_FILE}"
        exit_code=$?
    else
        bibtex "${MAIN_FILE}" > /dev/null 2>&1
        exit_code=$?
    fi
    popd > /dev/null || exit

    if [[ $exit_code -ne 0 ]]; then
        print_error "bibtex failed"
        print_error "Check ${BUILD_DIR}/${MAIN_FILE}.blg for details"
        exit $exit_code
    fi

    # Check bibtex output for issues
    if [[ -f "${BUILD_DIR}/${MAIN_FILE}.blg" ]]; then
        local warnings=0
        local errors=0
        if grep -q "Warning" "${BUILD_DIR}/${MAIN_FILE}.blg" 2>/dev/null; then
            warnings=$(grep -c "Warning" "${BUILD_DIR}/${MAIN_FILE}.blg" 2>/dev/null)
        fi
        if grep -q "Error" "${BUILD_DIR}/${MAIN_FILE}.blg" 2>/dev/null; then
            errors=$(grep -c "Error" "${BUILD_DIR}/${MAIN_FILE}.blg" 2>/dev/null)
        fi

        if [[ "$errors" -gt 0 ]]; then
            print_error "BibTeX reported $errors error(s)"
            [[ "$VERBOSE" == true ]] && cat "${BUILD_DIR}/${MAIN_FILE}.blg"
        elif [[ "$warnings" -gt 0 ]]; then
            print_warning "BibTeX reported $warnings warning(s)"
            [[ "$VERBOSE" == true ]] && grep "Warning" "${BUILD_DIR}/${MAIN_FILE}.blg"
        else
            print_success "BibTeX completed successfully"
        fi
    fi
}

# Function to check for citation issues
check_citations() {
    print_status "Checking for citation issues..."

    if [[ -f "${BUILD_DIR}/${MAIN_FILE}.log" ]]; then
        local undefined_citations=0
        local undefined_references=0
        if grep -q "Citation.*undefined" "${BUILD_DIR}/${MAIN_FILE}.log" 2>/dev/null; then
            undefined_citations=$(grep -c "Citation.*undefined" "${BUILD_DIR}/${MAIN_FILE}.log" 2>/dev/null)
        fi
        if grep -q "Reference.*undefined" "${BUILD_DIR}/${MAIN_FILE}.log" 2>/dev/null; then
            undefined_references=$(grep -c "Reference.*undefined" "${BUILD_DIR}/${MAIN_FILE}.log" 2>/dev/null)
        fi

        if [[ "$undefined_citations" -gt 0 ]]; then
            print_error "Found $undefined_citations undefined citation(s)"
            if [[ "$VERBOSE" == true ]]; then
                echo "Undefined citations:"
                grep "Citation.*undefined" "${BUILD_DIR}/${MAIN_FILE}.log" | head -5
                [[ "$undefined_citations" -gt 5 ]] && echo "... and $((undefined_citations - 5)) more"
            fi
            return 1
        fi

        if [[ "$undefined_references" -gt 0 ]]; then
            print_warning "Found $undefined_references undefined reference(s)"
            if [[ "$VERBOSE" == true ]]; then
                echo "Undefined references:"
                grep "Reference.*undefined" "${BUILD_DIR}/${MAIN_FILE}.log" | head -3
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
    if [[ -f "${BUILD_DIR}/${MAIN_FILE}.pdf" ]]; then
        local pdf_size=$(ls -lh "${BUILD_DIR}/${MAIN_FILE}.pdf" | awk '{print $5}')
        print_success "PDF generated successfully in ${BUILD_DIR}/ (${pdf_size})"
    else
        print_error "PDF was not generated"
        return 1
    fi

    # Count bibliography entries
    if [[ -f "${BUILD_DIR}/${MAIN_FILE}.bbl" ]]; then
        local bib_entries=0
        if grep -q "bibitem" "${BUILD_DIR}/${MAIN_FILE}.bbl" 2>/dev/null; then
            bib_entries=$(grep -c "bibitem" "${BUILD_DIR}/${MAIN_FILE}.bbl" 2>/dev/null)
        fi
        print_success "Bibliography contains $bib_entries entries"
    fi

    # Check for any remaining warnings
    if [[ -f "${BUILD_DIR}/${MAIN_FILE}.log" ]]; then
        local total_warnings=0
        if grep -q "Warning" "${BUILD_DIR}/${MAIN_FILE}.log" 2>/dev/null; then
            total_warnings=$(grep -c "Warning" "${BUILD_DIR}/${MAIN_FILE}.log" 2>/dev/null)
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
    print_status "Output directory: ${BUILD_DIR}/"
    [[ "$VERBOSE" == true ]] && print_status "Verbose mode enabled"
    [[ "$FORCE_REBUILD" == true ]] && print_status "Force rebuild mode enabled"

    # Create build directory
    create_build_dir

    # Copy bibliography and style files to build directory
    copy_bib_files

    # Check required files
    check_files

    # Clean files if requested
    if [[ "$CLEAN_ALL" == true ]]; then
        clean_files
    fi

    # Step 1: First pdflatex run to generate .aux with citations
    run_pdflatex 1 "Generate .aux file with citations"

    # Check if we have citations to process
    if [[ -f "${BUILD_DIR}/${MAIN_FILE}.aux" ]] && grep -q "\\citation" "${BUILD_DIR}/${MAIN_FILE}.aux"; then
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
