#!/bin/bash
while getopts d: option
do
    case "${option}"
        in
        d) DIR=$OPTARG;;
    esac
done

## Check if there's network
function ping_gw() {
    ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && \
    return 0 || return 1
}

ping_gw || (echo "no network, bye" && exit 1)

subreddits=("wallpapers" "art" "iwallpaper")
selectedsubreddit=${subreddits[$RANDOM % ${#subreddits[@]} ]}

URLS=($(wget -O - http://www.reddit.com/r/$selectedsubreddit.rss | grep -Eo "https://?[^&]+jpg" | grep -v "thumbs"))
URL=${URLS[$RANDOM % ${#URLS[@]} ]}
NAME=$(basename "$URL");

if [ "$DIR" ]
then
    FILENAME="$DIR""$NAME";
else
    FILENAME=~/Pictures/"$NAME";
fi

## Check if file exists
if [ ! -f $FILENAME ]; then
    wget "$URL" -N -O "$FILENAME";
    sleep 1;
fi
gsettings set org.gnome.desktop.background picture-uri nothing;
gsettings set org.gnome.desktop.background picture-uri file://"$FILENAME";
