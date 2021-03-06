#!/bin/bash
# Charlie Rose
# A script to build my webpages for my personal site

TEMPLATE=$(cat template.html)
MD_SRC='./markdownfiles'
BLOGMD_SRC=${MD_SRC}/blog
BLOGPOST_SRC="./blogposts"

declare -A HEADERS
HEADERS=( ["activism.html"]="Activism Work"
		  ["blog.html"]="Blog"
		  ["experience.html"]="Professional Experience"
		  ["index.html"]=" "
		  ["projects.html"]="Personal Projects")

echo "Building main HTML files from Markdown..."

for IN_FILE in ${MD_SRC}/*
do
	if [ -d ${IN_FILE} ]
	then
		continue
	fi

	OUT_FILE=.${IN_FILE#${MD_SRC}}
	OUT_FILE=${OUT_FILE%.md}.html

	echo "Building ${OUT_FILE} from ${IN_FILE}..."
	
	HEADER=${HEADERS[${OUT_FILE#./}]}
	if [ ! "$OUT_FILE" = "./index.html" ]
	then
		HEADER=" - $HEADER"
	fi

	CONTENT=$(pandoc --preserve-tabs ${IN_FILE})

	HTMLPAGE=${TEMPLATE}
	HTMLPAGE="${HTMLPAGE/<!-- HEADING -->/${HEADER}}"
	HTMLPAGE="${HTMLPAGE/<!-- CONTENT -->/${CONTENT}}"

	echo "${HTMLPAGE}" > ${OUT_FILE}
done

echo "Completed main HTML files from Markdown"

if [ ! -e "${BLOGPOST_SRC}" ]
then
	echo "Building blogpost directory..."
	mkdir ${BLOGPOST_SRC}
	echo "Completed making blogpost directory"
fi

echo "Building blog HTML files from Markdown..."
echo "Building blog main page HTML file..."

BLOG_CONTENT=" "

for IN_FILE in $(ls ${BLOGMD_SRC} | sort -r)
do
	# Only build the page if it's not in progress
	if [ "${IN_FILE}" = "${IN_FILE%wip*}" ]
	then
		OUT_FILE=${BLOGPOST_SRC}/${IN_FILE#${BLOGMD_SRC}}
		OUT_FILE=${OUT_FILE%.md}.html

		echo "Building ${OUT_FILE} from ${IN_FILE}..."

		TITLE=`head -n 1 ${BLOGMD_SRC}/${IN_FILE}`
		TITLE=${TITLE#"# "}
		
		HEADER=" - ${HEADERS[blog.html]}"

		CONTENT=$(pandoc --preserve-tabs ${BLOGMD_SRC}/${IN_FILE})

		HTMLPAGE=${TEMPLATE}
		HTMLPAGE="${HTMLPAGE/<!-- HEADING -->/${HEADER}}"
		HTMLPAGE="${HTMLPAGE/<!-- CONTENT -->/${CONTENT}}"

		echo "${HTMLPAGE}" > ${OUT_FILE}

		DATE=${IN_FILE%_*}
		MONTH=${DATE%-*}
		MONTH=${MONTH#*-}
		DAY=${DATE##*-}
		YEAR=${DATE%%-*}
		PRETTYDATE="${MONTH}/${DAY}/${YEAR}"

		ENTRY_LINK="<a href='${OUT_FILE#./}'>$PRETTYDATE : $TITLE</a>"
		BLOG_CONTENT="${BLOG_CONTENT}<br>${ENTRY_LINK}"

	else
		echo "Ignoring work in progress file ${IN_FILE}"
	fi
done

echo "Completed blog HTML files from Markdown"

echo "Compiling main blog.html file..."

OUT_FILE="blog.html"

HTMLPAGE=${TEMPLATE}
HTMLPAGE="${HTMLPAGE/<!-- HEADING -->/${HEADER}}"
HTMLPAGE="${HTMLPAGE/<!-- CONTENT -->/${BLOG_CONTENT}}"

echo "${HTMLPAGE}" > ${OUT_FILE}

echo "Completed main blog page"

echo "Completed Script"
