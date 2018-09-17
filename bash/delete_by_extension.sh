#!/bin/bash

DIRECTORY="/html/"
FILE_EXT="*.*" # will not even look at directories
FILELIST=(${DIRECTORY}/${FILE_EXT})

echo -e "$(date) ____________________"

## if there are files in directory
if [ ${#FILELIST[@]} -gt 0 ]; then
	
	# move into the directory
	cd $DIRECTORY
	
	echo -e "> processing: [${#FILELIST[@]}] files from $DIRECTORY\n"
	
	# for each file found
	for f in "${FILELIST[@]}"
	do
		## if it is an image, ignore it
		if [[ "${f##*.}" =~ ^(jpg|jpeg|png|gif|tiff)$ ]]; then
			echo "[#] SAFE: [$f]"
		else
			echo "[!] DELETE: [$f]"
			rm $f # delete the file.
		fi
	done
else
	echo -e "[!] No files found."
fi
echo -e "finished at: $(date)\n\n"