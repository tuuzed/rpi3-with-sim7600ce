#! /bin/sh

# 上下文路径
export CONTEXT_PATH=$PWD

echo "工作路径:" $CONTEXT_PATH

# 多线程加速参数配置,一般配置成CPU核心数的1.5倍
export CONFIG_SPEED_UP=6

# 编译临时目录
export TEMP_PATH=$CONTEXT_PATH/temp

# 缓冲目录
export CACHE_PATH=$CONTEXT_PATH/.cache

# 内核版本
# rpi-4.9.y
# rpi-4.9.y-stable

export KERNEL_VERSION=rpi-4.13.y

# 驱动源码路径
export SRC_PATH=$CONTEXT_PATH/src

# 编译时系统内核源码路径
export LINUX_PATH=$TEMP_PATH/linux
# 编译时交叉编译工具路径
export TOOLS_PATH=$TEMP_PATH/tools
# 编译好的升级补丁路径
export UPGRADE_PATCH_PATH=$TEMP_PATH/UpgradePatch


case $1 in

# 从Github下载交叉编译工具和源码
download)
	mkdir $CACHE_PATH
	git clone --depth=1 https://github.com/raspberrypi/tools.git $CACHE_PATH/tools
	git clone -b $KERNEL_VERSION --depth=1 https://github.com/raspberrypi/linux.git $CACHE_PATH/linux-$KERNEL_VERSION
	;;

# 从Gitee下载交叉编译工具和源码
download-gitee)
	mkdir $CACHE_PATH
	git clone --depth=1 https://gitee.com/rpi-image/tools.git $CACHE_PATH/tools
	git clone -b $KERNEL_VERSION --depth=1 https://gitee.com/rpi-image/linux.git $CACHE_PATH/linux-$KERNEL_VERSION
	;;

# 净化目录
purge)
	rm -rf $CACHE_PATH \
	&& rm -rf $TEMP_PATH
	;;

# 清除编译
clean)
	rm -rf $TEMP_PATH
	;;

# 编译
build)
	mkdir $TEMP_PATH \
	&& cp -r $CACHE_PATH/linux-$KERNEL_VERSION $LINUX_PATH \
	&& cp -r $CACHE_PATH/tools $TOOLS_PATH \
	&& export PATH=$TOOLS_PATH/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin:$PATH \
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
	&& cd $CONTEXT_PATH \
	&& cp -r $SRC_PATH/public/upgrade.sh $UPGRADE_PATCH_PATH/
	;;

*)
	echo ""
	echo "如何使用: ./configure.sh [command]"
	echo ""
	echo "    command: download           从Github下载交叉编译工具和源码"
	echo "    command: download-gitee     从Gitee下载交叉编译工具和源码"
	echo "    command: purge              净化目录"
	echo "    command: clean              清除编译"
	echo "    command: build              编译"
	echo ""
	;;

esac
