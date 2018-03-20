using BinaryBuilder

# Collection of sources required to build zlib
sources = [
  "https://zlib.net/zlib-1.2.11.tar.gz" =>
  "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd zlib-1.2.11/

# On windows platforms, our ./configure and make invocations differ a bit
if [[ ${target} == *-w64-mingw* ]]; then
    EXTRA_CONFIGURE_FLAGS="--sharedlibdir=${prefix}/bin"
    EXTRA_MAKE_FLAGS="SHAREDLIB=libz.dll SHAREDLIBM=libz-1.dll SHAREDLIBV=libz-1.2.11.dll LDSHAREDLIBC= "
fi

./configure ${EXTRA_CONFIGURE_FLAGS} --prefix=${prefix}
make install ${EXTRA_MAKE_FLAGS} -j${nproc}
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line.
platforms = [
    Windows(:i686),
    Windows(:x86_64),
    Linux(:i686, :glibc),
    Linux(:x86_64, :glibc),
    Linux(:aarch64, :glibc),
    Linux(:armv7l, :glibc),
    Linux(:powerpc64le, :glibc),
    MacOS()
]

# The products that we will ensure are always built
products = prefix -> [
    LibraryProduct(prefix,"libz", :libz),
]

# Dependencies that must be installed before this package can be built
dependencies = [
]

build_tarballs(ARGS, "Zlib", sources, script, platforms, products, dependencies)
