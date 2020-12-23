#!/bin/bash
cd ~/workspace/config/

rm keys* *.png spl_*

egrep "^(bindsym|# CATEGORY)" ~/.config/i3/config | sed 's/# CATEGORY: \(.*\)/\n# CATEGORY: \1\n=====================================/g' | sed 's/bindsym//g' | sed "s/\"/\'/g" >> keys_in.txt

split -d -l 50 keys_in.txt spl_key

for f in spl_*; do
  sed -i '1s;^;text 25 0";' $f
  echo "\"" >> $f
  convert -size 500x1000 xc:"#212024" -font DejaVu-Sans -pointsize 12 -gravity West -fill white -draw @$f $f.png
done

convert spl_key*.png +append keys.png

feh -x --no-menus --on-last-slide quit --title "keys_i3_cheatsheet" keys.png

rm keys* *.png spl_*
