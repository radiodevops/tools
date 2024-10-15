# tools

```bash
#!/usr/bin/env bash

FONT=JetBrainsMono.zip
K9S=k9s_linux_amd64.rpm

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/${FONT}
sudo unzip JetBrainsMono.zip -d /usr/share/fonts/
fc-cache -fv
rm -rf $FONT

wget https://github.com/derailed/k9s/releases/download/v0.32.5/${K9S}
sudo yum install ./${K9S}
rm -rf $K9S

sudo curl -sS https://starship.rs/install.sh | sh

echo 'eval "$(starship init bash)"' >> ~/.bashrc

starship preset nerd-font-symbols -o ~/.config/starship.toml
rm -rf install.sh


sudo hostnamectl set-hostname dev
source ~/.bash_profile
```
