#!/bin/bash
#######################################
#
#
# Package sediROM helper
#
# v2016-01-04
#######################################
ANSW=undef
LVERFILE=package_last-version.txt
WORKDIR="../../PROJECT_sediROM"
BDIR="$PWD"

# check for vendor dev specification
VENDEV="$1"
while [ -z "$VENDEV" ];do
    echo
    echo "sorry you haven't specified a device name!"
    echo
    echo "Please type in now (e.g.: i927):"
    echo
    read VENDEV
done

F_TYPE(){
    echo
    echo "Type in NIGHTLY, BETA, RELEASE or TEST"
    echo "or press ENTER for TYPE = 'NIGHTLY'!"
    echo
    echo "  TEST    = META-INF only"
    echo "  NIGHTLY = All stuff + MD5"
    echo "  BETA    = same as NIGHTLY but with BETA in name"
    echo "  RELEASE = All stuff + MD5 + Create Release Package"
    echo
    echo "Your choice: "
    read TYPE
    [ -z "$TYPE" ]&&TYPE=NIGHTLY
}

# get last remembered version
LAST_VER(){
    if [ -r "$LVERFILE" ];then
        PREVVER=$(cat $LVERFILE)
        # split major and minor version number
        MINOR=$(echo ${PREVVER##*\.})
        MAJOR=$(echo ${PREVVER%\.*})
        # count it by 1
        NEWMINOR=$(($MINOR + 1))
        OFFERVER=$(echo $MAJOR.$NEWMINOR)
    else
        echo no previous version detected
    fi
}

# set current version
SET_LASTVER(){
    VERSION=$1
    echo $VERSION > $LVERFILE
}

TYPE_PROOF(){
    #debug
    #echo "DEBUG: in TYPE_PROOF"

    unset PROOF_STAT
    if [ -z "$TYPE" ];then
        PROOF_STAT=1
        F_TYPE
    else
        if [ $TYPE != "NIGHTLY" ];then
            if [ $TYPE != "TEST" ];then
                if [ $TYPE != "BETA" ];then
                    if [ $TYPE != "RELEASE" ];then
                        PROOF_STAT=1
                        F_TYPE
                    else
                        PROOF_STAT=0
                    fi
                else
                    PROOF_STAT=0
                fi
            else
                PROOF_STAT=0
            fi
        else
            PROOF_STAT=0
        fi   
    fi
    return $PROOF_STAT
}

while [ $ANSW != "y" ];do
    clear
    if [ -z "$ANSW" ];then break ;fi
    unset ANSW VERSION TYPE
    PROOF_STAT=1

    echo
    echo "$VENDEV mode ..."
    echo

    LAST_VER
    echo 
    echo "Previous version was $PREVVER."
    echo "Should we use >$OFFERVER< for this build?"
    echo
    echo "Type in a new version (e.g.: 'v1.5.0')"
    echo "or simply press ENTER for using $OFFERVER."
    echo
    read UVERSION
    if [ -z $UVERSION ];then
        echo using offered version
        VERSION=$OFFERVER
    else
        echo using your version
        VERSION=$UVERSION
    fi

    while [ -z $VERSION ];do
    	echo "Enter version number (e.g.: 'v1.5.0'):"
    	read VERSION
    done

    while [ "$PROOF_STAT" -ne "0" ];do
            TYPE_PROOF $TYPE
    done

    while [ -z "$ANSW" ];do
        clear
    	echo
    	echo "Your choice was:"
    	echo "	VERSION	= $VERSION"
    	echo "	TYPE	= $TYPE"
    	echo
    	echo "Is that OK?" 
        echo "Press -RETURN- or type 'y' for yes."
        echo "To ABORT instead type in 'abort' and we will starting over again:"
        read ANSW
        if [ -z $ANSW ];then ANSW="y" ;fi
    done 
done

# everything fine so do the magic

case "$TYPE" in
	TEST)
        # add vendor dev spec to type
        TYPE="${VENDEV}_${TYPE}"

        echo "$TYPE zip will be created."
		cd $WORKDIR && zip -x "*gitignore" -y -q -r -5 sediROM_${TYPE}_${VERSION}.zip META-INF && cd $BDIR
        if [ $? -eq 0 ];then
            echo "$TYPE: Completed successfully. This window will autoclose in 2 seconds."
            sleep 2 && echo CLOSING NOW && exit
        else
            echo "ERROR occured while creating ZIP file ${VERSION}.zip"
        fi
	;;
	BETA|NIGHTLY)
        # add vendor dev spec to type
        TYPE="${VENDEV}_${TYPE}"

        echo "$TYPE zip will be created. This will take a long time"
        cd $WORKDIR && zip -x "*gitignore" -y -q -r -9 sediROM_${TYPE}_${VERSION}.zip boot.img customize META-INF modem.bin setup system tmp README.txt \
            && echo "Creating MD5.." && md5sum sediROM_${TYPE}_${VERSION}.zip > sediROM_${TYPE}_${VERSION}.zip.md5 \
            && echo "MD5 created successfully." \
            && cd $BDIR
        if [ $? -eq 0 ];then
            SET_LASTVER "$VERSION"
            echo "$TYPE: Completed successfully. This window will close in 30 seconds."
            sleep 10 && echo ... 20 seconds
            sleep 10 && echo ... 10 seconds
            sleep 10 && echo CLOSING NOW && exit
        else
            echo "ERROR occured while creating ZIP file ${VERSION}.zip"
            read DUMMY
        fi
	;;
	RELEASE)
        # add vendor dev spec to type
        TYPE="${VENDEV}_${TYPE}"

        echo "$TYPE zip will be created. This will take a very VERY long time..."
        cd $WORKDIR && zip -x "*gitignore" -y -q -r -9 sediROM_${VERSION}.zip boot.img customize META-INF modem.bin setup system tmp README.txt && cd $BDIR
        if [ $? -eq 0 ];then 
            echo "Zip completed. Creating sediROM $TYPE Package..."
            cd $WORKDIR && zip -T sediROM_${VERSION}.zip \
                && echo "ZIP integrity OK. Creating MD5.." && md5sum sediROM_${VERSION}.zip > sediROM_${VERSION}.zip.md5 \
                && echo "MD5 created successfully. Packaging whole stuff now.." && cp tmp/CHANGES . && zip -r -0 sediROM_${MAJOR}_EXTRACT-ME-BEFORE-FLASHING.zip sediROM_${VERSION}.zip sediROM_${VERSION}.zip.md5 README.txt CHANGES\
                && echo "Release Packaging finished. Cleaning up..." && rm -f sediROM_${VERSION}.zip sediROM_${VERSION}.zip.md5 CHANGES \
                && cd $BDIR
            if [ $? -eq 0 ];then
                SET_LASTVER "$VERSION"
                echo "$TYPE: Completed successfully. This window will autoclose in 30 seconds."
                sleep 10 && echo ... 20 seconds
                sleep 10 && echo ... 10 seconds
                sleep 10 && echo CLOSING NOW && exit
            else
               echo "$TYPE: ERROR occured while creating ZIP file ${VERSION}.zip"
            fi 
        else 
            echo "ERROR occured while creating ZIP file ${VERSION}.zip"
        fi
	;;
	*)
        echo "FATAL ERROR. THAT SHOULD NEVER HAPPEN!"
        read DUMMY
    ;;
esac

SET_LASTVER "$VERSION"
