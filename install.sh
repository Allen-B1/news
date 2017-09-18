dpkg -l libgtk-3-dev || sudo apt-get install libgtk-3-dev
dpkg -l valac || sudo apt-get install valac

cd `mktemp -d`
git clone https://github.com/allen-b1/news.git
cd news/src
valac news.vala widgets.vala --pkg gtk+-3.0 -o com.github.allen-b1.news
sudo mv com.github.allen-b1.news /usr/bin
cd ..
sudo cp data/com.github.allen-b1.news.svg /usr/share/icons/hicolor/128x128/apps
cp data/com.github.allen-b1.news.desktop ~/.local/share/applications