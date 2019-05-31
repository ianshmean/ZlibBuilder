using BinaryBuilder

# zlib version
version = v"1.2.11"

# Collection of sources required to build zlib
sources = [
    "https://zlib.net/zlib-$(version).tar.gz" =>
    "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/zlib-*
apk add yasm
# On windows platforms, our ./configure and make invocations differ a bit
if [[ ${target} == *-w64-mingw* ]]; then
    EXTRA_CONFIGURE_FLAGS="--sharedlibdir=${prefix}/bin"
    EXTRA_MAKE_FLAGS="SHAREDLIB=libz.dll SHAREDLIBM=libz-1.dll SHAREDLIBV=libz-1.2.11.dll LDSHAREDLIBC= "
fi

if [[ ${target} == *-freebsd* ]]; then
    cmake -DCMAKE_INSTALL_PREFIX=${prefix} -DCMAKE_TOOLCHAIN_FILE=/opt/${target}/${target}.toolchain
else
    ./configure ${EXTRA_CONFIGURE_FLAGS} --prefix=${prefix}
fi

make install ${EXTRA_MAKE_FLAGS} -j${nproc}

if [[ ! -e ${prefix}/lib/pkgconfig/zlib.pc ]]; then
    mkdir -p ${prefix}/lib/pkgconfig
    cat << EOF > $prefix/lib/pkgconfig/zlib.pc
prefix=${prefix}
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
sharedlibdir=\${libdir}
includedir=\${prefix}/include

Name: zlib
Description: zlib compression library
Version: 1.2.11

Requires:
Libs: -L\${libdir} -L\${sharedlibdir} -lz
Cflags: -I\${includedir}
EOF
fi
"""

# Build for ALL THE PLATFORMS!
platforms = supported_platforms()

# The products that we will ensure are always built
products = prefix -> [
    LibraryProduct(prefix, "libz", :libz),
]

# Dependencies that must be installed before this package can be built
dependencies = [
]

build_tarballs(ARGS, "Zlib", version, sources, script, platforms, products, dependencies)
