#!/bin/bash

system="`lsb_release -sd`"
system_release="`lsb_release -sr`"
system_architecture="`uname -m`"

echo "LINUX DEVELOPMENT SCRIPT (for systems based on debian)"
echo "Author: 0jafc0"
echo "System: $system"
echo "System release: $system_release"
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
  openjdk-8-jdk
  openjdk-8-jre
  openjdk-11-jdk
  openjdk-11-jre
  maven
  postgresql
  mysql-server
  dbeaver-ce
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
    file="./Postman"
    wget -O "$file" "$1"
    tar -xzf $file
    sudo mv $file /opt/
    sudo ln -s /opt/Postman/app/Postman /usr/local/bin/postman
    rm -fv "$file"
}

# Removendo travas
printLinha "Removendo travas"
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/cache/apt/archives/lock

# Instalando pacotes necessarios
printLinha "Instalando pacotes necessarios"
sudo apt install apt-transport-https curl

# Adicionando chave de pacote do Brave
printLinha "Adicionando Pacote do Brave"
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list

# Adicionando chave de pacote do Docker e Docker-composer
printLinha "Adicionando Pacote do Docker e Docker-composer"
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Adicionando chave de pacote do Code
printLinha "Adicionando Pacote do vscode"
wget -O- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/vscode.gpg -y
echo deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/vscode stable main | sudo tee /etc/apt/sources.list.d/vscode.list -y

# Adicionando pacote do postgresql
printLinha "Adicionando pacote do postgresql"
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Adicionando pacote dbeaver
printLinha "Adicionando pacote dbeaver"
curl -fsSL https://dbeaver.io/debs/dbeaver.gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/dbeaver.gpg -y
echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list -y

# atualizando repositorios
printLinha "Update"
sudo apt update -y

# -------------- laço de instalação --------------
# Instalando programas pelo apt
for nome_programa in "${PROGRAMAS_PARA_INSTALAR[@]}"; do
    if ! [ -x "$(command -v $nome_programa)" ]; then
        printLinha "[INSTALANDO...] $nome_programa"
        sudo apt install "$nome_programa" -y
    else
        echo "[INSTALADO]" - $nome_programa
    fi
done

# selecionando zsh como padrao
printLinha "selecionando zsh como padrao"
sudo chsh -s $(which zsh) -y

# Instalando o droidCam
printLinha "Instalando DroidCam"
cd /tmp/
wget -O droidcam_latest.zip https://files.dev47apps.net/linux/droidcam_1.8.2.zip

unzip droidcam_latest.zip -d droidcam
cd droidcam && sudo ./install-client

sudo apt install -y "https://files.dev47apps.net/linux/libindicator3-7_0.5.0-4_amd64.deb"

# Instalando o Postman
printLinha "Instalando Postman"
if ! [ -d "/opt/Postman" ]; then
    printLinha "[INSTALANDO...] Postman"
    installPostman https://dl.pstmn.io/download/latest/linux64
    exit 1
else
    echo "[INSTALADO]" - Postman
fi

# Instalando
printLinha "[INSTALANDO...] docker desktop"
sudo apt install -y "https://desktop.docker.com/linux/main/amd64/docker-desktop-4.13.1-amd64.deb?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-linux-amd64"

# Instalando o nvm(Node Version Manager)
printLinha "Instalando nvm"
curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh" | bash

# Exportando variaveis
printLinha "Exportando variaveis"
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

#instalando o Node
printLinha "Instalando o Nodejs"
nvm install --lts

# Instalando o Typescript
printLinha "Instalando Typescript"
npm install -g typescript -y

# Instalando o Angular
printLinha "Instalando Angular"
npm install -g @angular/cli -y

# Instalando o angular cli ghpages
printLinha "Instalando Angular/cli ghpages"
npm install -g angular-cli-ghpages -y

# Instalando o ohmyzsh
printLinha "Instalando ohmyzsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" -y

# Instalando o tema
printLinha "Clonando tema"
git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

# Instalando o ZSH Syntax Highlighting
printLinha "Clonando syntax highlighting"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Instalando o
printLinha "Clonando autosuggestions"
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

# configurando o oh-my-zsh
printLinha "Configurando o oh-my-zsh"
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="spaceship"/g' ~/.zshrc
sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/g' ~/.zshrc

# criando perfis vscode
printLinha "criando perfis vscode"
mkdir -p code_profiles/java/{exts,data}
mkdir -p code_profiles/angular/{exts,data}
mkdir -p code_profiles/python/{exts,data}
mkdir -p code_profiles/react/{exts,data}

# Criando variavel de ambiente para os perfis
printLinha "Criando variavel de ambiente para os perfis"
alias code-java="code --extensions-dir ~/code_profiles/java/exts --user-data-dir ~/code_profiles/java/data"
alias code-angular="code --extensions-dir ~/code_profiles/angular/exts --user-data-dir ~/code_profiles/angular/data"
alias code-python="code --extensions-dir ~/code_profiles/python/exts --user-data-dir ~/code_profiles/python/data"
alias code-react="code --extensions-dir ~/code_profiles/react/exts --user-data-dir ~/code_profiles/react/data"

# -------------- PÓS-INSTALAÇÃO --------------
## atualização e limpeza
sudo apt update -y
sudo apt upgrade -y
sudo apt autoclean -y
printLinha "Terminado"
echo "Por favor reinicie seu sistema."
