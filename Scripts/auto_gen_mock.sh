#!/bin/bash

if ! command -v mockolo &> /dev/null; then
echo "Mockolo is not installed. Please install it first."
exit 1
fi

mkdir -p ./NetworkKit/GeneratedMocks

source_directory="./NetworkKit"
output_file="./NetworkKit/GeneratedMocks/OutputMocks.swift"
excluded_types=("Images" "Strings")

exclude_flags=""

for type in "${excluded_types[@]}"; do
exclude_flags="$exclude_flags -x $type"
done

mockolo -s "$source_directory" -d "$output_file" $exclude_flags

import_statements=(
"@testable import NetworkKit"
)

for statement in "${import_statements[@]}"; do
sed -i '' "1i\\
    $statement
    " "$output_file"
done

echo "Mocks have been generated and saved to $output_file."
