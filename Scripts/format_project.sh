#!/bin/bash

format_file() {
  swiftformat "$1"
}

format_directory() {
  local dir="$1"
  local ignore_folders=("${@:2}")
  for file in "$dir"/*; do
    if [ -d "$file" ]; then
      if [[ ! " ${ignore_folders[@]} " =~ " $file " ]]; then
        format_directory "$file" "${ignore_folders[@]}"
      fi
    elif [ "${file##*.}" = "swift" ]; then
      echo "Formatting: $file"
      format_file "$file"
    fi
  done
}

execute_format_code() {
  local ignore_folders=("${@:2}")
  format_directory "." "${ignore_folders[@]}"
}

if ! command -v swiftformat &>/dev/null; then
  if command -v brew &>/dev/null; then
    echo "Installing swiftformat using Homebrew..."
    brew install swiftformat
  else
    echo "Error: swiftformat is not installed, and Homebrew is not available."
    exit 1
  fi
fi

ignore_folders=("Scripts")
execute_format_code "${ignore_folders[@]}"
