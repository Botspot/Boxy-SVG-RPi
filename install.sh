#!/bin/bash

function error {
  echo -e "\\e[91m$1\\e[39m"
  exit 1
}

if ! command -v yad &>/dev/null ;then
  echo "Installing yad..."
  sudo apt install -y yad
  if ! command -v yad &>/dev/null ;then
    error "YAD failed to install somehow!"
  fi
fi

if ! command -v git &>/dev/null ;then
  echo "Installing git..."
  sudo apt install -y git
  if ! command -v git &>/dev/null ;then
    error "git failed to install somehow!"
  fi
fi

if [ ! -d ~/Boxy-SVG-RPi ];then
  echo "Downloading Boxy-SVG-RPi repo now..."
  git clone https://github.com/Botspot/Boxy-SVG-RPi || error "failed to git clone!"
  cd Boxy-SVG-RPi
  unzip ./boxysvgrpi.zip >/dev/null
  rm ./boxysvgrpi.zip
else
  cd ~/Boxy-SVG-RPi
fi

if [ ! -d ~/Boxy-SVG-RPi/boxysvgrpi ];then
  error "extraction failed somehow!"
fi

if command -v chromium-browser &>/dev/null;then
  browser="$(command -v chromium-browser)"
elif command -v chromium &>/dev/null;then
  browser="$(command -v chromium)"
else
  error "User error: You must have Chromium Browser installed to use the Boxy SVG Chrome App!"
fi

#make chromium config with boxy svg pre-installed
rm -rf ~/.config/BoxySVG
mkdir -p ~/.config/BoxySVG/Default
cp ./Preferences ~/.config/BoxySVG/Default/Preferences
echo '' > ~/'.config/BoxySVG/First Run'
sed -i "s+/home/pi+$HOME+g" ~/.config/BoxySVG/Default/Preferences

#icons
mkdir -p ~/.local/share/icons/hicolor
cp -a ./icons/. ~/.local/share/icons/hicolor

#menu button
rm -f ~/.local/share/applications/*gaoogdonmngmdlbinmiclicjpbjhgomg*
mkdir -p ~/.local/share/applications
#create menu launcher
echo "#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Terminal=false
Type=Application
Name=Boxy SVG
Exec=$browser --user-data-dir=$HOME/.config/BoxySVG --profile-directory=Default --app-id=gaoogdonmngmdlbinmiclicjpbjhgomg %f
Icon=chrome-gaoogdonmngmdlbinmiclicjpbjhgomg-Boxysvg
StartupWMClass=crx_gaoogdonmngmdlbinmiclicjpbjhgomg
Categories=Graphics;
MimeType=image/svg+xml;
StartupNotify=true" >> ~/.local/share/applications/chrome-gaoogdonmngmdlbinmiclicjpbjhgomg-Boxysvg.desktop

if [ -z "$(cat ~/.config/mimeapps.list | grep 'gaoogdonmngmdlbinmiclicjpbjhgomg-Boxysvg')" ];then
  echo "Associating the SVG mimetype with Boxy SVG..."
  echo "[Added Associations]
image/svg+xml=chrome-gaoogdonmngmdlbinmiclicjpbjhgomg-Boxysvg.desktop;" >> ~/.config/mimeapps.list
fi

echo 'Done!'
