SHELL = /bin/sh

all: build

build: dependecies
	valac src/news.vala --pkg gtk+-3.0 -o ~/com.github.allen-b1.news

run:
	~/com.github.allen-b1.news

install:
	cp data/com.github.allen-b1.news.desktop ~/.local/share/applications

dependecies: 
	dpkg -s libgtk-3-dev 1>/dev/null || sudo apt-get install libgtk-3-dev
	dpkg -s valac 1>/dev/null || sudo apt-get install valac

uninstall:
	rm ~/.local/share/applications/com.github.allen-b1.news.desktop

clean: uninstall
	rm ~/com.github.allen-b1.news
