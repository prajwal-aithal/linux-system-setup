#!/bin/bash
cd ~/workspace/config/

rm *.png spl_*

split -d -l 20 screens.txt spl_screen

for f in spl_*; do
  sed -i '1s;^;text 25 0 ";' $f
  echo "\"" >> $f
  convert -size 500x500 xc:"#212024" -font DejaVu-Sans -pointsize 14 -fill white -gravity West -draw @$f $f.png
done

convert spl_screen*.png +append screens.png

feh -x --no-menus --on-last-slide quit --title "screens_i3_cheatsheet" screens.png

rm *.png spl_*
