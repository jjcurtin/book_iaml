#!/bin/bash  

# ./render.sh FILE FORMAT
# FILE = all or filename
# FORMAT = book, slides, or slides_wide

FILE=$1
FORMAT=$2

if [ "$FILE" = "all" ] && [ "$FORMAT" = "book" ]; then
  echo ""
  echo "Publishing all chapters to gh-pages"
  echo ""
  cp _quarto_book.yml _quarto.yml
  quarto publish gh-pages --no-browser 
  git restore _quarto.yml
fi

if [ $FILE != "all" ] && [ "$FORMAT" = "book" ];  then
  echo "ERROR - MUST RENDER FULL BOOK FOR NOW!"
  #echo ""
	#echo "Rendering $FILE to web book"
  #echo "Do not forget to add, commit, and push to Github"
  #echo ""
  #cp _quarto_book.yml _quarto.yml
  #quarto render "$FILE"
  #git restore _quarto.yml
fi
 
if [ $FILE != "all" ] && [ "$FORMAT" = "slides" ];  then
  echo ""
	echo "Publishing $FILE to standard slides on quarto-pub"
  echo ""
  cp _quarto_slides.yml _quarto.yml
  quarto publish quarto-pub "$FILE" 
  git restore _quarto.yml
fi
 
if [ $FILE != "all" ] && [ "$FORMAT" = "slides_wide" ];  then
  echo ""
	echo "Publishing $FILE to wide slides on quarto-pub"
  echo ""
  cp _quarto_slides_wide.yml _quarto.yml
  quarto publish quarto-pub "$FILE" 
  git restore _quarto.yml
fi
