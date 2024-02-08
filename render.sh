#!/bin/bash  

FILE=$1
FORMAT=$2

if [ "$FORMAT" = "book" ]  then     
	echo "Rendering book"
fi

if [ "$FORMAT" = "slides" ]  then     
	echo "Rendering standard slides"
fi

if [ "$FORMAT" = "wide_slides" ]  then     
	echo "Rendering wide slides"
fi