#!/bin/bash

#
# LOS-plus-Kernel Build Script
# 
# Author: sunilpaulmathew <sunil.kde@gmail.com>
# Modifed by: gsstudios <josh.lay@exemail.com.au>
# 
# This script has been modified to only build using Linaro TC
# and to build for the klte and kltespr (G900P + G900I) only.
#

#
# This script is licensed under the terms of the GNU General Public 
# License version 2, as published # by the Free Software Foundation, 
# and may be copied, distributed, and modified under those terms.
#

#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR # PURPOSE. See the
# GNU General Public License for more details.
#

#
# ***** ***** ***** ..How to use this script… ***** ***** ***** #
#
# For those who want to build this kernel using this script…
#
# Please note: this script is by-default designed to build all 
# the supported variants one after another.
#

# 1. Properly locate toolchain
# 3. Ensure you are root user. If not, go away! (Needed for ccache)
# 4. Open Terminal, ‘cd’ to the Kernel ‘root’ folder and run ‘.\build_LOS_plus.sh’
# 5. The output (anykernel zip) file will be generated in the ‘release_LOS_plus’ folder
# 6. Enjoy your new Kernel

#
# ***** ***** *Variables to be configured manually* ***** ***** #

# Toolchains

TOOLCHAIN="/home/josh/toolchain/linaro/bin/arm-linaro-linux-androideabi-"

ARCHITECTURE="arm"

KERNEL_NAME="LOS-plus-Kernel"

KERNEL_VERSION="stable-v1_r3"   # leave as such, if no specific version tag

KERNEL_DATE="$(date +"%Y%m%d")"

COMPILE_DTB="y"

NUM_CPUS=""   # number of cpu cores used for build (leave empty for auto detection)

# ***** ***** ***** ***** ***THE END*** ***** ***** ***** ***** #

COLOR_RED="\033[0;31m"
COLOR_GREEN="\033[1;32m"
COLOR_NEUTRAL="\033[0m"

export ARCH=$ARCHITECTURE

echo -e $COLOR_GREEN"\n Toolchain: Linaro\n"$COLOR_NEUTRAL

export CROSS_COMPILE="${CCACHE} $TOOLCHAIN"

if [ -z "$NUM_CPUS" ]; then
	NUM_CPUS=`grep -c ^processor /proc/cpuinfo`
fi

echo -e $COLOR_GREEN"\n building $KERNEL_NAME v. $KERNEL_VERSION for kltekor\n"$COLOR_NEUTRAL

# creating backups
cp scripts/mkcompile_h release_LOS_plus/
cp arch/arm/configs/LOS_plus_@kltekor@_defconfig release_LOS_plus/

# updating kernel name

sed -i "s;LOS-plus-Kernel;$KERNEL_NAME-kltekor;" scripts/mkcompile_h;

# updating kernel version

sed -i "s;stable;-$KERNEL_VERSION;" arch/arm/configs/LOS_plus_@kltekor@_defconfig;

if [ -e output_kltekor/.config ]; then
	rm -f output_kltekor/.config
	if [ -e output_kltekor/arch/arm/boot/zImage ]; then
		rm -f output_kltekor/arch/arm/boot/zImage
	fi
else
mkdir output_kltekor
fi

make -C $(pwd) O=output_kltekor LOS_plus_@kltekor@_defconfig && make -j$NUM_CPUS -C $(pwd) O=output_kltekor

if [ -e output_kltekor/arch/arm/boot/zImage ]; then
	echo -e $COLOR_GREEN"\n copying zImage to anykernel directory\n"$COLOR_NEUTRAL
	cp output_kltekor/arch/arm/boot/zImage anykernel_LOS_plus/
	# compile dtb if required
	if [ "y" == "$COMPILE_DTB" ]; then
		echo -e $COLOR_GREEN"\n compiling device tree blob (dtb)\n"$COLOR_NEUTRAL
		if [ -f output_kltekor/arch/arm/boot/dt.img ]; then
			rm -f output_kltekor/arch/arm/boot/dt.img
		fi
		chmod 777 tools/dtbToolCM
		tools/dtbToolCM -2 -o output_kltekor/arch/arm/boot/dt.img -s 2048 -p output_kltekor/scripts/dtc/ output_kltekor/arch/arm/boot/
		# removing old dtb (if any)
		if [ -f anykernel_LOS_plus/dtb ]; then
			rm -f anykernel_LOS_plus/dtb
		fi
		# copying generated dtb to anykernel directory
		if [ -e output_kltekor/arch/arm/boot/dt.img ]; then
			mv -f output_kltekor/arch/arm/boot/dt.img anykernel_LOS_plus/dtb
		fi
	fi
	echo -e $COLOR_GREEN"\n generating recovery flashable zip file\n"$COLOR_NEUTRAL
	cd anykernel_LOS_plus/ && zip -r9 $KERNEL_NAME-kltekor-$KERNEL_VERSION-$KERNEL_DATE.zip * -x README.md $KERNEL_NAME-kltekor-$KERNEL_VERSION-$KERNEL_DATE.zip && cd ..
	echo -e $COLOR_GREEN"\n cleaning...\n"$COLOR_NEUTRAL
	rm anykernel_LOS_plus/zImage && mv anykernel_LOS_plus/$KERNEL_NAME* release_LOS_plus/
	# restoring backups
	mv release_LOS_plus/mkcompile_h scripts/
	mv release_LOS_plus/LOS_plus_@kltekor@_defconfig arch/arm/configs/
	echo -e $COLOR_GREEN"\n building SmarPack-Kernel for kltekor is finished...\n"$COLOR_NEUTRAL
else
	# restoring backups
	mv release_LOS_plus/mkcompile_h scripts/
	mv release_LOS_plus/LOS_plus_@kltekor@_defconfig arch/arm/configs/
	echo -e $COLOR_GREEN"\n Building error... zImage not found...\n"$COLOR_NEUTRAL
fi

echo -e $COLOR_GREEN"\n building $KERNEL_NAME v. $KERNEL_VERSION for klte\n"$COLOR_NEUTRAL

# creating backups
cp scripts/mkcompile_h release_LOS_plus/
cp arch/arm/configs/LOS_plus_@klte@_defconfig release_LOS_plus/

# updating kernel name

sed -i "s;LOS-plus-Kernel;$KERNEL_NAME-klte;" scripts/mkcompile_h;

# updating kernel version

sed -i "s;stable;-$KERNEL_VERSION;" arch/arm/configs/LOS_plus_@klte@_defconfig;

if [ -e output_klte/.config ]; then
	rm -f output_klte/.config
	if [ -e output_klte/arch/arm/boot/zImage ]; then
		rm -f output_klte/arch/arm/boot/zImage
	fi
else
mkdir output_klte
fi

make -C $(pwd) O=output_klte LOS_plus_@klte@_defconfig && make -j$NUM_CPUS -C $(pwd) O=output_klte

if [ -e output_klte/arch/arm/boot/zImage ]; then
	echo -e $COLOR_GREEN"\n copying zImage to anykernel directory\n"$COLOR_NEUTRAL
	cp output_klte/arch/arm/boot/zImage anykernel_LOS_plus/
	# compile dtb if required
	if [ "y" == "$COMPILE_DTB" ]; then
		echo -e $COLOR_GREEN"\n compiling device tree blob (dtb)\n"$COLOR_NEUTRAL
		if [ -f output_klte/arch/arm/boot/dt.img ]; then
			rm -f output_klte/arch/arm/boot/dt.img
		fi
		chmod 777 tools/dtbToolCM
		tools/dtbToolCM -2 -o output_klte/arch/arm/boot/dt.img -s 2048 -p output_klte/scripts/dtc/ output_klte/arch/arm/boot/
		# removing old dtb (if any)
		if [ -f anykernel_LOS_plus/dtb ]; then
			rm -f anykernel_LOS_plus/dtb
		fi
		# copying generated dtb to anykernel directory
		if [ -e output_klte/arch/arm/boot/dt.img ]; then
			mv -f output_klte/arch/arm/boot/dt.img anykernel_LOS_plus/dtb
		fi
	fi
	echo -e $COLOR_GREEN"\n generating recovery flashable zip file\n"$COLOR_NEUTRAL
	cd anykernel_LOS_plus/ && zip -r9 $KERNEL_NAME-klte-$KERNEL_VERSION-$KERNEL_DATE.zip * -x README.md $KERNEL_NAME-klte-$KERNEL_VERSION-$KERNEL_DATE.zip && cd ..
	echo -e $COLOR_GREEN"\n cleaning...\n"$COLOR_NEUTRAL
	rm anykernel_LOS_plus/zImage && mv anykernel_LOS_plus/$KERNEL_NAME* release_LOS_plus/
	# restoring backups
	mv release_LOS_plus/mkcompile_h scripts/
	mv release_LOS_plus/LOS_plus_@klte@_defconfig arch/arm/configs/
	echo -e $COLOR_GREEN"\n building LOS-plus-Kernel for klte is finished...\n"$COLOR_NEUTRAL
else
	# restoring backups
	mv release_LOS_plus/mkcompile_h scripts/
	mv release_LOS_plus/LOS_plus_@klte@_defconfig arch/arm/configs/
	echo -e $COLOR_GREEN"\n Building error... zImage not found...\n"$COLOR_NEUTRAL
fi

echo -e $COLOR_GREEN"\n building $KERNEL_NAME v. $KERNEL_VERSION for klteduos\n"$COLOR_NEUTRAL

# creating backups
cp scripts/mkcompile_h release_LOS_plus/
cp arch/arm/configs/LOS_plus_@klteduos@_defconfig release_LOS_plus/

# updating kernel name

sed -i "s;LOS-plus-Kernel;$KERNEL_NAME-klteduos;" scripts/mkcompile_h;

# updating kernel version

sed -i "s;stable;-$KERNEL_VERSION;" arch/arm/configs/LOS_plus_@klteduos@_defconfig;

if [ -e output_klteduos/.config ]; then
	rm -f output_klteduos/.config
	if [ -e output_klteduos/arch/arm/boot/zImage ]; then
		rm -f output_klteduos/arch/arm/boot/zImage
	fi
else
mkdir output_klteduos
fi

make -C $(pwd) O=output_klteduos LOS_plus_@klteduos@_defconfig && make -j$NUM_CPUS -C $(pwd) O=output_klteduos

if [ -e output_klteduos/arch/arm/boot/zImage ]; then
	echo -e $COLOR_GREEN"\n copying zImage to anykernel directory\n"$COLOR_NEUTRAL
	cp output_klteduos/arch/arm/boot/zImage anykernel_LOS_plus/
	# compile dtb if required
	if [ "y" == "$COMPILE_DTB" ]; then
		echo -e $COLOR_GREEN"\n compiling device tree blob (dtb)\n"$COLOR_NEUTRAL
		if [ -f output_klteduos/arch/arm/boot/dt.img ]; then
			rm -f output_klteduos/arch/arm/boot/dt.img
		fi
		chmod 777 tools/dtbToolCM
		tools/dtbToolCM -2 -o output_klteduos/arch/arm/boot/dt.img -s 2048 -p output_klteduos/scripts/dtc/ output_klteduos/arch/arm/boot/
		# removing old dtb (if any)
		if [ -f anykernel_LOS_plus/dtb ]; then
			rm -f anykernel_LOS_plus/dtb
		fi
		# copying generated dtb to anykernel directory
		if [ -e output_klteduos/arch/arm/boot/dt.img ]; then
			mv -f output_klteduos/arch/arm/boot/dt.img anykernel_LOS_plus/dtb
		fi
	fi
	echo -e $COLOR_GREEN"\n generating recovery flashable zip file\n"$COLOR_NEUTRAL
	cd anykernel_LOS_plus/ && zip -r9 $KERNEL_NAME-klteduos-$KERNEL_VERSION-$KERNEL_DATE.zip * -x README.md $KERNEL_NAME-klteduos-$KERNEL_VERSION-$KERNEL_DATE.zip && cd ..
	echo -e $COLOR_GREEN"\n cleaning...\n"$COLOR_NEUTRAL
	rm anykernel_LOS_plus/zImage && mv anykernel_LOS_plus/$KERNEL_NAME* release_LOS_plus/
	# restoring backups
	mv release_LOS_plus/mkcompile_h scripts/
	mv release_LOS_plus/LOS_plus_@klteduos@_defconfig arch/arm/configs/
	echo -e $COLOR_GREEN"\n building SmarPack-Kernel for klteduos is finished...\n"$COLOR_NEUTRAL
else
	# restoring backups
	mv release_LOS_plus/mkcompile_h scripts/
	mv release_LOS_plus/LOS_plus_@klteduos@_defconfig arch/arm/configs/
	echo -e $COLOR_GREEN"\n Building error... zImage not found...\n"$COLOR_NEUTRAL
fi

echo -e $COLOR_GREEN"\n building $KERNEL_NAME v. $KERNEL_VERSION for kltespr\n"$COLOR_NEUTRAL

# creating backups
cp scripts/mkcompile_h release_LOS_plus/
cp arch/arm/configs/LOS_plus_@kltespr@_defconfig release_LOS_plus/

# updating kernel name

sed -i "s;LOS-plus-Kernel;$KERNEL_NAME-kltespr;" scripts/mkcompile_h;

# updating kernel version

sed -i "s;stable;-$KERNEL_VERSION;" arch/arm/configs/LOS_plus_@kltespr@_defconfig;

if [ -e output_kltespr/.config ]; then
	rm -f output_kltespr/.config
	if [ -e output_kltespr/arch/arm/boot/zImage ]; then
		rm -f output_kltespr/arch/arm/boot/zImage
	fi
else
mkdir output_kltespr
fi

make -C $(pwd) O=output_kltespr LOS_plus_@kltespr@_defconfig && make -j$NUM_CPUS -C $(pwd) O=output_kltespr

if [ -e output_kltespr/arch/arm/boot/zImage ]; then
	echo -e $COLOR_GREEN"\n copying zImage to anykernel directory\n"$COLOR_NEUTRAL
	cp output_kltespr/arch/arm/boot/zImage anykernel_LOS_plus/
	# compile dtb if required
	if [ "y" == "$COMPILE_DTB" ]; then
		echo -e $COLOR_GREEN"\n compiling device tree blob (dtb)\n"$COLOR_NEUTRAL
		if [ -f output_kltespr/arch/arm/boot/dt.img ]; then
			rm -f output_kltespr/arch/arm/boot/dt.img
		fi
		chmod 777 tools/dtbToolCM
		tools/dtbToolCM -2 -o output_kltespr/arch/arm/boot/dt.img -s 2048 -p output_kltespr/scripts/dtc/ output_kltespr/arch/arm/boot/
		# removing old dtb (if any)
		if [ -f anykernel_LOS_plus/dtb ]; then
			rm -f anykernel_LOS_plus/dtb
		fi
		# copying generated dtb to anykernel directory
		if [ -e output_kltespr/arch/arm/boot/dt.img ]; then
			mv -f output_kltespr/arch/arm/boot/dt.img anykernel_LOS_plus/dtb
		fi
	fi
	echo -e $COLOR_GREEN"\n generating recovery flashable zip file\n"$COLOR_NEUTRAL
	cd anykernel_LOS_plus/ && zip -r9 $KERNEL_NAME-kltespr-$KERNEL_VERSION-$KERNEL_DATE.zip * -x README.md $KERNEL_NAME-kltespr-$KERNEL_VERSION-$KERNEL_DATE.zip && cd ..
	echo -e $COLOR_GREEN"\n cleaning...\n"$COLOR_NEUTRAL
	rm anykernel_LOS_plus/zImage && mv anykernel_LOS_plus/$KERNEL_NAME* release_LOS_plus/
	if [ -f anykernel_LOS_plus/dtb ]; then
		rm -f anykernel_LOS_plus/dtb
	fi
	# restoring backups
	mv release_LOS_plus/mkcompile_h scripts/
	mv release_LOS_plus/LOS_plus_@kltespr@_defconfig arch/arm/configs/
	echo -e $COLOR_GREEN"\n building LOS-plus-Kernel for kltespr is finished...\n"$COLOR_NEUTRAL
	echo -e $COLOR_GREEN"\n everything done... please visit "release_LOS_plus"...\n"$COLOR_NEUTRAL
else
	if [ -f anykernel_LOS_plus/dtb ]; then
		rm -f anykernel_LOS_plus/dtb
	fi
	# restoring backups
	mv release_LOS_plus/mkcompile_h scripts/
	mv release_LOS_plus/LOS_plus_@kltespr@_defconfig arch/arm/configs/
	echo -e $COLOR_GREEN"\n Building error... zImage not found...\n"$COLOR_NEUTRAL
fi
