# news
A news viewer for elementary os

![Screenshot](screenshot.png)

# Installation
## On elementary OS?
Make sure that `elementary-sdk` is installed.

```bash
git clone https://github.com/allen-b1/news.git
cd news
cmake /usr ./
make
sudo make install
```
## Not on elementary OS?
Try this:

```bash
sudo apt-get install libgtk-3-dev
sudo apt-get install valac

git clone https://github.com/allen-b1/news.git
cd news/src
valac news.vala --pkg gtk+-3.0 -o com.github.allen-b1.news
sudo mv com.github.allen-b1.news /usr/bin
cd ..
cp data/com.github.allen-b1.news.desktop ~/Desktop
```
