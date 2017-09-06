SHELL = /bin/sh

all: build install

build: dependecies
	valac src/news.vala --pkg gtk+-3.0

install: 
	cp data/com.github.allen-b1.news.desktop ~/.local/share/applications
	chmod +x ~/.local/share/applications/com.github.allen-b1.news.desktop

dependecies: 
	dpkg -s libgtk-3-dev 1>/dev/null || sudo apt-get install libgtk-3-dev
	dpkg -s valac 1>/dev/null || sudo apt-get install valac
