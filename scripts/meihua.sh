#! /bin/sh
# 美画
#

if [ $# -eq 0 ]; then
	printf "Usage:\n $ meihua <photo/dir/path>\n\n"
	exit 1
fi

photo_dir=$1

read -p "Gallery title: " gallery_title
read -p "Gallery date: " gallery_date
read -p "Gallery filename: " gallery_page

# Generate <img> tags based on files in photo dir
imgs=""
for photo in ${photo_dir}/*; do
	# Check if ImageMagick installed
	if ! command -v identify &> /dev/null;
	then
		imgs+="\t<p><img src=\"$photo\"></p>\n"
	else
		ratio=`identify -format '%[fx:(h/w)]' "$photo"`
		if awk "BEGIN {exit !($ratio <= 1.0)}";
		then
			imgs+="\t<p><img src=\"$photo\" class=\"landscape\"></p>\n"
		else
			imgs+="\t<p><img src=\"$photo\" class=\"portrait\"></p>\n"
			# TODO: For half-frame photos it could be cool to have two
			# next to each other on a single line.
		fi
	fi
done

cat <<EOF > ${gallery_page}.html
<!DOCTYPE html>
<html>
<head>
	<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes" />
	<title>$gallery_title</title>
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
		h1,h2,h3 {
			line-height: 1.2;
		}
		header {
			margin-bottom: 4em;
			text-align: center;
		}
	</style>
</head>
<body>
	<header>
		<h1>$gallery_title</h1>
		<h3>$gallery_date</h3>
	</header>
`echo $imgs`
</body>
</html>
EOF

