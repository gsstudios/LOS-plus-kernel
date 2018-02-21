#!/system/bin/sh
#
#
# LOS-plus-Kernel Boot Script
# 
# Author: sunilpaulmathew <sunil.kde@gmail.com>
# Modified by: Joshua Lay <mugiisstronk@gmail.com>
#

#
# This script is licensed under the terms of the GNU General Public 
# License version 2, as published by the Free Software Foundation, 
# and may be copied, distributed, and modified under those terms.
#

#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#

echo "Executing LOS plus Boot Script" | tee /dev/kmsg

#
# CPU Input Boost
#
echo 1190400 1497600 > /sys/kernel/cpu_input_boost/ib_freqs
echo 1400 > /sys/kernel/cpu_input_boost/ib_duration_ms
echo 1 > /sys/kernel/cpu_input_boost/enabled

#
# Disable mpdecision & enable Intelliplug
#
stop mpdecision
echo 1 > /sys/module/intelli_plug/parameters/intelli_plug_active

#
# Set Internal I/O defaults
#
echo zen > /sys/block/mmcblk0/queue/scheduler
echo 1024 > /sys/block/mmcblk0/queue/read_ahead_kb

#
# Done!
#
echo "Everything done" | tee /dev/kmsg
