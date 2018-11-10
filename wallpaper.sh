#!/bin/bash

## Check if there's network
function ping_gw() {
    ping -q -w 1 -c 1 "imgur.com" > /dev/null && \
    return 0 || return 1
}

## Get a list of pictures from subreddits
function get_pics_list() {
    URLS=()
    for sub in "$@"
    do
        URLS+=($(wget -q -O- http://www.reddit.com/r/$sub.rss | grep -Eo "https://?[^&]+(jpg|png)" | grep -v "thumbs"))
    done
}

## Download a picture from the list of pictures
function get_pic() {
    URL=${URLS[$RANDOM % ${#URLS[@]}]}
    NAME=$(basename "$URL");
    if [ "$DIR" ]
    then
        FILENAME="$DIR""$NAME";
    else
        FILENAME=~/Pictures/"$NAME";
    fi
    
    ## Check if file exists
    if [ ! -f "$FILENAME" ]; then
        wget "$URL" -q -O "$FILENAME";
        sleep 1;
    fi
    SIZE=$(identify -format "%W:%H" "$FILENAME" | awk -F ':' 'END{if ($1 > 1920 && $1/$2>1.5) {print "WIDE"} else {print "HIGH"}}')
}

## Find a picture based on filter
function get_bg_image() {
    ping_gw || (echo "no network, bye" && exit 1)
    
    get_pics_list "wallpapers" "art" "iwallpaper"
    
    while [[ "$SIZE" != "WIDE" ]]
    do
        get_pic
    done
}

## Set wallpaper
function set_wallpaper() {
    gsettings set org.gnome.desktop.background picture-uri nothing;
    gsettings set org.gnome.desktop.background picture-uri file://"$FILENAME";
}

while getopts d: option
do
    case "${option}"
        in
        d) DIR=$OPTARG;;
        *) echo "What?" && exit 1;;
    esac
done

get_bg_image
set_wallpaper
