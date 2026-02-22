#!/bin/bash  

# ./render.sh FILE FORMAT
# FILE = all or filename
# FORMAT = book, slides, or slides_wide

FORMAT=$1
FILE=$2

if [ "$FORMAT" = "book" ]; then
  echo ""
  echo "Publishing all chapters to gh-pages"
  echo ""
  cp _quarto_book.yml _quarto.yml
  quarto publish gh-pages --no-browser 
  rm _quarto.yml
  rm -r _book
fi

if [ "$FORMAT" = "slides_local" ];  then
  echo ""
	echo "Publishing $FILE to standard slides locally"
  echo ""
  cp _quarto_slides.yml _quarto.yml
  quarto render "$FILE"
  cp _quarto_book.yml _quarto.yml
  quarto publish gh-pages --no-browser 
  rm -r _book
  rm _quarto.yml
  git add .
  git commit -m "render slides"
  git push
  mkdir ~/stage/
  cp -a *.html ~/stage/ 
  cp -ar *_files ~/stage/  
  cp -a uwlogo.png ~/stage/
  cp -a slides_teaching.css ~/stage/
  mkdir ~/tmp/
  cp -ar .Rproj.user ~/tmp/
  cp -a book_iaml.Rproj ~/tmp/
  git checkout gh-pages
  cp -ar ~/stage/. .
  rm -r ~/stage
  git add .
  git commit -m "publish slides"
  git push
  git checkout main
  cp -r ~/tmp/. .
  rm -r ~/tmp
  # rm -r *_files
  # rm *.html
fi

 
if [ "$FORMAT" = "slides" ];  then
  echo ""
	echo "Publishing $FILE to standard slides on quarto-pub"
  echo ""
  cp _quarto_slides.yml _quarto.yml
  quarto publish quarto-pub "$FILE" --no-browser
  rm _quarto.yml
  # rm -r *_files
  # rm *.html
fi
 
if [ "$FORMAT" = "slides_wide" ];  then
  echo ""
	echo "Publishing $FILE to wide slides on quarto-pub"
  echo ""
  cp _quarto_slides_wide.yml _quarto.yml
  quarto publish quarto-pub "$FILE" --no-browser
  rm _quarto.yml
  # rm -r *_files
  # rm *.html
fi


