all: dependencies build install

build:
	valac src/news.vala src/widgets.vala src/NewsHeaderBar.vala src/NewsList.vala src/NewsParse.vala src/NewsPanel.vala src/NewsAboutDialog.vala --pkg gtk+-3.0 --pkg granite --pkg libxml-2.0 --pkg webkit2gtk-4.0 -o com.github.allen-b1.news

install:
	cp com.github.allen-b1.news /bin
	cp data/com.github.allen-b1.news.desktop /usr/share/applications/
	cp data/com.github.allen-b1.news.svg /usr/share/icons/hicolor/128x128/apps
	cp data/com.github.allen-b1.news.appdata.xml /usr/share/metainfo

clean:
	rm com.github.allen-b1.news

uninstall: clean
	rm /bin/com.github.allen-b1.news || true
	rm /usr/share/applications/com.github.allen-b1.news.desktop || true
	rm /usr/share/icons/hicolor/128x128/apps/com.github.allen-b1.news.svg || true
	rm /usr/share/metainfo/com.github.allen-b1.news.appdata.xml || true

build-dependency:
	mk-build-deps debian/control
