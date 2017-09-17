# news
A news viewer for elementary os

![Screenshot](screenshot.png)

# Installation (on Elementary OS) (with the elementary sdk)
```bash
git clone https://github.com/allen-b1/news.git
cd news
cmake /usr ./
make
sudo make install
```
## Alternate
If the above doesn't work, try this:

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
