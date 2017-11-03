#!/bin/bash

set -e
set -o pipefail

cd task-input

find . -type "$FIND_TYPE" -name "$FIND_NAME" | while read -r line; 
do
  # Contains the extension; 'filename.txt'
  filename=$(basename "$line")
  
  # Handles when there's no extension ('Makefile' => '' empty extension)
  extension=$([[ "$filename" = *.* ]] && echo ".${filename#*.}" || echo '')
  
  # Prune off extension; 'filename'
  filename="${filename%%.*}"
    
  mv "$line" "$(dirname "$line")/${PREFIX}${filename}${SUFFIX}${extension}"
done 

cd ..

cp -R task-input/* task-output/.