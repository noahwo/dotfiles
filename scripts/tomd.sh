#!/bin/bash

# Check if a file parameter was provided
if [ $# -eq 0 ]; then
  echo "Error: Please provide a docx file as parameter"
  echo "Usage: $0 <filename.docx>"
  exit 1
fi

# Get the input file path
input_file="$1"

# Extract filename without extension
filename=$(basename "$input_file" .docx)

# Check if input file exists and is a docx file
if [ ! -f "$input_file" ]; then
  echo "Error: File '$input_file' not found"
  exit 1
fi

if [[ ! "$input_file" =~ \.docx$ ]]; then
  echo "Error: Input file must be a .docx file"
  exit 1
fi

# Create media directory if it doesn't exist
mkdir -p "./attachments/$filename"

# Convert docx to markdown using pandoc
pandoc \
  -t markdown_strict \
  --extract-media="./attachments/$filename" \
  "$input_file" \
  -o "$filename.md"

# Check if conversion was successful
if [ $? -eq 0 ]; then
  echo "Conversion successful!"
  echo "Markdown file: $filename.md"
  echo "Media files: ./attachments/$filename/"
else
  echo "Error: Conversion failed"
  exit 1
fi
