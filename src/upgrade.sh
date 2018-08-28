#! /bin/sh

sudo cp -r kernel7.img /boot/ \
&& sudo cp -r lib/modules/* /lib/modules \
&& sudo cp -r dts/*.dtb /boot/ \
&& sudo cp -r dts/overlays/*.dtb* /boot/overlays/ \
&& sudo cp -r dts/overlays/README /boot/overlays/
