# ======== Simple HTML Copy ========
# 
# Copies the files from "~/my_project" to "~/public_html", assuming:
#   1)  "~/my_project" contains the directories "cgi" and "html".
#   2)  There are no subdirectories under the "html" and "cgi"
#       directories.

# From directory
FROM_DIR="~/project"
# To directory
TO_DIR="~/public_html"

echo "Uploading files..."
echo "========================"
echo "    Uploading root directory files..."
cp -i "$FROM_DIR/*" "$TO_DIR/"
echo "      Root directory contents uploaded."
echo "------------------------"
echo "    Begin uploading subdirectories."

for i in cgi html; do
    echo "        " $i | tr 'a-z' 'A-Z'
    cp -i "$FROM_DIR/$i" "$TO_DIR/$i"
    echo "          Subdirectory uploaded."
done

echo "========================"
echo "Upload complete."
