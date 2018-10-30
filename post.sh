#!/bin/bash
git config --global user.email "lwylwy@outlook.com"
git config --global user.name 'sko00o'
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=30'

git clone https://github.com/theme-next/theme-next-reading-progress themes/next/source/lib/reading_progress
git clone https://github.com/theme-next/theme-next-pangu.git themes/next/source/lib/pangu
git clone https://github.com/theme-next/theme-next-bookmark.git themes/next/source/lib/bookmark

hexo g -d
read -p 'push src to hexo? (Y/n): ' ch

if [ _'$ch' = _'n' ] || [ _'$ch' = _'N' ]
then
    echo "out"
    exit 1
fi

git add . 
git commit -m "Changed on Linux"
git push origin hexo
echo "done"
