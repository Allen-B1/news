[![Built by Developers](https://forthebadge.com/images/badges/built-by-developers.svg)](https://forthebadge.com)

# News
A feed reader for elementary os

[![Get it on Appcenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.allen-b1.news)

![Screenshot](screenshot.png)

## Notes
A big thanks to [mirkobrombin](https://github.com/mirkobrombin) for designing the icon  
![this one](data/com.github.allen-b1.news.svg)

## Building
install dependencies (Ubuntu):
  1. valac
  2. gtk+-3.0
  3. webkit2gtk-4.0
  4. granite (libgranite-dev)
  
```bash
sudo apt install valac gtk+-3.0 webkit2gtk-40 libgranite-dev
```
---

```bash
git clone https://github.com/allen-b1/news.git
cd news
meson .build
cd .build
ninja
```

To install:

```bash
sudo ninja install
```
