#! /usr/bin/env bash
# -------------- variaveis --------------
PROGRAMAS_PARA_INSTALAR_SNAP=(
    brave
    typora
    postman
)

PROGRAMAS_PARA_INSTALAR=(
    python3
    docker
    maven
    postgresql
    discord
    gimp
    code
    okular
)

# removendo travas
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/cache/apt/archives/lock

# atualizando repositorios
sudo pacman -Syyu

# instalando o snapd
git clone https://aur.archlinux.org/snapd.git
cd snapd
makepkg -si
rm -r snapd

sudo systemctl enable --now snapd.socket
sudo ln -s /var/lib/snapd/snap /snap

# -------------- laços de instalação --------------
# Instalando programas pelo pacman
for nome_programa in ${PROGRAMAS_PARA_INSTALAR[@]}; do
    if ! dpkg -1 | grep -q $nome_programa; then
        sudo pacman -S "$nome_programa"
    else
        echo "[INSTALADO]" - $nome_programa
    fi
done

# Instalando programas pelo snap
for nome_programa in ${PROGRAMAS_PARA_INSTALAR_SNAP[@]}; do
    
    if [ $nome_programa == code ]; then
        sudo snap install "$nome_programa" --classic
    elif [ ! dpkg -l | grep -q $nome_programa ]; then
        sudo snap install "$nome_programa"
    else
        echo "[INSTALADO] - $nome_programa"
    fi
done

# Instalando o IriunWebcam
git clone https://aur.archlinux.org/iriunwebcam-bin.git
cd iriunwebcam-bin
makepkg -si
rm -r iriunwebcam-bin
cd
# Instalando o JDK 8 e o JDK 11
git clone https://aur.archlinux.org/jdk8.git
cd jdk8
makepkg -si
rm -r jdk8
cd
git clone https://aur.archlinux.org/jdk11.git
cd jdk11
makepkg -si
rm -r jdk11

# -------------- PÓS-INSTALAÇÃO --------------
## atualização e limpeza##
sudo pacman -Syyu
sudo pacman -Rs