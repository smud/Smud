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
sudo apt-get install make libevent-dev
git clone https://github.com/smud/Smud.git
cd Smud
make fetch-master
make
```

