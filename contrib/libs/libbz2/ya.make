# Generated by devtools/yamaker from nixpkgs 5852a21819542e6809f68ba5a798600e69874e76.

LIBRARY()



VERSION(1.0.8)

ORIGINAL_SOURCE(https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz)

LICENSE(
    BSD-3-Clause AND
    bzip2-1.0.6
)

LICENSE_TEXTS(.yandex_meta/licenses.list.txt)

NO_COMPILER_WARNINGS()

NO_RUNTIME()

IF (SANITIZER_TYPE == undefined)
    NO_SANITIZE()
ENDIF()

SRCS(
    blocksort.c
    bzlib.c
    compress.c
    crctable.c
    decompress.c
    huffman.c
    randtable.c
)

END()
