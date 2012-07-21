#!/bin/bash -e
#
# author: Alexander Suslov
# dependencies: jhead, imagemagick

processing() {
  local pic_name="${*##*/}"
  local big_pic="$pic_big_path/$pic_name"
  local thumb_pic="$pic_thumb_path/$pic_name"
  local usual_pic="$pic_path_usual/$pic_name"

  jhead -autorot "$*"
  convert  -resize '1024x' "$*" "$usual_pic"
  convert  -resize '60x' "$*" "$thumb_pic"


  if [ -s data.js ]; then
    printf "," >> data.js
  else
    printf " var data = [" > data.js
  fi ;

  printf "{
    image: \"%s\",
    thumb: \"%s\",
    big: \"%s\"
  }
  " $usual_pic $thumb_pic $big_pic >> data.js
}

pic_big_path="pic"
pic_thumb_path="$pic_big_path/thumb"
pic_path_usual="$pic_big_path/usual"


if [ -d $pic_thumb_path ]; then
  thumbs="$pic_thumb_path/*"
  rm -fr $thumbs
else
    mkdir -p $pic_thumb_path
fi ;

if [ -d $pic_path_usual ]; then
  usuals="$pic_path_usual/*"
  rm -fr $usuals
else
    mkdir -p $pic_path_usual
fi ;

> data.js


pic_path="pic"

for file in $(find $pic_path -type f -iregex  ".*.\(jpg\|png\|gif\)+" | sort)
do
   echo "${file}"
   processing "$file"
done

printf "];" >> data.js

echo "waiting ..."
wait