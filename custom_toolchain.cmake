# Wrap SDK toolchain
include($ENV{CMAKE_TOOLCHAIN_FILE})
# Qt6 paths (these get cached)
set(Qt6_DIR $ENV{OECORE_TARGET_SYSROOT}/usr/lib/cmake/Qt6)
set(QT_HOST_PATH $ENV{OECORE_NATIVE_SYSROOT}/usr)

