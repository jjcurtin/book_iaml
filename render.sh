#!/bin/bash  

# ./render.sh FILE FORMAT
# FILE = all or filename
# FORMAT = book, slides, or wide_slides

FILE=$1
FORMAT=$2

if [ "$FILE" = "all" ] && [ "$FORMAT" = "book" ]; then
  echo "Rendering full book"
  cp _quarto_book.yml _quarto.yml
  quarto render
fi

if [ $FILE != "all" ] && [ "$FORMAT" = "book" ];  then
	echo "Rendering book chapter"
  cp _quarto_book.yml _quarto.yml
  quarto render "$FILE"
fi
 
if [ $FILE != "all" ] && [ "$FORMAT" = "slides" ];  then
	echo "Rendering standard slides"
  cp _quarto_slides.yml _quarto.yml
  quarto publish quarto-pub "$FILE" 
fi
 
if [ $FILE != "all" ] && [ "$FORMAT" = "wide_slides" ];  then
	echo "Rendering wide slides"
  cp _quarto_slides_wide.yml _quarto.yml
  quarto publish quarto-pub "$FILE" 
fi