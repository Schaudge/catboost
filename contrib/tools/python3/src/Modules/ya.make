# Generated by devtools/yamaker.

LIBRARY()



VERSION(3.10.7)

ORIGINAL_SOURCE(https://github.com/python/cpython/archive/v3.10.7.tar.gz)

LICENSE(Python-2.0)

PEERDIR(
    contrib/libs/expat
    contrib/libs/libbz2
    contrib/libs/libc_compat
    contrib/libs/lzma
    contrib/libs/openssl
    contrib/libs/zlib
    contrib/restricted/libffi
)

ADDINCL(
    contrib/libs/expat
    contrib/libs/libbz2
    contrib/restricted/libffi/include
    contrib/tools/python3/src/Include
    contrib/tools/python3/src/Include/internal
    contrib/tools/python3/src/Modules
    contrib/tools/python3/src/Modules/_decimal/libmpdec
)

NO_COMPILER_WARNINGS()

NO_RUNTIME()

CFLAGS(
    -DPy_BUILD_CORE
    -DPy_BUILD_CORE_BUILTIN
)

SRCS(
    _abc.c
    _asynciomodule.c
    _bisectmodule.c
    _blake2/blake2b_impl.c
    _blake2/blake2module.c
    _blake2/blake2s_impl.c
    _bz2module.c
    _codecsmodule.c
    _collectionsmodule.c
    _contextvarsmodule.c
    _csv.c
    _ctypes/_ctypes.c
    _ctypes/callbacks.c
    _ctypes/callproc.c
    _ctypes/cfield.c
    _ctypes/stgdict.c
    _datetimemodule.c
    _decimal/_decimal.c
    _decimal/libmpdec/basearith.c
    _decimal/libmpdec/constants.c
    _decimal/libmpdec/context.c
    _decimal/libmpdec/convolute.c
    _decimal/libmpdec/crt.c
    _decimal/libmpdec/difradix2.c
    _decimal/libmpdec/fnt.c
    _decimal/libmpdec/fourstep.c
    _decimal/libmpdec/io.c
    _decimal/libmpdec/mpalloc.c
    _decimal/libmpdec/mpdecimal.c
    _decimal/libmpdec/mpsignal.c
    _decimal/libmpdec/numbertheory.c
    _decimal/libmpdec/sixstep.c
    _decimal/libmpdec/transpose.c
    _elementtree.c
    _functoolsmodule.c
    _hashopenssl.c
    _heapqmodule.c
    _io/_iomodule.c
    _io/bufferedio.c
    _io/bytesio.c
    _io/fileio.c
    _io/iobase.c
    _io/stringio.c
    _io/textio.c
    _io/winconsoleio.c
    _json.c
    _localemodule.c
    _lsprof.c
    _lzmamodule.c
    _math.c
    _multiprocessing/multiprocessing.c
    _multiprocessing/posixshmem.c
    _multiprocessing/semaphore.c
    _opcode.c
    _operator.c
    _pickle.c
    _queuemodule.c
    _randommodule.c
    _sha3/sha3module.c
    _sre.c
    _ssl.c
    _stat.c
    _statisticsmodule.c
    _struct.c
    _threadmodule.c
    _tracemalloc.c
    _weakref.c
    _xxsubinterpretersmodule.c
    _xxtestfuzz/_xxtestfuzz.c
    _xxtestfuzz/fuzzer.c
    _zoneinfo.c
    arraymodule.c
    atexitmodule.c
    audioop.c
    binascii.c
    cjkcodecs/_codecs_cn.c
    cjkcodecs/_codecs_hk.c
    cjkcodecs/_codecs_iso2022.c
    cjkcodecs/_codecs_jp.c
    cjkcodecs/_codecs_kr.c
    cjkcodecs/_codecs_tw.c
    cjkcodecs/multibytecodec.c
    cmathmodule.c
    config.c
    errnomodule.c
    faulthandler.c
    gcmodule.c
    getbuildinfo.c
    itertoolsmodule.c
    main.c
    mathmodule.c
    md5module.c
    mmapmodule.c
    posixmodule.c
    pyexpat.c
    rotatingtree.c
    selectmodule.c
    sha1module.c
    sha256module.c
    sha512module.c
    signalmodule.c
    socketmodule.c
    symtablemodule.c
    timemodule.c
    unicodedata.c
    zlibmodule.c
)

IF (OS_WINDOWS)
    SRCS(
        _winapi.c
        overlapped.c
    )
ELSE()
    SRCS(
        _cryptmodule.c
        _posixsubprocess.c
        fcntlmodule.c
        getpath.c
        grpmodule.c
        pwdmodule.c
        resource.c
        syslogmodule.c
        termios.c
    )

    IF (OS_DARWIN)
        SRCS(
            _ctypes/darwin/dlfcn_simple.c
            _scproxy.c
        )
    ELSEIF (OS_LINUX)
        IF (NOT MUSL)
            EXTRALIBS(crypt)
        ENDIF()

        SRCS(
            spwdmodule.c
        )
    ENDIF()
ENDIF()

END()
