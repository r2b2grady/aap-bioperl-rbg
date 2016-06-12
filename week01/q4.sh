# ======== Simple HTML Copy ========
# 
# Copies the files from "~/my_project" to "~/public_html", assuming:
#   1)  "~/my_project" contains the directories "cgi" and "html".
#   2)  There are no subdirectories under the "html" and "cgi"
#       directories.

# From directory
FROM_DIR="~/my_project"
# To directory
TO_DIR="~/public_html"

echo "Uploading files..."
echo "========================"
echo "    Uploading root directory files..."
cp -i "$FROM_DIR/*" "$t/"
echo "      Root directory contents uploaded."
echo "------------"
echo "    Uploading CGI directory..."
cp -i "$FROM_DIR/cgi/*" "$t/cgi/"
echo "      CGI directory uploaded."
echo "------------"
echo "    Uploading HTML directory..."
cp -i "$FROM_DIR/html/*" "$TO_DIR/html/"
echo "      HTML directory uploaded."
echo "========================"
echo "Upload complete."
