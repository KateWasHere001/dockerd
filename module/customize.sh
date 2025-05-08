#!/system/bin/sh
SKIPUNZIP=0
SKIPMOUNT=false

if [ "$BOOTMODE" != true ]; then
  ui_print "! Please install in Magisk Manager or KernelSU Manager"
  ui_print "! Install from recovery is NOT supported"
  abort "-----------------------------------------------------------"
elif [ "$KSU" = true ] && [ "$KSU_VER_CODE" -lt 10670 ]; then
  abort "error: Please update your KernelSU and KernelSU Manager"
fi

generate_os_release() {

  local OS_RELEASE_FILE="$MODPATH/system/etc/os-release"
  mkdir -p $(dirname "$OS_RELEASE_FILE")
  local ANDROID_VERSION=$(getprop ro.build.version.release)
  local BUILD_ID=$(getprop ro.build.id)

  echo "NAME=\"Android\"" > "$OS_RELEASE_FILE"
  echo "ID=\"android\"" >> "$OS_RELEASE_FILE"
  echo "VERSION=\"$ANDROID_VERSION\"" >> "$OS_RELEASE_FILE"
  echo "VERSION_ID=\"$ANDROID_VERSION\"" >> "$OS_RELEASE_FILE"
  echo "BUILD_ID=\"$BUILD_ID\"" >> "$OS_RELEASE_FILE"
  echo "PRETTY_NAME=\"Android $ANDROID_VERSION \"" >> "$OS_RELEASE_FILE"
  set_perm "$OS_RELEASE_FILE" 0 0 0644

}

SERVICE_DIR="/data/adb/service.d"

CUSTOM_DIR="/data/adb/docker"

if [ -f "$CUSTOM_DIR/scripts/dockerd.service" ]; then
  ui_print "- Stopping dockerd service"
  "$CUSTOM_DIR/scripts/dockerd.service" stop 2>&1 > /dev/null
fi

ui_print "- Creating directories"

mkdir -p "$CUSTOM_DIR" "$SERVICE_DIR"

ui_print "- Extracting docker binaries"

tar -xf "$MODPATH/docker.tar.xz" -C "$CUSTOM_DIR"

rm -f "$MODPATH/docker.tar.xz"

ui_print "- Moving files to $CUSTOM_DIR"

mv -f "$MODPATH/dockerd/scripts" "$CUSTOM_DIR/scripts"
mv -f "$MODPATH/dockerd/settings.ini" "$CUSTOM_DIR/settings.ini"

rm -rf "$MODPATH/dockerd"

ui_print "- Setting permissions"
set_perm_recursive $CUSTOM_DIR 0 0 0755 0755
set_perm_recursive $MODPATH/system/bin 0 0 0755 0755
set_perm $MODPATH/service.sh 0 0 0755
mv -f "$MODPATH/service.sh" "$SERVICE_DIR/dockerd_service.sh"
generate_os_release