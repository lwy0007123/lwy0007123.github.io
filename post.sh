#!/bin/bash
git config --global user.email "lwylwy@outlook.com"
git config --global user.name 'sko00o'
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=30'

hexo g -d
read -sp 'username:' passvar
read -sp 'Hey $passvar, password please:' passvar

git add . 
git commit -m "Changed on Linux"
git push origin hexo
