#!/system/bin/sh
############################################################
#
# Copyright (c) 2015 by Thomas Fischer, www.se-di.de
# All rights reserved.
# v2.3
#
# This script is part of sediROM.
############################################################

echo "$(date +%D_%T) - sediROM($0): starting. Should be executed by cron." >> /dev/kmsg

# path where the config and log will be saved (may be auto adapted later in this script)
SEDIDIR=/preload/.sediROM/

BTIPATH=$(dirname /data/misc/bluetoothd/*/.)
BTINDI="$BTIPATH/btfix.indicator"

# Indicator file will be added by shutdown script and that requires at least 1 clean shutdown.
IFLAG=$SEDIDIR/.initialized

############################################################
# ensure that /data is not encrypted and if so we wait until it will
# be unlocked by the user
ENCSTATE=$(getprop vold.post_fs_data_done)

# ensure that system has booted completely
BOOTSTATE=$(getprop sys.boot_completed)

while [ ! -f "$IFLAG" ] || [ ! "x$ENCSTATE" == "x1" ] || [ ! "x$BOOTSTATE" == "x1" ];do
    echo "$(date +%D_%T) - sediROM($0): /data (still) locked or sediROM is not fully initialized." >> /dev/kmsg
    RETIFLAG=$(test -f "$IFLAG")
    echo "$(date +%D_%T) - sediROM($0): boot state was: $BOOTSTATE (should be empty or 1)." >> /dev/kmsg
    echo "$(date +%D_%T) - sediROM($0): $IFLAG test was: $RETIFLAG (should be empty or 0)." >> /dev/kmsg
    echo "$(date +%D_%T) - sediROM($0): Encryption test was: $ENCSTATE (should be 1)." >> /dev/kmsg
    sleep 10s
    # re-check states
    ENCSTATE=$(getprop vold.post_fs_data_done)
    BOOTSTATE=$(getprop sys.boot_completed)
    
    # ensure sdcard was initialized
    while [ ! -d "/sdcard/.sediROM" ];do sleep 3s ;done
    
    # if we were not able to use preload as log storage we will use sdcard instead    
    SEDISDDIR=/sdcard/.sediROM # if we cannot mount /preload this is a fallback
    INDIMOVED=$SEDISDDIR/dir-moved-2-preload.txt # indicator file to know if we are using preload or not               
    if [ ! -f "$INDIMOVED" ];then                                                                              
        SEDIDIR=$SEDISDDIR
    fi                                                                                                         
    echo "$(date +%D_%T) - sediROM($0): initflag dir set to $SEDIDIR" >> /dev/kmsg
    IFLAG=$SEDIDIR/.initialized
done

# set working dir according to the above result
WRKDIR=$SEDIDIR/bin
LOG=$WRKDIR/${0##*/}.log

# setup work dir
[ ! -d $WRKDIR ] && mkdir -p $WRKDIR

echo "$(date +%D_%T) - sediROM($0): sediROM fully initialized. Starting BTFix after FC." >> /dev/kmsg

# check if a force close / soft reboot has taken place
# and if so re-enable bluetooth
if [ ! -f "$BTINDI" ];then
    echo "$(date) sediROM: starting $0" > $LOG
    sh /etc/init.d/92sediROM_btfix >> $LOG
else
    echo "$(date) sediROM: $0 - BT indicator file is here. nothing to do." > $LOG
fi
echo "$(date +%D_%T) - sediROM($0): finished." >> /dev/kmsg
