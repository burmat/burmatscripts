#!/bin/bash

TMP_DIRECTORY="/var/www/html/tmp"
FILE_EXT="*.*" # will not even look at directories
FILELIST=(${TMP_DIRECTORY}/${FILE_EXT})

echo -e "$(date) ____________________"

## if there are files in directory
if [ ${#FILELIST[@]} -gt 0 ]; then
      # move into the directory
      cd $TMP_DIRECTORY

      echo -e "> processing: [${#FILELIST[@]}] files from $TMP_DIRECTORY\n"

      # for each file found
      for f in "${FILELIST[@]}"
      do
            ## if it is an image, ignore it
            if [[ "${f##*.}" =~ ^(jpg|jpeg|png|gif|tiff)$ ]]; then
                  echo "[#] SAFE: [$f]"
            else
                  echo "[!] DELETE: [$f]"
                  rm -f $f # delete the file.
            fi
      done
else
      echo -e "[!] No files found."
fi

echo -e "finished at: $(date)\n\n"