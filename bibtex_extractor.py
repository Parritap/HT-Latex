#!/usr/bin/env python3
"""
BibTeX ID and DOI Extractor
Extracts citation IDs and DOIs from BibTeX entries and outputs to CSV format.
"""

import re
import csv
import argparse
import sys
from pathlib import Path


def extract_bibtex_entries(content):
    """
    Extract individual BibTeX entries from the content.

    Args:
        content (str): The full BibTeX file content

    Returns:
        list: List of BibTeX entry strings
    """
    # Pattern to match complete BibTeX entries
    pattern = r"@\w+\s*\{[^@]*?\n\}"
    entries = re.findall(pattern, content, re.DOTALL | re.IGNORECASE)
    return entries


def extract_id_and_doi(bibtex_entry):
    """
    Extract ID and DOI from a single BibTeX entry.

    Args:
        bibtex_entry (str): A single BibTeX entry

    Returns:
        tuple: (id, doi) where both can be None if not found
    """
    # Extract ID (the part after the opening brace)
    id_pattern = r"@\w+\s*\{\s*([^,\s]+)"
    id_match = re.search(id_pattern, bibtex_entry, re.IGNORECASE)
    entry_id = id_match.group(1).strip() if id_match else None

    # Extract DOI (look for doi field)
    doi_pattern = r'doi\s*=\s*["{]([^"}]+)["}]'
    doi_match = re.search(doi_pattern, bibtex_entry, re.IGNORECASE)
    doi = doi_match.group(1).strip() if doi_match else None

    # Also check for URL containing DOI
    if not doi:
        url_pattern = r'url\s*=\s*["{]([^"}]*doi[^"}]*)["}]'
        url_match = re.search(url_pattern, bibtex_entry, re.IGNORECASE)
        if url_match:
            url = url_match.group(1)
            # Extract DOI from URL
            doi_in_url = re.search(r"doi\.org/(.+)", url, re.IGNORECASE)
            if doi_in_url:
                doi = doi_in_url.group(1).strip("/")

    return entry_id, doi


def process_bibtex_file(input_file, output_file=None, include_missing=False):
    """
    Process a BibTeX file and extract IDs and DOIs.

    Args:
        input_file (str): Path to input BibTeX file
        output_file (str): Path to output CSV file (optional)
        include_missing (bool): Include entries without DOI

    Returns:
        list: List of (id, doi) tuples
    """
    try:
        with open(input_file, "r", encoding="utf-8") as f:
            content = f.read()
    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found.", file=sys.stderr)
        return []
    except Exception as e:
        print(f"Error reading file: {e}", file=sys.stderr)
        return []

    entries = extract_bibtex_entries(content)
    results = []

    for entry in entries:
        entry_id, doi = extract_id_and_doi(entry)

        if entry_id:  # Only process if we found an ID
            if doi or include_missing:
                results.append((entry_id, doi or ""))

    # Write to CSV
    if output_file:
        try:
            with open(output_file, "w", newline="", encoding="utf-8") as csvfile:
                writer = csv.writer(csvfile)
                writer.writerow(["ID", "DOI"])  # Header
                writer.writerows(results)
            print(f"Results written to '{output_file}'")
        except Exception as e:
            print(f"Error writing to CSV file: {e}", file=sys.stderr)
    else:
        # Print to stdout
        writer = csv.writer(sys.stdout)
        writer.writerow(["ID", "DOI"])
        writer.writerows(results)

    return results


def process_bibtex_string(bibtex_string, output_file=None, include_missing=False):
    """
    Process a BibTeX string directly.

    Args:
        bibtex_string (str): BibTeX content as string
        output_file (str): Path to output CSV file (optional)
        include_missing (bool): Include entries without DOI

    Returns:
        list: List of (id, doi) tuples
    """
    entries = extract_bibtex_entries(bibtex_string)
    results = []

    for entry in entries:
        entry_id, doi = extract_id_and_doi(entry)

        if entry_id:  # Only process if we found an ID
            if doi or include_missing:
                results.append((entry_id, doi or ""))

    # Write to CSV
    if output_file:
        try:
            with open(output_file, "w", newline="", encoding="utf-8") as csvfile:
                writer = csv.writer(csvfile)
                writer.writerow(["ID", "DOI"])  # Header
                writer.writerows(results)
            print(f"Results written to '{output_file}'")
        except Exception as e:
            print(f"Error writing to CSV file: {e}", file=sys.stderr)
    else:
        # Print to stdout
        writer = csv.writer(sys.stdout)
        writer.writerow(["ID", "DOI"])
        writer.writerows(results)

    return results


def main():
    parser = argparse.ArgumentParser(
        description="Extract BibTeX IDs and DOIs to CSV format",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s input.bib                     # Output to stdout
  %(prog)s input.bib -o output.csv       # Output to file
  %(prog)s input.bib --include-missing   # Include entries without DOI
  echo "@article{id,doi={10.1000/example}}" | %(prog)s --stdin
        """,
    )

    parser.add_argument(
        "input_file",
        nargs="?",
        help="Input BibTeX file (use --stdin to read from stdin)",
    )
    parser.add_argument("-o", "--output", help="Output CSV file (default: stdout)")
    parser.add_argument(
        "--include-missing",
        action="store_true",
        help="Include entries without DOI (empty DOI field)",
    )
    parser.add_argument(
        "--stdin", action="store_true", help="Read BibTeX content from stdin"
    )
    parser.add_argument(
        "--stats", action="store_true", help="Show statistics after processing"
    )

    args = parser.parse_args()

    if args.stdin:
        # Read from stdin
        try:
            content = sys.stdin.read()
            results = process_bibtex_string(content, args.output, args.include_missing)
        except KeyboardInterrupt:
            print("\nOperation cancelled.", file=sys.stderr)
            return 1
    elif args.input_file:
        # Read from file
        if not Path(args.input_file).exists():
            print(f"Error: File '{args.input_file}' does not exist.", file=sys.stderr)
            return 1
        results = process_bibtex_file(
            args.input_file, args.output, args.include_missing
        )
    else:
        parser.print_help()
        return 1

    if args.stats:
        total_entries = len(results)
        entries_with_doi = sum(1 for _, doi in results if doi)
        entries_without_doi = total_entries - entries_with_doi

        print(f"\nStatistics:", file=sys.stderr)
        print(f"Total entries processed: {total_entries}", file=sys.stderr)
        print(f"Entries with DOI: {entries_with_doi}", file=sys.stderr)
        print(f"Entries without DOI: {entries_without_doi}", file=sys.stderr)
        if total_entries > 0:
            percentage = (entries_with_doi / total_entries) * 100
            print(f"DOI coverage: {percentage:.1f}%", file=sys.stderr)

    return 0


if __name__ == "__main__":
    sys.exit(main())
