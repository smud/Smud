# Compiling Smud on Ubuntu 16.04

Install swiftenv:

```
sudo apt-get install git
git clone https://github.com/kylef/swiftenv.git ~/.swiftenv
echo 'export SWIFTENV_ROOT="$HOME/.swiftenv"' >> ~/.bashrc
echo 'export PATH="$SWIFTENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(swiftenv init -)"' >> ~/.bashrc
```

Install Swift and it's dependencies:

```
sudo apt-get install clang
swiftenv install swift-DEVELOPMENT-SNAPSHOT-2016-07-25-a
#swiftenv install https://swift.org/builds/swift-3.0-preview-2/ubuntu1510/swift-3.0-PREVIEW-2/swift-3.0-PREVIEW-2-ubuntu15.10.tar.gz
```

Download and compile Smud:

```
sudo apt-get install binutils make libevent-dev
git clone https://github.com/smud/Smud.git
cd Smud
make fetch-master
make
```

## VIM

Optionally, configure vim for Swift:

Install plug-vim plugin manager:
```
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

Add to ~/.vimrc:
```
call plug#begin('~/.vim/plugged')
Plug 'https://github.com/keith/swift.vim.git'
call plug#end()
```

Reload .vimrc and :PlugInstall to install plugins.

## Ctags

To use `ctags` with Swift CoreFoundation classes, download swift-corelibs-foundation repo and put it next to Smud/ directory:
```
cd ..
git clone https://github.com/apple/swift-corelibs-foundation.git
cd swift-corelibs-foundation
git checkout swift-DEVELOPMENT-SNAPSHOT-2016-07-25-a
```

Rebuild tags:
```
cd ../Smud
make tags
```

Now press CTRL-] in VIM to go to the method definition.
Alternatively, press 'g' then ']' to choose from multiple overloads.


