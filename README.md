# tools

```bash
#!/usr/bin/env bash

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip
sudo unzip JetBrainsMono.zip -d /usr/share/fonts/
fc-cache -fv

wget https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_linux_amd64.rpm
sudo yum install ./k9s_linux_amd64.rpm -y

rm -rf k9s_linux_amd64.rpm

sudo curl -sS https://starship.rs/install.sh | sh

echo 'eval "$(starship init bash)"' >> ~/.bashrc

starship preset nerd-font-symbols -o ~/.config/starship.toml



sudo hostnamectl set-hostname dev
source ~/.bash_profile
```
