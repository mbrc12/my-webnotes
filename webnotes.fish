#!/bin/env fish

set body ""

for file in (find Notes/*.svgz -printf "%f\n")
    set filename (echo $file | awk -F. '{print $1}')
    cat Notes/$file | gunzip > Pages/$filename.svg
    set height (identify -format "%h" Pages/$filename.svg)
    set width (identify -format "%w" Pages/$filename.svg)
    echo "$filename: $height x $width"
    cat document.html | \
    sed "s/%%PATH%%/$filename.svg/" | \
    sed "s/%%NAME%%/$filename/" | \
    sed "s/%%HEIGHT%%/$height/" | \
    sed "s/%%WIDTH%%/$width/">  "Pages/"$filename".html"
    
    set epochtime (stat -c "%Y" Notes/$file)
    set modified (date -d "@"$epochtime '+%a %b %d %T %Z')

    set current "<tr><td style='padding:20px'><a style='color:red' href='Pages/$filename.html'>$filename</a></td><td>$modified</td></tr>"
    set body $body$current
    echo $modified
end

cat template.html | sed "s#%%BODY%%#$body#" | sed "s/%%USER%%/$WEBNOTEUSER/" > index.html

git add .
git commit -m "Automatic Commit"
git push -u origin main
