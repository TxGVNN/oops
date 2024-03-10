[![Release image](https://github.com/TxGVNN/oops/workflows/Release%20image/badge.svg)](https://github.com/TxGVNN/oops/actions/workflows/docker-publish.yml)
[![Build pack](https://github.com/TxGVNN/oops/workflows/Build%20pack/badge.svg)](https://github.com/TxGVNN/oops/actions/workflows/pack.yml)
# What's wrong?
This repository provides a unified development environment that I need. Almost is Emacs!

# Usage
## Bare metal
- Get this package
```sh
wget https://txgvnn.github.io/oops/guix.tar.xz -P ~/

```
- Setup `.bashrc`
```sh
cat >> ~/.bashrc << EOF
if [ ! -d /gnu ]; then
    echo "Setup Guix..."
    sudo tar -xf ~/guix.tar.xz -C /
    ln -svf \$(ls -d /gnu/store/*profile) ~/.guix-profile
    ~/.guix-profile/bin/oops-link
fi
export GUIX_PROFILE=~/.guix-profile
if [ -e \${GUIX_PROFILE}/etc/profile ]; then
    source \${GUIX_PROFILE}/etc/profile
fi
export GUIX_LOCPATH=\${GUIX_PROFILE}/lib/locale
if type -p direnv &>/dev/null; then
    eval "\$(direnv hook bash)"
fi
EOF

```
## Github Codespaces
[![Open in Codespaces](https://img.shields.io/badge/Open%20in%20Codespaces-0b8ca5)](https://github.com/codespaces/new?hide_repo_select=false&ref=develop&repo=429365535&skip_quickstart=true)


## Gitpod.io
[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/TxGVNN/oops)
