using BinaryBuilder

platforms = [
  BinaryProvider.Linux(:i686, :glibc),
  BinaryProvider.Linux(:x86_64, :glibc),
  BinaryProvider.Linux(:aarch64, :glibc),
  BinaryProvider.Linux(:armv7l, :glibc),
  BinaryProvider.Linux(:powerpc64le, :glibc),
  BinaryProvider.MacOS()
]

sources = [
  "https://zlib.net/zlib-1.2.11.tar.gz" =>
  "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1",
]

script = raw"""
cd $WORKSPACE/srcdir
cd zlib-1.2.11/
./configure --prefix=/
make install -j3
"""

products = prefix -> [
  LibraryProduct(prefix,"libz"),
]
product_hashes = Dict()
autobuild(pwd(), "zlib", platforms, sources, script, products, product_hashes)


# Special-case windows platforms
platforms = [
  BinaryProvider.Windows(:i686),
  BinaryProvider.Windows(:x86_64),
]
script = raw"""
cd $WORKSPACE/srcdir
cd zlib-1.2.11/
./configure --sharedlibdir=/bin --prefix=/
make install SHAREDLIB=libz.dll SHAREDLIBM=libz-1.dll SHAREDLIBV=libz-1.2.11.dll LDSHAREDLIBC='' -j3
"""
autobuild(pwd(), "zlib", platforms, sources, script, products, product_hashes)

print_buildjl(product_hashes)

