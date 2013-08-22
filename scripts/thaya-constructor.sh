#!/bin/bash -e
#
# ==============================================================================
# PAQUETE: thayra-constructor
# ARCHIVO: thayra-constructor.sh
# DESCRIPCIÓN: Script de bash principal del paquete thayra-constructor originalmente basado en canaima-semilla
# COPYRIGHT:
#  
# LICENCIA: GPL3
# ==============================================================================
#
# Este programa es software libre. Puede redistribuirlo y/o modificarlo bajo los
# términos de la Licencia Pública General de GNU (versión 3).

VARIABLES="$CONSTRUCTOR/conf/variables.conf"

# Inicializando variables
. ${VARIABLES}

# Cargando funciones
. ${FUNCIONES}

# Comprobaciones varias
CHECK

# Case encargado de interpretar los parámetros introducidos a
# thaya-constructor y ejecutar la función correspondiente
case ${1} in

# En caso de que queramos construir una ISO
construir)

# Capturamos todos los parámetros de entrada
PARAMETROS=${@}
# Removemos el ayudante
PARAMETROS=${PARAMETROS#construir}

[ $( echo ${PARAMETROS} | grep -c "\-\-arquitectura=" ) == 0 ] && PARAMETROS='--arquitectura="" '${PARAMETROS}
[ $( echo ${PARAMETROS} | grep -c "\-\-medio=" ) == 0 ] && PARAMETROS='--medio="" '${PARAMETROS}
[ $( echo ${PARAMETROS} | grep -c "\-\-perfil=" ) == 0 ] && PARAMETROS='--perfil="" '${PARAMETROS}
[ $( echo ${PARAMETROS} | grep -c "\-\-instalador=" ) == 0 ] && PARAMETROS='--instalador="" '${PARAMETROS}

# Para cada argumento ...
for ARGUMENTO in ${PARAMETROS}; do

# Removemos los guiones y la igualdad para aislar el nombre de la variable
# en ${ARG_VARIABLE}
ARG_VARIABLE=${ARGUMENTO#--}
ARG_VARIABLE=${ARG_VARIABLE%=*}
# Removemos la variable para aislar el valor de la variable
ARG_VALOR=${ARGUMENTO#--${ARG_VARIABLE}=}
# Convertiomos la variable en mayúscula
ARG_VARIABLE=$( echo ${ARG_VARIABLE} | tr '[:lower:]' '[:upper:]' )
# Evaluamos la expresión para usar las variables
eval "${ARG_VARIABLE}=${ARG_VALOR}"

# Case para validaciones diversas 
case ${ARG_VARIABLE} in

INSTALADOR)

[ -z ${INSTALADOR} ] && INSTALADOR="no" && ADVERTENCIA 'No se incluirá el instalador.'

case ${INSTALADOR} in
si|yes)
INSTALADOR="--debian-installer=live"
;;
no)
INSTALADOR="--debian-installer=false"
;;
esac

;;

ARQUITECTURA)

# Establecemos la arquitectura del host, si no se especifica
[ -z ${ARQUITECTURA} ] && ARQUITECTURA=$( uname -m ) && ADVERTENCIA 'No especificaste una arquitectura, utilizando "'${ARQUITECTURA}'" presente en el sistema.'

case ${ARQUITECTURA} in
amd64|x64|64|x86_64)
ARQUITECTURA="amd64"
PERFIL_KERNEL="amd64"
EXITO "Arquitectura: amd64"
;;
i386|486|686|i686)
ARQUITECTURA="i386"
PERFIL_KERNEL="686"
EXITO "Arquitectura: i386"
;;
*)
ERROR 'Arquitectura "'${ARQUITECTURA}'" no soportada en Thaya. Abortando.'
;;
esac
;;

PERFIL)

# Establecemos el pefil por defecto "thaya", en caso de no especificar ninguno
[ -z ${PERFIL} ] && PERFIL="thaya" && ADVERTENCIA 'No especificaste un perfil, utilizando perfil "thaya" por defecto.'

rm -rf ${ISO_DIR}config

for PERFILES in $( ls -F ${PLANTILLAS} | grep "/" ); do
if [ "${PERFILES}" == "${PERFIL}/" ]; then
	CONFIGURAR-PERFIL
fi
done

if [ -e ${ISO_DIR}config/perfil-configurado ]; then
EXITO "Perfil: ${PERFIL}"
else
ERROR 'Perfil "'${PERFIL}'" desconocido o no disponible. Abortando.'
fi

;;

MEDIO)

# Establecemos medio "iso", en caso de no especificar ninguno
[ -z ${MEDIO} ] && MEDIO="iso-hybrid" && ADVERTENCIA 'Utilizando medio "iso-hybrid" '

case ${MEDIO} in
usb|usb-hdd|img|USB)
MEDIO="usb-hdd"
EXITO "Medio: Dispositivos de almacenamiento extraíble (USB)"
;;
iso|ISO|CD|DVD)
MEDIO="iso"
EXITO "Medio: Dispositivos de almacenamiento extraíble (CD/DVD)"
;;
iso-hybrid|hibrido|mixto)
MEDIO="iso-hybrid"
EXITO "Medio: iso-hybrid"
;;

*)
ERROR 'Medio "'${MEDIO}'" no reconocido por thaya. Abortando.'
;;
esac

;;

esac

done

PERFIL_BOOTSTRAP=${MIRROR_DEBIAN}
PERFIL_CHROOT=${MIRROR_DEBIAN}
PERFIL_BINARY=${MIRROR_DEBIAN}

cd ${ISO_DIR}

ADVERTENCIA "Limpiando posibles residuos de construcciones anteriores ..."
rm -rf ${ISO_DIR}.stage ${ISO_DIR}auto ${ISO_DIR}binary.log ${ISO_DIR}cache/stages_bootstrap/

lb clean

ADVERTENCIA "Generando árbol de configuraciones ..."

lb config --distribution="${PERFIL_DIST}" \
          --apt="aptitude" \
          --apt-recommends="false" \
          --bootloader="syslinux" \
          --binary-images="${MEDIO}" \
          --bootstrap="debootstrap" \
          --mirror-chroot-security="none" \
          --mirror-binary-security="none" \
          --bootappend-live="boot=live config locale=es_AR.UTF-8 keyboard-layouts=latam quiet splash vga=791 live-config.user-fullname=thaya" \
          --iso-preparer="${PREPARADO_POR}" \
          --iso-volume="thaya-${PERFIL}" \
          --iso-publisher="${PUBLICADO_POR}" \
          --iso-application="${APLICACION}" \
          --mirror-bootstrap="${PERFIL_BOOTSTRAP}" \
          --mirror-binary="${PERFIL_BINARY}" \
          --mirror-chroot="${PERFIL_CHROOT}" \
          --memtest="none" \
          --archive-areas="${COMP_MIRROR_DEBIAN}" \
          --grub-splash="${PERFIL_SYSPLASH}" \
          --win32-loader="false" \
          --bootappend-install="locale=es_AR.UTF-8" \
          --cache="true" \
          --linux-flavours="${PERFIL_KERNEL}" \
          --security="false" \
          --backports="false" \
          --source="false" \
          --architecture="${ARQUITECTURA}" \
          ${INSTALADOR} \
          --language="es_AR.UTF-8" \
          --binary-indices="false" \
          --includes="none" \
          --username="thaya" \
          --hostname="thaya-${PERFIL}" \
          --volatile="false" \
          --syslinux-menu="true" \
          --syslinux-timeout="5" \
          --packages="${PERFIL_PAQUETES}" \
          --syslinux-splash="${PERFIL_SYSPLASH}" 

sed -i 's/LB_SYSLINUX_MENU_LIVE_ENTRY=.*/LB_SYSLINUX_MENU_LIVE_ENTRY="Probar"/g' config/binary

ADVERTENCIA "Construyendo ..."

PATH=$PATH lb build 2>&1 | tee binary.log

if [ ${MEDIO} == "iso" ] && [ -e ${ISO_DIR}binary.iso ]; then
	PESO=$( ls -lah ${ISO_DIR}binary.iso | awk '{print $5}' )
	mv ${ISO_DIR}binary.iso thaya-${PERFIL}_${ARQUITECTURA}.iso
	EXITO "¡Enhorabuena! Se ha creado una imagen ISO de thaya-${PERFIL}, que pesa ${PESO}."
	EXITO "Puedes encontrar la imagen \"thaya-${PERFIL}_${ARQUITECTURA}.iso\" en el directorio $ISO_DIR"
	exit 0
elif [ ${MEDIO} == "usb" ] && [ -e ${ISO_DIR}binary.img ]; then
	PESO=$( ls -lah ${ISO_DIR}binary.img | awk '{print $5}' )
	mv ${ISO_DIR}binary.img thaya-${PERFIL}_${ARQUITECTURA}.img
	EXITO "¡Enhorabuena! Se ha creado una imagen IMG de thaya-${PERFIL}, que pesa ${PESO}."
	EXITO "Puedes encontrar la imagen \"thaya-${PERFIL}_${ARQUITECTURA}.img\" en el directorio $ISO_DIR"
	exit 0
else
	ERROR "Ocurrió un error durante la generación de la imagen."
	ERROR "Envía un correo a desarrolladores@thaya.softwarelibre.gob.ve con el contenido del archivo ${ISO_DIR}binary.log"
	exit 1
fi

;;

instalar)
# En Desarrollo
# aptitude install ${PERFIL_PAQUETES}
;;

probar)
# En Desarrollo
# qemu ISO
;;

gui)
# En Desarrollo
;;

--ayuda|--help|'')
# Imprimiendo la ayuda
man thaya-constructor
;;

esac
