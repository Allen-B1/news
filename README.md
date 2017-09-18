# news
A news viewer for elementary os

![Screenshot](screenshot.png)

# Installation
## On elementary OS?

<!--a href="https://appcenter.elementary.io/com.github.allen-b1.news"><img src="https://appcenter.elementary.io/badge.svg" alt="Get it on the AppCenter"></a-->
See the building instructions below.

## Not on elementary OS?
Download [`install.sh`](https://raw.githubusercontent.com/Allen-B1/news/master/install.sh) and execute it.

# Building
Make sure that `elementary-sdk` is installed.

```bash
git clone https://github.com/allen-b1/news.git
cd news
cmake /usr ./
make
sudo make install
```
