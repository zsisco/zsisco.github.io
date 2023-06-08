#! /bin/sh
# 美画
#

if [ $# -eq 0 ]; then
	printf "\nUsage:\n $ meihua.sh image-file ...\n\n"
	exit 1
fi

read -p "Gallery title: " gallery_title
read -p "Gallery date: " gallery_date

# Check if ImageMagick installed
(! command -v identify &> /dev/null)
has_identify=$?

# Generate <img> elements based on input files
imgs=""
for photo; do
	imgs+="\t<p><a href=\"$photo\"><img src=\"$photo\" loading=\"lazy\""
	if [ "$has_identify" -eq 1 ];
	then
		# Use ImageMagick identify to get height/width of image
		ratio=$(identify -format '%[fx:(h/w)]' "$photo")
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

cat <<EOF > index.html
<!DOCTYPE html>
<html>
<head>
	<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes" />
	<title>${gallery_title}</title>
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
</head>
<body>
	<header>
		<h1>${gallery_title}</h1>
		<h3>${gallery_date}</h3>
	</header>
$(echo "$imgs")
</body>
</html>
EOF

