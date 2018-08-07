#!/bin/bash
uservar='sko00o'
read -sp 'Hey sko00o, password please:' passvar

git config --global user.email "lwylwy@outlook.com"
git config --global user.name $uservar
hexo g -d
$uservar
$passvar
git add . 
git commit -m "Changed on Linux"
git push origin hexo
$uservar
$passvar