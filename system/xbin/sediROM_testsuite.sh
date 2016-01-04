#!/system/bin/sh
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

# the first sediROM testing suite!
# execute it like this:
# adb push sediROM_testsuite.sh /sdcard/ && adb shell "su -c sh /sdcard/sediROM_testsuite.sh"

LOG=/sdcard/testsuite.log

echo "Starting testsuite: $(date +"%F %T")" > $LOG

# hard aborting/failures
F_FAIL(){
    echo -e "-> !!!!! ERROR !!!!! : While processing test $1. ABORTED\n"
    echo "ERROR: While processing test $1. ABORTED." >> $LOG
    exit 2
}

# soft failures without aborting
F_WARN(){
    echo -e "!!!!! WARNING !!!!!: While processing test $1.\nResult was: >$2<"
    echo "WARNING: While processing test $1.\nResult was: >$2<" >> $LOG
    echo 
}

# echo output with variable as result
END_VAR(){
    echo "-> OK: Testing $1 finished successfully"
    echo "-> OK: Testing $1 finished successfully" >> $LOG
    echo -e "-> Result was:\n$2\n"
}

# echo output with temp file as result
END_FILE(){
    echo "-> OK: Testing $1 finished successfully"
    echo "-> OK: Testing $1 finished successfully" >> $LOG
    echo -e "-> Result was:\n$(cat /sdcard/test)\n\n"
}
###########################################################################

echo -e "\n\nStarting the sediROM test suite! Have fun ;-)"
echo -e "-------------------------------------------------------\n"

echo "\n****************************************************"
TEST=">crond<"
echo "-> Testing $TEST"
ps |grep crond > /sdcard/test
if [ $? -ne 0 ];then
    cat /sdcard/test
    F_FAIL "$TEST"
else
    END_FILE "$TEST"
fi

echo "\n****************************************************"
TEST=">crond config<"
echo "-> Testing $TEST"
FSIZE=$(stat -t /system/etc/cron.d/root |cut -d " " -f 2 )
if [ "$FSIZE" -lt 10 ];then
    stat -t /system/etc/cron.d/root
    F_FAIL "$TEST"
else
    END_VAR "$TEST" "$FSIZE"
fi

echo "\n****************************************************"
TEST=">sediROM app<"
echo "-> Testing $TEST"
SAPP=/system/app/sediROM_boot.apk
stat $SAPP > /sdcard/test
if [ $? -ne 0 ];then
    cat /sdcard/test
    F_FAIL "$TEST"
else
    END_FILE "$TEST"
fi

echo "\n****************************************************"
TEST=">easy install: sediKERNEL<"
echo "-> Testing $TEST"
KERNEL=$(uname -r |grep -o sediKERNEL)
if [ "$KERNEL" != "sediKERNEL" ];then
    F_WARN "$TEST" "$KERNEL"
else
    END_VAR "$TEST" "$KERNEL"
fi

echo "\n****************************************************"
TEST=">easy install: gsm.version.baseband<"
echo "-> Testing $TEST"
MODEM=$(getprop gsm.version.baseband)
if [ "$MODEM" != "I927UCLJ3" ];then
    echo -e "WARNING: While processing test $TEST. Found: $MODEM.\n"
else
    END_VAR "$TEST" "$MODEM"
fi

echo "\n****************************************************"
TEST=">easy install: root<"
echo "-> Testing $TEST"
ROOT=$(su -c echo "rooted")
if [ "$ROOT" != "rooted" ];then
    F_WARN "$TEST" "$ROOT"
else
    END_VAR "$TEST" "$ROOT"
fi

echo "\n****************************************************"
TEST=">BT-fix startmessage<"
echo "-> Testing $TEST"
dmesg |grep "sedi_btFCdetect.sh.*starting" | tail -n 3 > /sdcard/test
if [ $? -ne 0 ];then
    cat /sdcard/test
    F_FAIL "$TEST"
else
    END_FILE "$TEST"
fi

echo "\n****************************************************"
TEST=">BT-fix finishmessage<"
echo "-> Testing $TEST"
dmesg |grep "sedi_btFCdetect.sh.*finished" | tail -n 3 > /sdcard/test
if [ $? -ne 0 ];then
    cat /sdcard/test
    F_FAIL "$TEST"
else
    END_FILE "$TEST"
fi

echo "\n****************************************************"
TEST=">BT-fix indicator file<"
echo "-> Testing $TEST"
BTIPATH=$(dirname /data/misc/bluetoothd/*/.)
BTINDI="$BTIPATH/btfix.indicator"
if [ ! -f "$BTINDI" ];then
    echo $BTINDI
    F_FAIL "$TEST"
else
    END_VAR "$TEST" "$BTINDI"
fi

echo "\n****************************************************"
TEST=">/preload/.sediROM<"
echo "-> Testing $TEST"
SEDIDIR="/preload/.sediROM"
if [ ! -d "$SEDIDIR" ];then
    stat -t $SEDIDIR
    F_FAIL "$TEST"
else
    END_VAR "$TEST"
    stat -t $SEDIDIR
fi

echo "\n****************************************************"
TEST=">dir-moved-2-preload.txt<"
echo "-> Testing $TEST"
SFILE="/preload/.sediROM/dir-moved-2-preload.txt"
if [ ! -f "$SFILE" ];then
    stat -t $SFILE
    F_FAIL "$TEST"
else
    END_VAR "$TEST"
    stat -t $SFILE
fi

echo "\n****************************************************"
TEST=">initialized state<"
echo "-> Testing $TEST"
IFILE="/preload/.sediROM/.initialized"
if [ ! -f "$IFILE" ];then
    stat -t "$IFILE"
    F_FAIL "$TEST"
else
    END_VAR "$TEST"
    stat -t "$IFILE"
fi

echo "\n****************************************************"
TEST=">remountrw<"
echo "-> Testing $TEST"
remountrw /system > /sdcard/test
if [ $? -ne 0 ];then
    cat /sdcard/test
    F_FAIL "$TEST"
else
    END_FILE "$TEST"
fi

echo "\n****************************************************"
TEST=">remountro<"
echo "-> Testing $TEST"
remountro /system > /sdcard/test
if [ $? -ne 0 ];then
    cat /sdcard/test
    F_FAIL "$TEST"
else
    END_FILE "$TEST"
fi

echo "\n****************************************************"
TEST=">EFS backup<"
echo "-> Testing $TEST"
ls /sdcard/efs_$(date +%F)_* 2>&1 > /sdcard/test
if [ $? -ne 0 ];then
    ls /sdcard/efs_$(getprop ro.build.display.id)* 2>&1 > /sdcard/test
    if [ $? -ne 0 ];then
        cat /sdcard/test
        F_FAIL "$TEST"
    else
        F_WARN "$TEST" "matching $(ls /sdcard/efs_$(getprop ro.build.display.id)* )"
    fi
else
    END_FILE "$TEST"
fi

echo "\n****************************************************"
TEST=">init.d dir perm<"
echo "-> Testing $TEST"
EISTAT=$(stat -c %a /etc/init.d/ )
if [ "$EISTAT" -ne 750 ];then
    echo "$TEST: $EISTAT"
    F_FAIL "$TEST"
else
    END_VAR "$TEST" "$EISTAT"
fi


echo "\n****************************************************"
TEST=">init.d file perms<"
echo "-> Testing $TEST"
WORLDRW=$(find /etc/init.d -perm -o+w|wc -l)
if [ "$WORLDRW" -ne 0 ];then
    echo "$TEST: $WORLDRW"
    F_FAIL "$TEST"
else
    END_VAR "$TEST" "$(find /etc/init.d -perm -o+w)"
fi

echo "\n****************************************************"
TEST=">init.d file owner<"
echo "-> Testing $TEST"
IUSER=$(ls -la /etc/init.d |grep -v root|wc -l)
if [ "$IUSER" -ne 0 ];then
    ls -la /etc/init.d |grep -v root
    F_FAIL "$TEST"
else
    END_VAR "$TEST" "$(ls -la /etc/init.d |grep -v rootxxx)"
fi



echo -e "\n-------------------------------------------------------\n"
# Created by http://patorjk.com/software/taag/#p=display&h=1&f=Ivrit&t=sediROM%3A
# font = Ivrit
echo '       
                 _  _  ____    ___   __  __ 
  ___   ___   __| |(_)|  _ \  / _ \ |  \/  |
 / __| / _ \ / _` || || |_) || | | || |\/| |
 \__ \|  __/| (_| || ||  _ < | |_| || |  | |
 |___/ \___| \__,_||_||_| \_\ \___/ |_|  |_|
                                     
'
echo 
echo -e "Test suite summary:\n"
echo -e "\tOK count: $(grep -c OK $LOG)"
echo -e "\tWARNING count: $(grep -c WARNING $LOG)"
echo -e "\tERROR count: $(grep -c ERROR $LOG)"
echo -e "\nTest suite finished! Have a nice day ;-)\n\n"

echo -e "Test suite summary:\n" >> $LOG
echo -e "\tOK count: $(grep -c OK $LOG)" >> $LOG
echo -e "\tWARNING count: $(grep -c WARNING $LOG)" >> $LOG
echo -e "\tERROR count: $(grep -c ERROR $LOG)" >> $LOG
echo -e "\nTest suite finished $(date +"%F %T")! Have a nice day ;-)" >> $LOG

