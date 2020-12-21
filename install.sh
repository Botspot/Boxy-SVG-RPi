#!/bin/bash

function error {
  echo -e "\\e[91m$1\\e[39m"
  exit 1
}

if [ ! -d ~/Boxy-SVG-RPi ];then
  echo "Downloading Boxy-SVG-RPi repo now..."
  git clone https://github.com/Botspot/Boxy-SVG-RPi || error "failed to git clone!"
  cd Boxy-SVG-RPi
  unzip ./boxysvgrpi.zip
  rm ./boxysvgrpi.zip
else
  cd ~/Boxy-SVG-RPi
fi

if [ ! -d ~/Boxy-SVG-RPi/boxysvgrpi ];then
  error "extraction failed somehow!"
fi

if command -v chromium-browser;then
  browser="$(command -v chromium-browser)"
elif command -v chromium;then
  browser="$(command -v chromium)"
else
  error "You must have Chromium Browser installed to use the Boxy SVG Chrome App!"
fi

pkill chromium
if [ -f "$HOME/.config/chromium/Default/Preferences" ] && [ "$(cat "$HOME/.config/chromium/Default/Preferences" | grep 'developer_mode":true')" ];then
  echo "It appears Developer Mode is already enabled in Chromium. Skipping tutorial."
else
  $browser &>/dev/null &
  
  sleep 5
  echo "Go to this URL in your browser:
  chrome:extensions" | yad --text-info \
    --image=$(pwd)/extensions.png --image-on-top \
    --button=Next:0 \
    --title="Step 1: go to chrome:extensions" \
    --width=400 --center --on-top || error "user exited step 1."
  
  echo "Now enable Developer Mode." | yad --text-info \
    --image=$(pwd)/dev_mode.png --image-on-top \
    --button=Done:0 \
    --title="Step 2: enable developer mode" \
    --width=400 --center --on-top || error "user exited step 2."
  pkill chromium
fi

$browser --load-and-launch-app=$(pwd)/boxysvgrpi &>/dev/null &

echo "Launching Boxy SVG Chrome App...
Closing in 20 seconds." | yad --text-info \
  --image=$(pwd)/boxy-window.png --image-on-top \
  --button=OK:0 \
  --title="Launching Boxy SVG" \
  --width=400 --center --on-top \
  --timeout=20 --timeout-indicator=bottom
pkill chromium
if [ -f ~/.local/share/applications/chrome-gaoogdonmngmdlbinmiclicjpbjhgomg-Default.desktop ];then
  echo "Boxy svg menu button found. Good."
  if [ -z "$(cat ~/.local/share/applications/chrome-gaoogdonmngmdlbinmiclicjpbjhgomg-Default.desktop | grep Graphics)" ];then
    echo "Moving menu button to the Graphics category..."
    echo "Categories=Graphics;" >> ~/.local/share/applications/chrome-gaoogdonmngmdlbinmiclicjpbjhgomg-Default.desktop
  fi
else
  error "Chromium did not create a menu button for Boxy SVG!
Please report this to Botspot."
fi
echo 'Done!'
