#!/bin/bash
# @
# devsoftprog.bash.screen.menu
# @
#
# alias brig=<?...>
# alias wifi=<?...>
# alias all=<?...>
# alias off=<?...>
xrandr --output LVDS1 --scale 1.05x1.0
xrandr --output LVDS1 --scale 1.05x1.0 --panning 1024x600
alias bat='upower -i /org/freedesktop/UPower/devices/battery_BAT1'
alias b='sensors | grep -vi virtu && bat | grep rate | grep -v His && bat | grep time && bat | grep percent && bat | grep state'
shopt -s expand_aliases
screen bash -ci "brig"
xmodmap ~/.Xmodmap
echo "bem-vindo"
echo "[ menu-screen-bash ]"
b;
echo "-= off? =-"
read -e -p "> " a; if [ "$a" == "y" ]; then screen bash -ci "off"; fi
echo "-= mount filesystems? =-"
read -e -p "> " a; if [ "$a" == "" ]; then screen bash -ci "all"; fi
#screen bash -ci dmesg | tail | less;
df -h;
echo "-= connect wifi? =-"
read -e -p "> " a; if [ "$a" == "" ]; then screen bash -ci "wifi"; fi
echo "done"
echo "bye"
read bye
exit 0

