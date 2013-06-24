#!/bin/sh

find "markdown-site" -iname "*.html" | 
while read file
do
    # convert html file into markdown file and delete the html file
    pandoc "${file}" -o "${file%.*}".tmp.md
    rm "${file}"

    # top and tail the resulting markdown file to remove nav and footer sections
    sed '1,49d' "${file%.*}".tmp.md | sed -e :a -e '$d;N;2,7ba' -e 'P;D' > "${file%.*}".md
    rm "${file%.*}".tmp.md
done
