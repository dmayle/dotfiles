Installation:

```
# In process of moving towards a Git Strap version that autoinstalls
git clone git@github.com:dmayle/dotfiles.git ~/.dotfiles
```

Create symlinks:

```
ln -s .dotfiles/vim ~/.vim
ln -s .dotfiles/bash/bashrc ~/.bashrc
ln -s .dotfiles/bash/bashrc ~/.bash_profile
ln -s .dotfiles/bash/aliases ~/.bash_aliases
ln -s .dotfiles/inputrc ~/.inputrc
ln -s .dotfiles/editrc ~/.editrc
ln -s .dotfiles/crontab ~/.crontab
ln -s .dotfiles/tmux/outer.conf ~/.tmux-outer.conf
ln -s .dotfiles/tmux/shared.conf ~/.tmux-shared.conf
ln -s .dotfiles/tmux/inner.conf ~/.tmux-inner.conf
ln -s .vim/vimrc ~/.vimrc
```

Switch to the `~/.dotfiles` directory, and fetch submodules:

```
cd ~/.dotfiles
git submodule update --init
```

Tell crontab to import our self-updating, version-controlled crontab

```
crontab ~/.crontab
```
