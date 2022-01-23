#!/bin/bash

system="`lsb_release -sd`"
system_release="`lsb_release -sr`"
system_architecture="`uname -m`"

echo "LINUX DEVELOPMENT SCRIPT (LinuxMint)"
echo "Author: 0jafc0"
echo "System: $system"
echo "Architecture: $system_architecture"
echo "Home: $HOME"
echo "User: $USER"
sudo echo -n "--------------"

# -------------- Lista --------------
PROGRAMAS_PARA_INSTALAR=(
    git
    python3
    docker
    docker-compose
    openjdk-8-jdk 
    openjdk-11-jdk
    maven
    postgresql
    pgadmin4
    brave-browser
    code
    zsh
)

# -------------- Funções --------------
printLinha() {
    text="$1"
  if [ ! -z "$text" ]
  then
    text="$text "
  fi
  length=${#text}
  sudo echo ""
  echo -n "$text"
  for i in {1..80}
  do
    if [ $i -gt $length ]
    then
      echo -n "="
    fi
  done
  echo ""
}

dpkgInstall() {
  file="$HOME/$1"
  wget -O "$file" "$2"
  sudo dpkg -i "$file"
  rm -fv "$file"
  sudo apt install -fy
}

installPostman() {
    file="$HOME/Postman"
    wget -O "$file" "$1"
    tar -xzf $file
    sudo mv $file /opt/
    sudo ln -s /opt/Postman/Postman /usr/local/bin/postman
    rm -fv "$file"
}

# Removendo travas
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/cache/apt/archives/lock

# Instalando pacotes necessarios
printLinha "Instalando pacotes necessarios"
sudo apt install apt-transport-https curl

# Adicionando chave de pacote do Brave
printLinha "Adicionando Pacote do Brave"
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

# Adicionando chave de pacote do Docker e Docker-composer
printLinha "Adicionando Pacote do Docker e Docker-composer"
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Adicionando chave de pacote do Code
printLinha "Adicionando Pacote do vscode"
curl -sSL https://packages.microsoft.com/keys/microsoft.asc -o microsoft.asc
gpg --no-default-keyring --keyring ./ms_signing_key_temp.gpg --import ./microsoft.asc
gpg --no-default-keyring --keyring ./ms_signing_key_temp.gpg --export > ./ms_signing_key.gpg
sudo mv ms_signing_key.gpg /etc/apt/trusted.gpg.d/

# Adicionando chave de pacote do Pgadmin4
printLinha "Adicionando Pacote do Pgadmin4"
sudo curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add
sudo sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/bionic pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'

# atualizando repositorios
printLinha "Update"
sudo apt update -y

# -------------- laço de instalação --------------
# Instalando programas pelo apt
for nome_programa in ${PROGRAMAS_PARA_INSTALAR[@]}; do
    if ! [ -x "$(command -v $nome_programa)" ]; then
        printLinha "[INSTALANDO...] $nome_programa"
        sudo apt install "$nome_programa" -y
    else
        echo "[INSTALADO]" - $nome_programa
    fi
done

# Instalando o IriunWebcam
dpkgInstall iriunwebcam https://iriun.gitlab.io/iriunwebcam-2.6.deb

# Instalando o Postman
printLinha "Instalando Postman"
if ! [ -d "/opt/Postman" ]; then
    printLinha "[INSTALANDO...] Postman"
    installPostman https://dl.pstmn.io/download/latest/linux64
    exit 1
else
    echo "[INSTALADO]" - Postman
fi


# Instalando o nvm(Node Version Manager)
printLinha "Instalando nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# Exportando variaveis
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

#instalando o Node
printLinha "Instalando o Nodejs"
nvm install --lts

# Instalando o Typescript
printLinha "Instalando Typescript"
npm install -g typescript

# Instalando o Angular
printLinha "Instalando Angular"
npm install -g @angular/cli

# Instalando o ohmyzsh
printLinha "Instalando ohmyzsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# configurando o oh-my-zsh
#sed -i "s|ZSH_THEME='spaceship'|ZSH_THEME='agnoster'|g" ~/.zshrc

# -------------- PÓS-INSTALAÇÃO --------------
## atualização e limpeza
sudo apt update -y
sudo apt upgrade -y
sudo apt autoclean -y
printLinha "Terminado"
echo "Por favor reinicie seu sistema."
