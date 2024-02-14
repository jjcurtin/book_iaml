#!/bin/bash  

# ./render.sh FILE FORMAT
# FILE = all or filename
# FORMAT = book, slides, or slides_wide

FILE=$1
FORMAT=$2

if [ "$FILE" = "all" ] && [ "$FORMAT" = "book" ]; then
  echo ""
  echo "Rendering all chapters to web book"
  echo "Do not forget to add, commit, and push to Github"
  echo ""
  cp _quarto_book.yml _quarto.yml
  quarto render
  git restore _quarto.yml
fi

if [ $FILE != "all" ] && [ "$FORMAT" = "book" ];  then
  echo ""
	echo "Rendering $FILE to web book"
  echo "Do not forget to add, commit, and push to Github"
  echo ""
  cp _quarto_book.yml _quarto.yml
  quarto render "$FILE"
  git restore _quarto.yml
fi
 
if [ $FILE != "all" ] && [ "$FORMAT" = "slides" ];  then
  echo ""
	echo "Rendering $FILE to standard slides on quarto-pub"
  echo ""
  cp _quarto_slides.yml _quarto.yml
  quarto publish quarto-pub "$FILE" 
  git restore _quarto.yml
fi
 
if [ $FILE != "all" ] && [ "$FORMAT" = "slides_wide" ];  then
  echo ""
	echo "Rendering $FILE to wide slides on quarto-pub"
  echo ""
  cp _quarto_slides_wide.yml _quarto.yml
  quarto publish quarto-pub "$FILE" 
  git restore _quarto.yml
fi
