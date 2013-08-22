#!/bin/bash -e
#
# ==============================================================================
# PAQUETE: thaya-constructor
# ARCHIVO: funciones-constructor.sh
# DESCRIPCIÓN: Script de bash principal del paquete thayra-constructor basado en canaima-desarrollador
# COPYRIGHT:
#
# LICENCIA: GPL3
# ==============================================================================
#
# Este programa es software libre. Puede redistribuirlo y/o modificarlo bajo los
# términos de la Licencia Pública General de GNU (versión 3).

function ERROR() {
        echo -e ${ROJO}${1}${FIN}
}

function ADVERTENCIA() {
        echo -e ${AMARILLO}${1}${FIN}
}

function EXITO() {
        echo -e ${VERDE}${1}${FIN}
}

function CONFIGURAR-PERFIL() {

if [ -e "${PLANTILLAS}${PERFIL}/perfil.conf" ]; then
	. "${PLANTILLAS}${PERFIL}/perfil.conf"
else
	ERROR 'El perfil "'${PERFIL}'" no posee archivo de configuración ${PLANTILLAS}${PERFIL}/perfil.conf' && exit 1
fi

for PAQUETES_ in $(ls ${PLANTILLAS}${PERFIL}/paquetes/*.list);do 
        PERFIL_PAQUETES="$PERFIL_PAQUETES $(cat $PAQUETES_)"
done 

if [ -e "${PLANTILLAS}${PERFIL}/preseed-instalador.cfg" ]; then
	mkdir -p "${ISO_DIR}config/binary_debian-installer"
	cp ${PLANTILLAS}${PERFIL}/preseed-instalador.cfg ${ISO_DIR}config/binary_debian-installer/preseed.cfg
fi

if [ -e "${PLANTILLAS}${PERFIL}/banner-instalador.png" ]; then
	mkdir -p "${ISO_DIR}config/binary_debian-installer-includes/usr/share/graphics"
	cp ${PLANTILLAS}${PERFIL}/banner-instalador.png ${ISO_DIR}config/binary_debian-installer-includes/usr/share/graphics/logo_debian.png
fi

if [ -e "${PLANTILLAS}${PERFIL}/gtkrc-instalador" ]; then
	mkdir -p "${ISO_DIR}config/binary_debian-installer-includes/usr/share/themes/Clearlooks/gtk-2.0"
	cp ${PLANTILLAS}${PERFIL}/gtkrc-instalador ${ISO_DIR}config/binary_debian-installer-includes/usr/share/themes/Clearlooks/gtk-2.0/gtkrc
fi

if [ -d "${PLANTILLAS}${PERFIL}/inclusiones-iso" ]; then
        mkdir -p "${ISO_DIR}config/binary_local-includes"
        cp -r ${PLANTILLAS}${PERFIL}/inclusiones-iso/* ${ISO_DIR}config/binary_local-includes/
fi

if [ -d "${PLANTILLAS}${PERFIL}/inclusiones-fs" ]; then
        mkdir -p "${ISO_DIR}config/chroot_local-includes"
        cp -r ${PLANTILLAS}${PERFIL}/inclusiones-fs/* ${ISO_DIR}config/chroot_local-includes/
fi

if [ -e "${PLANTILLAS}${PERFIL}/syslinux.png" ]; then
	mkdir -p "${ISO_DIR}config/binary_syslinux"
	cp ${PLANTILLAS}${PERFIL}/syslinux.png ${ISO_DIR}config/binary_syslinux/splash.png
	PERFIL_SYSPLASH="config/binary_syslinux/splash.png"
fi

if [ -e ${PLANTILLAS}${PERFIL}/*.binary ]; then
	mkdir -p "${ISO_DIR}config/chroot_sources"
	cp ${PLANTILLAS}${PERFIL}/*.binary ${ISO_DIR}config/chroot_sources/
fi

mkdir -p "${ISO_DIR}config/package-lists"
cp ${PLANTILLAS}${PERFIL}/paquetes/*.list ${ISO_DIR}config/package-lists/

mkdir -p "${ISO_DIR}config/chroot_sources"
cp ${PLANTILLAS}${PERFIL}/llaves-publicas/*.gpg ${ISO_DIR}config/chroot_sources/

if [ -e ${PLANTILLAS}${PERFIL}/*.chroot ]; then
	mkdir -p "${ISO_DIR}config/chroot_sources"
	cp ${PLANTILLAS}${PERFIL}/*.chroot ${ISO_DIR}config/chroot_sources/
fi

if [ -e ${PLANTILLAS}${PERFIL}/preseed-debconf.cfg ]; then
	mkdir -p "${ISO_DIR}config/chroot_local-preseed"
	cp ${PLANTILLAS}${PERFIL}/preseed-debconf.cfg ${ISO_DIR}config/chroot_local-preseed/
fi

if [ -e ${PLANTILLAS}${PERFIL}/chroot-local-hook.sh ]; then
        mkdir -p "${ISO_DIR}config/chroot_local-hooks"
        cp ${PLANTILLAS}${PERFIL}/chroot-local-hook.sh ${ISO_DIR}config/chroot_local-hooks/
fi

if [ -n "${PERFIL_PAQUETES_ISOPOOL}" ]; then
	mkdir -p "${ISO_DIR}config/binary_local-packageslists"
	echo ${PERFIL_PAQUETES_ISOPOOL} > ${ISO_DIR}config/binary_local-packageslists/paquetes-pool.list
fi

echo "${PERFIL}" > ${ISO_DIR}config/perfil-configurado
}

function CHECK() {
# Asegurando que las carpetas especificadas
# terminen con un slash (/) al final
ultimo_char_iso=${ISO_DIR#${ISO_DIR%?}}
ultimo_char_pla=${PLANTILLAS#${PLANTILLAS%?}}
ultimo_char_scr=${SCRIPTS#${SCRIPTS%?}}
[ "${ultimo_char_iso}" != "/" ] && ISO_DIR="${ISO_DIR}/"
[ "${ultimo_char_pla}" != "/" ] && PLANTILLAS="${PLANTILLAS}/"
[ "${ultimo_char_scr}" != "/" ] && SCRIPTS="${SCRIPTS}/"
echo "Iniciando Thaya Constructor ..."
}
