#!/bin/bash

# ======== Simple HTML Copy ========
# 
# Copies the files from "~/my_project" to "~/public_html", assuming:
#   1)  "~/my_project" contains the directories "cgi" and "html".
#   2)  There are no subdirectories under the "html" and "cgi"
#       directories.

# From directory
FROM_DIR=~/project
# To directory
TO_DIR=~/public_html

cd $FROM_DIR

if [ ! -d $TO_DIR ]; then
    mkdir $TO_DIR
    echo "    $TO_DIR created."
fi

for f in `find . cgi html -maxdepth 1 -type f`; do
    if [ -f "$TO_DIR/$f" ]; then
	if [ "$FROM_DIR/$f" -nt "$TO_DIR/$f" ]; then
	    cp $FROM_DIR/$f $TO_DIR/$f
	    echo "    Copied $FROM_DIR/$f to $TO_DIR/$f"
	else
	    echo "    $TO_DIR/$f newer than $OLD_DIR/$f; not copied"
	fi
    else
	cp $FROM_DIR/$f $TO_DIR/$f
	echo "    Copied $FROM_DIR/$f to $TO_DIR/$f"
    fi
done

echo "========================"
echo "Upload complete."
