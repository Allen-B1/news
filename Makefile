all: dependecies build install

dependecies:
	apt install libgtk-3-dev
	apt install libgranite-dev
	apt install libxml2-dev

build:
	valac src/news.vala src/widgets.vala src/NewsHeaderBar.vala src/NewsList.vala --pkg gtk+-3.0 --pkg granite --pkg libxml-2.0 -o com.github.allen-b1.news

install:
	cp com.github.allen-b1.news /bin
	cp data/com.github.allen-b1.news.desktop /usr/share/applications/
	cp data/com.github.allen-b1.news.svg /usr/share/icons/hicolor/128x128/apps
	cp data/com.github.allen-b1.news.appdata.xml /usr/share/metainfo
