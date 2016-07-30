# Compiling Smud on Ubuntu 14.04

## swiftenv

Install swiftenv:

```
sudo apt-get install git
git clone https://github.com/kylef/swiftenv.git ~/.swiftenv
echo 'export SWIFTENV_ROOT="$HOME/.swiftenv"' >> ~/.bashrc
echo 'export PATH="$SWIFTENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(swiftenv init -)"' >> ~/.bashrc
```

## Swift

Install Swift and it's dependencies:

```
sudo apt-get install clang
swiftenv install swift-DEVELOPMENT-SNAPSHOT-2016-07-25-a
```

## libdispatch

For building libdispatch clang 3.8+ is required.

```
sudo apt-get install clang-3.8 lldb-3.8
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.8 100
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.8 100
```

Build and install libdispatch:

```
sudo apt-get install autoconf libtool libkqueue-dev libkqueue0 libcurl4-openssl-dev libbsd-dev libblocksruntime-dev
export SWIFT_HOME=~/.swiftenv/versions/DEVELOPMENT-SNAPSHOT-2016-07-25-a
git clone --recursive -b experimental/foundation https://github.com/apple/swift-corelibs-libdispatch.git
cd swift-corelibs-libdispatch
sh ./autogen.sh
./configure --with-swift-toolchain=$SWIFT_HOME/usr --prefix=$SWIFT_HOME/usr
make
make install
```

In case this won't work, detailed instructions are available at this URL:

https://github.com/apple/swift-corelibs-libdispatch/blob/experimental/foundation/INSTALL

## Smud

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


