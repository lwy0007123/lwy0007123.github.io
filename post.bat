call git config --global user.email "lwylwy@outlook.com"
call git config --global user.name "sko00o"
call hexo g -d
call git add . 
call git commit -m "Changed on Windows"
call git push origin hexo