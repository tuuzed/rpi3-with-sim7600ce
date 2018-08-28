#! /bin/sh

echo "工作路径:" $PWD

# 多线程加速参数配置,一般配置成CPU核心数的1.5倍
export CONFIG_SPEED_UP=6

# 内核版本
export KERNEL_VERSION=rpi-4.9.y-stable

# 系统内核源码路径
export LINUX_PATH=$PWD/linux

# 交叉编译工具路径
export TOOLS_PATH=$PWD/tools

# 升级补丁
export UPGRADE_PATCH=UpgradePatch

# 编译好的升级补丁路径
export UPGRADE_PKG_PATH=$PWD/$UPGRADE_PATCH

# 驱动源码路径
export SRC_PATH=$PWD/src

case $1 in

# 从Github下载交叉编译工具和源码
download)
	git clone --depth=1 https://github.com/raspberrypi/tools.git $TOOLS_PATH \
	&& git clone -b $KERNEL_VERSION --depth=1 https://github.com/raspberrypi/linux.git $LIUNX_PATH \
	&& mkdir .cache \
	&& cp -r linux .cache/ \
	&& cp -r tools .cache/
	;;

# 从Gitee下载交叉编译工具和源码
download-gitee)
	git clone --depth=1 https://gitee.com/rpi-image/tools.git $TOOLS_PATH \
	&& git clone -b $KERNEL_VERSION --depth=1 https://gitee.com/rpi-image/linux.git $LIUNX_PATH \
	&& mkdir .cache \
	&& cp -r linux .cache/ \
	&& cp -r tools .cache/
	;;

# 净化目录
purge)
	rm -rf $UPGRADE_PKG_PATH* \
	&& rm -rf ./linux \
	&& rm -rf ./tools \
	&& rm -rf .cache
	;;

# 清除编译
clean)
	rm -rf $UPGRADE_PKG_PATH* \
	&& rm -rf ./linux \
	&& cp -r linux .cache/
	;;

# 编译
build)
	# 设置环境变量
	export PATH=$TOOLS_PATH/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin:$PATH \
	&& cp $SRC_PATH/public/simcom_wwan.c $LINUX_PATH/drivers/net/usb \
	&& cp $SRC_PATH/$KERNEL_VERSION/option.c $LINUX_PATH/drivers/usb/serial/option.c \
	&& cp $SRC_PATH/$KERNEL_VERSION/bcm2709_defconfig $LINUX_PATH/arch/arm/configs/bcm2709_defconfig \
	&& echo "\nobj-\$(CONFIG_USB_USBNET) += usbnet.o simcom_wwan.o\n" >> $LINUX_PATH/drivers/net/usb/Makefile \
	&& cd $LINUX_PATH \
	&& make mrproper \
	&& make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcm2709_defconfig \
	&& make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j $CONFIG_SPEED_UP zImage modules dtbs \
	&& mkdir $UPGRADE_PATCH_PATH \
	&& make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- modules_install INSTALL_MOD_PATH=$UPGRADE_PATCH_PATH \
	&& scripts/mkknlimg arch/arm/boot/zImage $UPGRADE_PATCH_PATH/kernel7.img \
	&& cp -r $LINUX_PATH/arch/arm/boot/dts $UPGRADE_PATCH_PATH/dts \
	&& cd .. \
	&& cp -r $SRC_PATH/public/upgrade.sh $UPGRADE_PATCH_PATH/ \
	&& tar -zcf UpgradePatch.tar.gz $UPGRADE_PATCH/
	;;

*)
	echo "如何使用: ./configure.sh [command]"
	echo "command: download           从Github下载交叉编译工具和源码"
	echo "command: download-gitee     从Gitee下载交叉编译工具和源码"
	echo "command: purge              净化目录"
	echo "command: clean              清除编译"
	echo "command: build              编译"
	;;

esac
