#/bin/bash

THAYA="/opt/ThayaLinux"

CONSTRUCTOR="$THAYA/thaya-constructor"
BASE="$THAYA/thaya-base"
PERFILES="$THAYA/thaya-perfiles"
LB_BASE="$BASE/live-build"

PATH_THAYA="$CONSTRUCTOR/scripts:$LB_BASE/scripts/:$LB_BASE/scripts/build:$BASE/usr/bin/:/usr/bin:/usr/sbin:/sbin:/bin:$PATH"

THAYA=$THAYA CONSTRUCTOR=$CONSTRUCTOR PERFILES=$PERFILES PATH=$PATH_THAYA LB_BASE=$LB_BASE  thaya-constructor.sh construir ${@}
