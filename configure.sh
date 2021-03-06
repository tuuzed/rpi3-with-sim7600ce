#! /bin/sh

# 内核版本
# rpi-4.9.y
# rpi-4.9.y-stable
# rpi-4.13.y

export KERNEL_VERSION=$2


# 显示帮助信息
showHelpInfo(){
	echo ""
	echo "如何使用: ./configure.sh <command> <version>"
	echo ""
	echo "    command: download           从Github下载交叉编译工具和源码"
	echo "    command: download-gitee     从Gitee下载交叉编译工具和源码"
	echo "    command: purge              净化目录"
	echo "    command: clean              清除编译"
	echo "    command: build              编译"
	echo ""
	echo "    version: rpi-4.9.y"
	echo "    version: rpi-4.9.y-stable"
	echo "    version: rpi-4.13.y"
	echo ""
	exit
}

case $KERNEL_VERSION in

rpi-4.9.y)
	echo "版本:" $KERNEL_VERSION
	;;
rpi-4.9.y-stable)
	echo "版本:" $KERNEL_VERSION
	;;
rpi-4.13.y)
	echo "版本:" $KERNEL_VERSION
	;;
*)
	showHelpInfo
	;;
esac

# 上下文路径
export CONTEXT_PATH=$PWD

echo "工作路径:" $CONTEXT_PATH


# 多线程加速参数配置,一般配置成CPU核心数的1.5倍
export CONFIG_SPEED_UP=6

# 编译临时目录
export TEMP_PATH=$CONTEXT_PATH/temp-$KERNEL_VERSION

# 缓冲目录
export CACHE_PATH=$CONTEXT_PATH/.cache
# 交叉编译工具路径
export TOOLS_PATH=$CACHE_PATH/tools


# 驱动源码路径
export SRC_PATH=$CONTEXT_PATH/src
# 编译时系统内核源码路径
export LINUX_PATH=$TEMP_PATH/linux
# 编译好的升级补丁路径
export UPGRADE_PATCH_PATH=$TEMP_PATH/UpgradePatch

export PATH=$TOOLS_PATH/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin:$PATH

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
	rm -rf $CACHE_PATH
	rm -rf $TEMP_PATH
	;;

# 清除编译
clean)
	rm -rf $TEMP_PATH
	;;

# 编译
build)
	mkdir $TEMP_PATH \
	&& cp -r $CACHE_PATH/linux-$KERNEL_VERSION $LINUX_PATH \
	&& cp $SRC_PATH/public/simcom_wwan.c $LINUX_PATH/drivers/net/usb \
	&& cp $SRC_PATH/$KERNEL_VERSION/option.c $LINUX_PATH/drivers/usb/serial/option.c \
	&& echo "\nobj-\$(CONFIG_USB_USBNET) += usbnet.o simcom_wwan.o\n" >> $LINUX_PATH/drivers/net/usb/Makefile \
	&& /usr/bin/python3 $SRC_PATH/public/merge_config.py $SRC_PATH/public/diff/bcm2709_defconfig.diff $LINUX_PATH/arch/arm/configs/bcm2709_defconfig $LINUX_PATH/arch/arm/configs/bcm2709_defconfig \
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
	showHelpInfo
	;;

esac
