#! /bin/bash


aurdir=~/aur-builds

echo "create directories"
mkdir -p ~/.ssh 
mkdir -p ~/downloads 
mkdir -p ~/google-drive
sudo mkdir -p /media/data

echo "install fonts"
sudo pacman -S --noconfirm noto-fonts noto-fonts-extra ttf-font-awesome

echo "install python"
sudo pacman -S --noconfirm python3 python-pip ipython python-virtualenv flake8

echo "install window manager"
sudo pacman -S --noconfirm i3-gaps compton dunst rofi feh

echo "install tools"
sudo pacman -S --noconfirm wget tree openvpn openssh git ntfs-3g xclip

echo "install applications"
sudo pacman -S --noconfirm ranger htop termite neovim python-neovim tig  \
                           zathura zathura-pdf-poppler firefox keepassx2 \
                           telegram-desktop newsboat

echo "prepare directory for [aur]"
mkdir -p $aurdir && rm -rf $aurdir/*


echo "install vscode [aur]"
cd $aurdir
git clone https://aur.archlinux.org/visual-studio-code-bin.git
cd visual-studio-code-bin
makepkg -sri --noconfirm


echo "install skype"
cd $aurdir
git clone https://aur.archlinux.org/skypeforlinux-stable-bin.git
cd skypeforlinux-stable-bin
makepkg -sri --nocnofirm


echo "install polybar deps"
sudo pacman -S jsoncpp

echo "install polybar [aur]"
cd $aurdir
git clone https://aur.archlinux.org/polybar.git
cd polybar
makepkg -sri --noconfirm


echo "instal grive deps"
sudo pacman -S inotify-tools

echo "install grive"
cd $aurdir
git clone https://aur.archlinux.org/grive.git
cd grive
makepkg -sri --noconfirm


echo "install rider deps"
sudo pacman -S mono dotnet-sdk

echo "install rider [aur]"
cd $aurdir
git clone https://aur.archlinux.org/rider.git
cd rider
makepkg -sri --noconfirm


echo "completed :)"

