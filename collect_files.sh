#!/bin/bash

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 /path/to/input_dir /path/to/output_dir [--max_depth N]"
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
MAX_DEPTH=""

if [[ "$3" == "--max_depth" && -n "$4" ]]; then
    MAX_DEPTH="$4"
fi

if [[ ! -d "$INPUT_DIR" ]]; then
    echo "Error: Input directory does not exist."
    exit 1
fi

if [[ ! -d "$OUTPUT_DIR" ]]; then
    echo "Error: Output directory does not exist."
    exit 1
fi

copy_files() {
    local input="$1"
    local output="$2"
    local max_depth="$3"

    if [[ -n "$max_depth" ]]; then
        find "$input" -mindepth 1 -maxdepth "$max_depth" -type f
    else
        find "$input" -type f
    fi
}

declare -A filename_counter

copy_files "$INPUT_DIR" "$OUTPUT_DIR" "$MAX_DEPTH" | while read -r filepath; do
    filename=$(basename "$filepath")
    if [[ -e "$OUTPUT_DIR/$filename" ]]; then
        count=${filename_counter["$filename"]}
        if [[ -z "$count" ]]; then
            count=1
        else
            ((count++))
        fi
        filename_counter["$filename"]=$count
        name="${filename%.*}"
        extension="${filename##*.}"
        if [[ "$name" == "$extension" ]]; then
            new_filename="${name}${count}"
        else
            new_filename="${name}${count}.${extension}"
        fi
        cp "$filepath" "$OUTPUT_DIR/$new_filename"
    else
        filename_counter["$filename"]=1
        cp "$filepath" "$OUTPUT_DIR/$filename"
    fi
done

echo "Files collected successfully."
