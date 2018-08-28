#! /bin/sh

echo Context Path: $PWD

# 多线程加速参数配置
export CONFIG_SPEED_UP=6

# 内核版本
export KERNEL_VERSION=rpi-4.9.y-stable

# 系统内核源码路径
export LINUX_PATH=$PWD/linux

# 交叉编译工具路径
export TOOLS_PATH=$PWD/tools

export UPGRADE_PKG=UpgradePkg

# 编译好的升级包路径
export UPGRADE_PKG_PATH=$PWD/$UPGRADE_PATH

# 驱动源码路径
export SRC_PATH=$PWD/src

case $1 in
cleanall) 
	rm -rf $TOOLS_PATH
	rm -rf $LINUX_PATH
	rm -rf $UPGRADE_PKG_PATH*
	;;
cleantools)
	rm -rf $TOOLS_PATH
	;;
cleanlinux)
	rm -rf $LINUX_PATH
	;;
cleanbuild)
	rm -rf $UPGRADE_PKG_PATH*
	;;

cloneall)
	git clone --depth=1 https://gitee.com/rpi-image/tools.git $TOOLS_PATH \
	&& git clone -b $KERNEL_VERSION --depth=1 https://gitee.com/rpi-image/linux.git $LIUNX_PATH
	;;
clonetools)
	git clone --depth=1 https://gitee.com/rpi-image/tools.git $TOOLS_PATH
	;;
clonelinux)
	git clone -b $KERNEL_VERSION --depth= https://gitee.com/rpi-image/linux.git $LINUX_PATH
	;;
build)
	export PATH=$TOOLS_PATH/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin:$PATH \
	&& cp $SRC_PATH/option.c $LINUX_PATH/drivers/usb/serial/option.c \
	&& cp $SRC_PATH/simcom_wwan.c $LINUX_PATH/drivers/net/usb \
	&& cp $SRC_PATH/bcm2709_defconfig $LINUX_PATH/arch/arm/configs/bcm2709_defconfig \
	&& echo "\nobj-\$(CONFIG_USB_USBNET) += usbnet.o simcom_wwan.o\n" >> $LINUX_PATH/drivers/net/usb/Makefile \
	&& cd $LINUX_PATH \
	&& make mrproper \
	&& make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcm2709_defconfig \
	&& make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j $CONFIG_SPEED_UP zImage modules dtbs \
	&& mkdir $UPGRADE_PKG_PATH \
	&& make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- modules_install INSTALL_MOD_PATH=$UPGRADE_PKG_PATH \
	&& scripts/mkknlimg arch/arm/boot/zImage $UPGRADE_PKG_PATH/kernel7.img \
	&& cp -r $LINUX_PATH/arch/arm/boot/dts $UPGRADE_PKG_PATH/dts \
	&& cd .. \
	&& cp -r $SRC_PATH/upgrade.sh $UPGRADE_PKG_PATH/ \
	&& tar -zcf UpgradePkg.tar.gz $UPGRADE_PKG/
	;;
*)
	echo commands: [cleanall, cleantools, cleanlinux, cloneall, clonetools, clonelinux, build]
esac
