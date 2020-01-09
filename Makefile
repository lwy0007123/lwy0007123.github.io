.PHONY: init deploy prepare

all: prepare

init:
	npm install --save
	sudo npm install -g hexo-cli

# deploy by hand only, we use travis instead.
deploy:
	hexo g -d

prepare: init
	git clone https://github.com/theme-next/theme-next-reading-progress themes/next/source/lib/reading_progress
	git clone https://github.com/theme-next/theme-next-pangu.git themes/next/source/lib/pangu
	git clone https://github.com/theme-next/theme-next-bookmark.git themes/next/source/lib/bookmark
