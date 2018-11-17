#!/bin/bash
cd ~

# Give step numbers
snumb=5

###############################################################
function ubuntu-install(){
# Get password
echo -n "[$(($snumb-4))/$snumb] Enter your user-with-sudo-rights password for one time: "; read -s PASSWD; echo;
# Check sudo rights
sudo -k
if sudo -lS &> /dev/null << EOF
$PASSWD
EOF
 then echo "[$(($snumb-4))/$snumb] Correct password. Go on.";
 else echo "[$(($snumb-4))/$snumb] Wrong password. Exit."; exit 1;
fi

echo "We will try $PKT_MGR as packet manager for install zsh"; echo;
echo; echo "[$(($snumb-3))/$snumb] $PKT_MGR install";
echo $PASSWD | sudo -S $PKT_MGR install -y zsh
echo; echo "[$(($snumb-3))/$snumb] wget oh-my-zsh";
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
echo; echo "[$(($snumb-3))/$snumb] change shell to zsh";
echo $PASSWD | chsh -s `which zsh`

while true; do
    read -p "[$(($snumb-3))/$snumb] Do you want to change root shell too? [y/N]: " yn
    case $yn in
        [yY] | [yY][Ee][Ss]  ) echo "[$(($snumb-3))/$snumb] sudo change root shell to zsh"; echo $PASSWD | sudo -S chsh -s `which zsh`; break;;
        [nN] | [n|N][O|o] | '' ) echo "[$(($snumb-3))/$snumb] root shell stays default"; break;;
        * ) echo "Please answer y[es] or N[o].";;
    esac
done

echo; echo "[$(($snumb-2))/$snumb] zshrc and theme";
wget -O /Users/$USER/.oh-my-zsh/custom/themes/fatllama.zsh-theme https://raw.githubusercontent.com/malltaf/zsh/master/fatllama.zsh-theme
wget -O /Users/$USER/.zshrc https://raw.githubusercontent.com/malltaf/zsh/master/.zshrc-linux

echo; echo "[$(($snumb-2))/$snumb] fast-syntax-highlighting";
git clone https://github.com/zdharma/fast-syntax-highlighting.git ${ZSH_CUSTOM:-/Users/$USER/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
echo; echo "[$(($snumb-2))/$snumb] history-substring-search";
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-/Users/$USER/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
echo; echo "[$(($snumb-2))/$snumb] zsh-autosuggestions";
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-/Users/$USER/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo; read -p "[$(($snumb-1))/$snumb] Enter your favorite theme [default is robbyrussell, recommended is fatllama]: " ZSH_DEFAULT_THEME;
ZSH_DEFAULT_THEME=${ZSH_DEFAULT_THEME:-robbyrussell}
echo "Theme you entered is $ZSH_DEFAULT_THEME"; echo;

# Get and export username and theme
sed -i "6s/^/export USER_ZSH=$(echo $USER)/" /home/$USER/.zshrc
sed -i "7s/^/export ZSH_DEFAULT_THEME=$(echo $ZSH_DEFAULT_THEME)/" /home/$USER/.zshrc

echo; read -p "[$snumb/$snumb] Press ANYKEY to finish. Start the new session to changes to take effect.";
}

###############################################################
function mac-install(){
cd /usr/local/Cellar
mkdir zsh zsh-completions 2> /dev/null
cd ~
echo; echo "[$(($snumb-3))/$snumb] make chown for brew (/usr/local/Cellar/zsh*)";
chown -R $(whoami):admin /usr/local/Cellar/zsh*
echo; echo "[$(($snumb-3))/$snumb] $PKT_MGR install";
$PKT_MGR install -y zsh zsh-completions
echo; echo "[$(($snumb-3))/$snumb] change shell to brew zsh";
dscl . -create /Users/$USER UserShell `which zsh`

echo; echo "[$(($snumb-3))/$snumb] wget oh-my-zsh";
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh 

echo; echo "[$(($snumb-2))/$snumb] zshrc and theme";
wget -O /Users/$USER/.oh-my-zsh/custom/themes/fatllama.zsh-theme https://raw.githubusercontent.com/malltaf/zsh/master/fatllama.zsh-theme
wget -O /Users/$USER/.zshrc https://raw.githubusercontent.com/malltaf/zsh/master/.zshrc-mac

echo; echo "[$(($snumb-2))/$snumb] fast-syntax-highlighting";
git clone https://github.com/zdharma/fast-syntax-highlighting.git ${ZSH_CUSTOM:-/Users/$USER/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
echo; echo "[$(($snumb-2))/$snumb] history-substring-search";
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-/Users/$USER/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
echo; echo "[$(($snumb-2))/$snumb] zsh-autosuggestions";
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-/Users/$USER/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo; read -p "[$(($snumb-1))/$snumb] Enter your favorite theme [default is robbyrussell, recommended is fatllama]: " ZSH_DEFAULT_THEME;
ZSH_DEFAULT_THEME=${ZSH_DEFAULT_THEME:-robbyrussell}
echo "Theme you entered is $ZSH_DEFAULT_THEME"; echo;

# Get and export username and theme
sed -i.tmp "6s/^/export USER_ZSH=$(echo $USER)/" /Users/$USER/.zshrc
sed -i.tmp "7s/^/export ZSH_DEFAULT_THEME=$(echo $ZSH_DEFAULT_THEME)/" /Users/$USER/.zshrc
rm -rf /Users/$USER/.zshrc.tmp

echo; read -p "[$snumb/$snumb] Press ANYKEY to finish. Start the new session to changes to take effect.";
}



# Determine OS platform
UNAME=$(uname | tr "[:upper:]" "[:lower:]")
# If Linux, try to determine specific distribution
if [ "$UNAME" == "linux" ]; then
    # If available, use LSB to identify distribution
    if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
        export DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
    # Otherwise, use release info file
    else
        export DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
    fi
fi
# For everything else (or if above failed), just use generic identifier
[ "$DISTRO" == "" ] && export DISTRO=$UNAME
unset UNAME

# Installation process
echo "You use $DISTRO distribution"; echo -n "We will try "
case "$DISTRO" in
    "darwin" ) PKT_MGR="brew"; echo -n "$PKT_MGR as packet manager for install zsh"; echo; mac-install;;
    "ubuntu" | "Ubuntu" ) PKT_MGR="apt-get"; echo -n "$PKT_MGR as packet manager for install zsh"; echo; ubuntu-install;;
    "centos" ) PKT_MGR="yum"; echo -n "$PKT_MGR as packet manager for install zsh"; echo; linux-install;; ################################################
    * ) echo "Unknown OS, exit."; exit 1;;
esac
unset DISTRO