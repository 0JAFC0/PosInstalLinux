#! /usr/bin/env bash
# -------------- variaveis --------------
system_release=$(cat -A /etc/fedora-release)
system_architecture="$(uname -m)"

echo "LINUX DEVELOPMENT SCRIPT (Fedora)"
echo "Author: 0jafc0"
echo "System: $system_release"
echo "Architecture: $system_architecture"
echo "Home: $HOME"
echo "User: $USER"
sudo echo -n "--------------"

# -------------- Lista --------------
PROGRAMAS_PARA_INSTALAR=(
  git
  python3
  python3-pip
  docker-ce
  docker-ce-cli
  containerd.io
  docker-compose-plugin
  java-1.8.0-openjdk
  java-1.8.0-openjdk-devel
  java-1.8.0-openjdk-headless
  java-11-openjdk
  java-11-openjdk-devel
  java-11-openjdk-headless
  maven
  postgresql-server
  postgresql-contrib
  community-mysql-server
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
    if [ "$i" -gt "$length" ]
    then
      echo -n "="
    fi
  done
  echo ""
}

# Removendo travas
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/cache/apt/archives/lock

# -------------- upgrade no sistema --------------
$ sudo dnf upgrade --refresh -y

# -------------- adicionando pacotes uteis --------------
sudo dnf install \
https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

sudo dnf install dnf-plugins-core -y

# Adicionando chave de pacote do Brave
printf "Adicionando Pacote do Brave"
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

# Adicionando chave de pacote do Docker e Docker-composer
printf "Adicionando Pacote do Docker e Docker-composer"
sudo dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo

# Baixando docker desktop
printf "Baixando docker desktop e instalando"
wget -o docker-desktop.rpm https://desktop.docker.com/linux/main/amd64/docker-desktop-4.13.1-x86_64.rpm?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-linux-amd64
./docker-desktop.rpm

# Baixando dockerCredential
printf "Baixando dockerCredential"
wget https://github.com/docker/docker-credential-helpers/releases/download/v0.6.0/docker-credential-pass-v0.6.0-amd64.tar.gz && tar -xf docker-credential-pass-v0.6.0-amd64.tar.gz && chmod +x docker-credential-pass && sudo mv docker-credential-pass /usr/local/bin/

gpg2 --gen-key
pass init "0jafc0"
sed -i '0,/{/s/{/{\n\t"credsStore": "pass",/' ~/.docker/config.json
docker login

#habilitando modulo postgresl 14
sudo dnf module enable postgresql:14 -y 

# Adicionando chave do repositorio do vsCode
printf "Adicionando Pacote do vscode"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

printf "[vscode]\nname=packages.microsoft.com\nbaseurl=https://packages.microsoft.com/yumrepos/vscode/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\nmetadata_expire=1h" | sudo tee -a /etc/yum.repos.d/vscode.repo

# atualizando repositorios
printf "Update"
sudo dnf update -y

# -------------- laço de instalação --------------
# Instalando programas pelo dnf
for nome_programa in "${PROGRAMAS_PARA_INSTALAR[@]}"; do
    if ! [ -x "$(command -v "$nome_programa")" ]; then
        printLinha "[INSTALANDO...] $nome_programa"
        sudo dnf install "$nome_programa" -y
    else
        echo "[INSTALADO]" - "$nome_programa"
    fi
done

# Instalando
printLinha "[INSTALANDO...] docker desktop"
sudo dnf install -y https://desktop.docker.com/linux/main/amd64/docker-desktop-4.10.1-x86_64.rpm

# habilitando docker
printf "iniciando docker"
sudo systemctl start docker

# Instalando pacote dbeaver
sudo yum -y install wget
wget https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm

# habilitando postgresql
sudo postgresql-setup initdb
sudo /usr/pgsql-14/bin/postgresql-14-setup initdb
sudo systemctl enable postgresql-14
sudo systemctl start postgresql-14

# Instalando o nvm(Node Version Manager)
printf "Instalando nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# Exportando variaveis
NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ]
export NVM_DIR && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

#instalando o Node
printf "Instalando o Nodejs"
nvm install --lts

# Instalando o Typescript
printf "Instalando Typescript"
npm install -g typescript

# Instalando o Angular
printf "Instalando Angular"
npm install -g @angular/cli

# Instalando o angular cli ghpages
printf "Instalando Angular/cli ghpages"
npm install -g angular-cli-ghpages

# Instalando o ohmyzsh
printf "Instalando ohmyzsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" -y

# configurando o oh-my-zsh
#sed -i "s|ZSH_THEME='spaceship'|ZSH_THEME='agnoster'|g" ~/.zshrc

# -------------- PÓS-INSTALAÇÃO --------------
## atualização e limpeza
sudo dnf update -y
sudo dnf upgrade -y
sudo dnf autoremove -y
printLinha "Terminado"
echo "Por favor reinicie o sistema."
