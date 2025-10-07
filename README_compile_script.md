# LaTeX Bibliography Compilation Script

This script (`compile_bibliography.sh`) automates the compilation of LaTeX documents with bibliography support and handles common citation and reference issues. All output files are generated in the `build/` directory to keep the project root clean.

## Quick Start

```bash
# Make the script executable (first time only)
chmod +x compile_bibliography.sh

# Basic compilation (output goes to build/)
./compile_bibliography.sh

# Clean compile (removes build/ contents, recommended when adding new citations)
./compile_bibliography.sh -c

# Verbose mode to see detailed output
./compile_bibliography.sh -v

# Force complete rebuild (cleans build/ and recompiles)
./compile_bibliography.sh -f
```

## What the Script Does

The script performs the complete LaTeX bibliography compilation sequence:

1. **Build Directory Setup**: Creates `build/` directory if it doesn't exist
2. **File Checks**: Verifies that required files exist
3. **Optional Cleaning**: Removes auxiliary files from `build/` if requested
4. **First pdflatex**: Generates `.aux` file with citation references in `build/`
5. **BibTeX Processing**: Processes citations and creates bibliography in `build/`
6. **Second pdflatex**: Incorporates the bibliography into the document
7. **Third pdflatex**: Resolves all cross-references
8. **Issue Detection**: Reports any remaining citation or reference problems

## Command Line Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Show help message |
| `-c, --clean` | Clean all files in `build/` directory before compilation |
| `-v, --verbose` | Show detailed compilation output |
| `-f, --force` | Force complete rebuild (cleans `build/` and recompiles) |

## Usage Examples

```bash
# Compile main.tex with bibliography (PDF output in build/)
./compile_bibliography.sh

# Clean build/ directory and compile main.tex
./compile_bibliography.sh -c

# Compile a different document (output still goes to build/)
./compile_bibliography.sh document

# Force rebuild with verbose output (cleans build/ first)
./compile_bibliography.sh -f -v

# Clean compile with verbose output
./compile_bibliography.sh -c -v
```

## When to Use This Script

Use this script whenever you encounter bibliography-related issues:

- **New citations added**: When you add new `\cite{}` commands to your document
- **Undefined citations**: When you see "Citation 'xyz' undefined" warnings
- **Missing bibliography**: When your References section is empty or incomplete
- **After uncommenting sections**: When you enable new parts of your document that contain citations
- **Bibliography not updating**: When changes to `.bib` file don't appear in the output

## Output Interpretation

### Success Messages
- ✅ **PDF generated successfully in build/**: Your document compiled without errors and is available in the build directory
- ✅ **Bibliography contains X entries**: Shows how many references were processed
- ✅ **All citations resolved**: No undefined citations remain

### Warning Messages
- ⚠️ **BibTeX reported warnings**: Minor issues (e.g., missing publisher) - usually safe to ignore
- ⚠️ **Total warnings in compilation**: General LaTeX warnings - check if important

### Error Messages
- ❌ **pdflatex failed**: Check the `build/main.log` file for syntax errors
- ❌ **bibtex failed**: Check the `build/main.blg` file for bibliography issues
- ❌ **Found undefined citations**: Some citations couldn't be resolved

## Troubleshooting

### Script Fails to Run
```bash
# Make sure the script is executable
chmod +x compile_bibliography.sh

# Check if you're in the right directory
ls -la compile_bibliography.sh
```

### Still Getting Citation Errors
1. Check that citation keys in your `.tex` file match those in your `.bib` file
2. Verify your `.bib` file syntax is correct
3. Try running with `-f -v` for detailed output
4. Check the `build/main.blg` file for BibTeX error details

### PDF Not Generated
1. Check for LaTeX syntax errors in your `.tex` files
2. Look at the `build/main.log` file for specific error messages
3. Try commenting out problematic sections to isolate the issue
4. Use `-c` option to clean the build directory and try again

## Files Created/Modified

The script works with these files:
- **Input**: `main.tex` (or specified file), `bibliografia.bib` (in project root)
- **Generated in build/**: `main.pdf`, `main.aux`, `main.bbl`, `main.log`
- **Temporary in build/**: `main.blg`, `main.out`, `main.toc`, etc.

The build directory structure:
```
project/
├── main.tex
├── bibliografia.bib
├── compile_bibliography.sh
└── build/
    ├── main.pdf          # Final output
    ├── main.aux
    ├── main.bbl
    ├── main.log
    └── ... (other auxiliary files)
```

## Script Features

- **Build Directory Management**: Automatically creates and manages `build/` directory
- **Smart Detection**: Only runs BibTeX if citations are found
- **Error Handling**: Stops on compilation errors with helpful messages
- **Progress Reporting**: Shows what step is currently running
- **Summary Report**: Provides overview of compilation results
- **Clean Mode**: Removes old auxiliary files from `build/` that might cause issues
- **Organized Output**: Keeps project root clean by isolating all generated files

## Tips for Best Results

1. **Always use `-c` when adding new citations** to ensure clean compilation from `build/`
2. **Use `-v` when debugging** to see detailed error messages
3. **Keep your `.bib` file clean** with proper syntax
4. **Run the script after major changes** to your document structure
5. **Find your PDF in the build/ directory** after successful compilation
6. **Use `-f` for a complete fresh start** when encountering persistent issues

## Requirements

- LaTeX installation with `pdflatex` and `bibtex`
- Bash shell (available on macOS, Linux, and Windows with WSL)
- Your main LaTeX file and bibliography file in the project root directory
- Write permissions to create the `build/` directory