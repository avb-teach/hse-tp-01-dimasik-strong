#!/bin/bash

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 /path/to/input_dir /path/to/output_dir [--max_depth N]"
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
MAX_DEPTH=""

args=("$@")
for ((i=2; i<${#args[@]}; i++)); do
    if [[ "${args[i]}" == "--max_depth" ]]; then
        ((i++))
        MAX_DEPTH="${args[i]}"
        if ! [[ "$MAX_DEPTH" =~ ^[0-9]+$ ]]; then
            echo "Error: --max_depth must be a positive integer"
            exit 1
        fi
    fi
done

if [[ ! -d "$INPUT_DIR" ]]; then
    echo "Error: Input directory does not exist."
    exit 1
fi

mkdir -p "$OUTPUT_DIR" 2>/dev/null

find_files() {
    local depth_arg=()
    if [[ -n "$MAX_DEPTH" ]]; then
        depth_arg=("-maxdepth" "$MAX_DEPTH")
    fi
    find "$INPUT_DIR" -mindepth 1 "${depth_arg[@]}" -type f -print0
}

declare -A file_counts

while IFS= read -r -d '' filepath; do
    filename=$(basename -- "$filepath")
    
    if [[ "$filename" =~ ^(.+)\.([^./]+)$ ]]; then
        base="${BASH_REMATCH[1]}"
        ext="${BASH_REMATCH[2]}"
    else
        base="$filename"
        ext=""
    fi

    if [[ -e "$OUTPUT_DIR/$filename" ]]; then
        ((file_counts["$filename"]++))
        count=${file_counts["$filename"]}
        if [[ -n "$ext" ]]; then
            new_filename="${base}_${count}.${ext}"
        else
            new_filename="${base}_${count}"
        fi
        cp -- "$filepath" "$OUTPUT_DIR/$new_filename"
    else
        file_counts["$filename"]=0
        cp -- "$filepath" "$OUTPUT_DIR/$filename"
    fi
done < <(find_files)

echo "Files collected successfully."