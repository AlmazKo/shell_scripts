#!/bin/bash -e
#
# author: Alexander Suslov

xconvert() {
  encode=`id3 -R -l "$*" | sed -n '/Title\|Artist\|Album/p' | enca -i -Lrussian`

  if [ "$encode" != "ASCII" ] && [ "$encode" != "UTF-8" ] && [ "$encode" != "???" ]; then 
    echo "FILE  :$*f"
    echo "ENCODE: $encode"
    echo "$*"
    mid3iconv -q -e $encode --remove-v1 "$*"
  fi

}

path="."

export -f xconvert

find $path -name '*.mp3' -type f -exec bash -c 'xconvert "{}"' \;
