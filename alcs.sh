#!/usr/bin/env bash

set -u

LATEX='platex'
DVIPDF='dvipdfmx'
PDF_VIEWER="evince"

if [ ! $# -eq 1 ] && [ ! $# -eq 2 ]; then
    echo "Usage: $0 <file name> [false]"
    exit 1
fi

if [ ! -e "$1" ]; then
    echo "File not found."
    exit 1
fi

if [ $# -eq 2 ] && [ ! "$2" = "false" ] && [ ! "$2" = "f" ]; then
    FLAG=true
else
    FLAG=false
fi

TIMESTAMP1=""
TIMESTAMP2=""

function compile() {
    NO_NEED="${1%.*}.aux ${1%.*}.dvi ${1%.*}.log"
    DVI="${1%.*}.dvi"
    PDF="${1%.*}.pdf"
    $LATEX $1 && $DVIPDF $DVI
    if ( $2 ); then
        $PDF_VIEWER $PDF &
    fi
    for file in $NO_NEED; do
        if [ -e $file ]; then
            rm $file
        fi
    done
}

function check_timestamp() {
    TIMESTAMP2=`\ls --full-time | awk /"$1"/'{print $7}'`
}

while true; do
    check_timestamp $1
    if [ ! "$TIMESTAMP1" = "$TIMESTAMP2" ]; then
        yes x | compile $1 $FLAG
        TIMESTAMP1=$TIMESTAMP2
    fi
done
