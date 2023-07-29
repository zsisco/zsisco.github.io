#! /bin/sh
# 美画
#
# Run this script in the parent photos dir;
# meta.txt contains a mapping of child dir to (album title + date).
# Then visit each child dir and generate its photo album
# based on title and date parameters (if index.html missing).
# Then, in the parent dir generate an index of photo albums.
#
# Usage:
# meihua.sh [-f]
# -f    Force generate all photo albums
(! ([ $# -gt 0 ] && [ "$1" = "-f" ]))
force=$?

# Script uses current directory as root
PHOTOS="."

[ ! -f "$PHOTOS"/meta.txt ] && echo "Error: No meta.txt file found!" && exit 1

# Check if ImageMagick installed
(! command -v identify &> /dev/null)
has_identify=$?

# CSS, header stuff
styles=$(cat <<EOF
	<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes" />
	<style>
		img {
			object-fit: contain;
			display: block;
			margin-left: auto;
			margin-right: auto;
		}
		.landscape {
			width: 100%;
			height: auto;
		}
		.portrait {
			width: 60%;
			height: auto;
		}
		body {
			margin: 1em auto;
			max-width: 60%;
			padding: 0.62em;
			font: 1.0em/1.6 monospace;
		}
		header {
			margin-bottom: 4em;
			text-align: center;
		}
	</style>
EOF
)

albums=""

while read meta; do
    album=$(echo "$meta" | cut -d ';' -f 1)
    album_title=$(echo "$meta" | cut -d ';' -f 2)
    album_date=$(echo "$meta" | cut -d ';' -f 3)
    album_extra=$(echo "$meta" | cut -d ';' -f 4)

    albums+="<li><a href=\"$album/index.html\">$album_title</a></li>\n"

    if [ "$force" = 1 ] || [ ! -f "$album"/index.html ];
    then
        # Assumes .jpg file endings
        # Generate <img> elements based on input files
        imgs=""
        for photo_file in $(find $PHOTOS/$album -name "*.jpg" -print | sort ); do
			echo "$photo_file"
            photo=$(echo "$photo_file" | cut -d '/' -f 3)
	        imgs+="\t<p><a href=\"$photo\"><img src=\"$photo\" loading=\"lazy\""
	        if [ "$has_identify" -eq 1 ];
	        then
		        # Use ImageMagick identify to get height/width of image
		        ratio=$(identify -format '%[fx:(h/w)]' "$photo_file")
		        if awk "BEGIN {exit !($ratio <= 1.0)}";
		        then
			        imgs+=" class=\"landscape\""
		        else
			        imgs+=" class=\"portrait\""
		        fi
	        fi
	        imgs+="></a></p>\n"
	        # TODO: For half-frame photos it could be cool to have two
	        # photos next to each other on a single <p>.
        done
        cat <<EOF > $album/index.html
<!DOCTYPE html>
<html>
<head>
	<title>${album_title}</title>
$(echo "$styles")
</head>
<body>
	<header>
		<h1>${album_title}</h1>
		<h3>${album_date}</h3>
		<p>${album_extra}</p>
	</header>
$(echo "$imgs")
</body>
</html>
EOF
    fi
done <$PHOTOS/meta.txt

# Finally, generate index file with list of galleries
cat <<EOF > index.html
<!DOCTYPE html>
<html>
<head>
	<title>Photos</title>
$(echo "$styles")
</head>
<body>
	<header>
		<h1>Photos</h1>
    </header>
<ul>
$(echo "$albums")
</ul>
</body>
</html>
EOF
