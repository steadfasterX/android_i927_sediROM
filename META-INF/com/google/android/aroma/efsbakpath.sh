#!/sbin/sh
#############################################################################################################################
#
# Author:   Thomas Fischer (xdajog) <mail@se-di.de>
# Desc:		This code is part of sediROM (http://forum.xda-developers.com/showthread.php?t=2789727)
# Version:  v2.0 (the first digit reflects the sediROM major version when this file has been created/changed/modified)
#
# License:  This code is licensed under the Creative Commons License CC BY-SA 4.0.
#
# DISCLAIMER:
# The following deed highlights only some of the key features and terms of the actual license.
# It is NOT a license and has NO legal value. You should carefully review ALL of the terms and conditions of the actual
# license before using the licensed material.
#
# Please check the following link for details and the full legal content:
# http://creativecommons.org/licenses/by-sa/4.0/legalcode
#
#    You are free to:
#
#       Share — copy and redistribute the material in any medium or format
#       Adapt — remix, transform, and build upon the material
#
#       for any purpose, even commercially.
#       The licensor cannot revoke these freedoms as long as you follow the license terms.
#
#    Under the following terms:
#
#       Attribution:
#          You must give appropriate credit, provide a link to the license, and indicate if changes were made.
#          You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
#
#       ShareAlike:
#          If you remix, transform, or build upon the material, you must distribute your contributions under the same
#          license as the original.
#
#############################################################################################################################
echo "/sdcard/efs_$(date +%F_%s 2>&1 | /sbin/busybox grep -v bionic).dd"