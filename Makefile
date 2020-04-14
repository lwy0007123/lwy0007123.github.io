.PHONY: all preview requirements plugins

all: plugins preview

preview:
	hexo g
	hexo s

requirements:
	npm install --save
	sudo npm install -g hexo-cli

plugins:
	git clone https://github.com/theme-next/theme-next-reading-progress themes/next/source/lib/reading_progress
	git clone https://github.com/theme-next/theme-next-pangu.git themes/next/source/lib/pangu
	git clone https://github.com/theme-next/theme-next-bookmark.git themes/next/source/lib/bookmark
