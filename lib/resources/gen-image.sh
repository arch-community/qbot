#!/usr/bin/env bash

convert \
	-background '#36393F' \
	\( \
		-size 41x41 xc:'#36393F' \
		\( \
			./avatar.png -resize 41x41 \
			\( -size 41x41 xc:black -fill white -draw 'circle 20,20 0.5,20' \) \
			-alpha off -compose CopyOpacity -composite -compose Over \
		\) \
		-composite \
	\) \
	\( -size 14x1 xc:'#36393F' \) -size 320x \
	\( \
		\( \
			\( \
				\( -size 1x1 xc:'#36393F' \) \
				-gravity southwest -size x \
				-background '#36393F' \
				-font ./Whitney-Medium-Pro.otf -fill '#FF0000' -pointsize 16 \
				label:"Zacc" \
				-append \
			\) \
			\( -size 7x1 xc:'#36393F' \) -size x \
			\( \
				-size 360x \
				-font ./Whitney-Book-Pro.otf -fill '#72767D' -pointsize 12 \
				caption:"Today at 2:22 AM" \
				\( -size 1x1 xc:'#36393F' \) \
				-append \
			\) \
			+append \
		\) \
			-gravity northwest \
		\( -size 1x4 xc:'#36393F' \) -size 320x \
		-font ./Whitney-Book-Pro.otf -fill '#DCDDDE' -pointsize 16 \
		-interline-spacing 4 \
		caption:"i really like this message generator" \
		-gravity northwest -append \
	\) \
	+append -trim \
	-bordercolor '#36393F' -border 5 \
	text.png
