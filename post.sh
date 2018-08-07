#!/bin/bash
git config --global user.email "lwylwy@outlook.com"
git config --global user.name 'sko00o'
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=30'

hexo g -d
read -p 'push src to hexo? (Y/n)' ch

if [ $ch = 'n' || $ch = 'N' ]
then
    exit 1
fi

git add . 
git commit -m "Changed on Linux"
git push origin hexo
