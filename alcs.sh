#!/usr/bin/env bash

set -u

LATEX='xelatex'

if [ ! $# -eq 1 ]; then
    echo "Usage: $0 [file name]"
    exit 1
fi

if [ ! -e "$1" ]; then
    echo "File not found."
    exit 1
fi

TIMESTAMP1=0
TIMESTAMP2=1

# for xelatex and MuPDF
function compile() {
    PDF="${1%.*}.pdf"
    NO_NEED="${1%.*}.aux ${1%.*}.log"

    # compile
    $LATEX $1
    $LATEX $1

    # refresh mupdf
    pkill -HUP mupdf

    # remove dumb files
    for file in $NO_NEED; do
        if [ -e $file ]; then
            rm $file
        fi
    done
}

while true; do
    # check timestamp
    TIMESTAMP2=`stat -c %Y $1`

    # compile when timestamp is updated
    if [ ! "$TIMESTAMP1" = "$TIMESTAMP2" ]; then
        yes x | compile $1
        TIMESTAMP1=$TIMESTAMP2
    fi
done
