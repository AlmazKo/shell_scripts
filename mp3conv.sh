#!/bin/bash -e
#
# author: Alexander Suslov



idmp3convert() {
  encode=`id3v2 -R -l "$*" | sed -n '/^Title\|^Artist\|^Album\|^[A-Z][A-Z0-9][A-Z0-9]:/p' | enca -i -Lrussian`

  if [ "$encode" != "ASCII" ] && [ "$encode" != "UTF-8" ] && [ "$encode" != "???" ]; then 
    echo "FILE  :$*"
    echo "ENCODE: $encode"
    mid3iconv -q -e $encode --remove-v1 "$*"
  fi

}

path="."

export -f idmp3convert

find $path -name '*.mp3' -type f -exec bash -c 'idmp3convert "{}"' \;