all: build

test:
	swift test

build:
	swift build -Xcc -fblocks
#	swift build -Xswiftc -j1

rebuild: clean build

clean:
	swift build --clean

distclean:
	swift build --clean dist

fetch-master:
	swift package fetch
	(cd Packages/CEvent-*; git checkout master; git pull)
	(cd Packages/ConfigFile-*; git checkout master; git pull)
	(cd Packages/Utils-*; git checkout master; git pull)

tags:
	ctags -R ./ ../swift-corelibs-foundation/ ../swift-corelibs-libdispatch/

xcodeproj:
	swift package generate-xcodeproj

.PHONY: all build rebuild clean distclean pull-master tags xcodeproj
