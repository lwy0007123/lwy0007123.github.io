#!/bin/bash
git config --global user.email "lwylwy@outlook.com"
git config --global user.name 'sko00o'
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=30'

hexo g -d
read -p 'push src to hexo? (Y/n): ' ch

if [ -n $ch ]
then 
    if [ $ch = 'n' ] || [ $ch = 'N' ]
    then
        echo "out"
        exit 1
    fi
fi

git add . 
git commit -m "Changed on Linux"
git push origin hexo
echo "done"
