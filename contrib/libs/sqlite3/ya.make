# Generated by devtools/yamaker from nixpkgs 9c191ebcdfe917043195c54ab6ae8e934434fe7b.

LIBRARY()



VERSION(3.37.0)

ORIGINAL_SOURCE(https://github.com/sqlite/sqlite/archive/version-3.37.0.tar.gz)

LICENSE(
    Public-Domain
    blessing
)

LICENSE_TEXTS(.yandex_meta/licenses.list.txt)

ADDINCL(
    contrib/libs/sqlite3
)

NO_COMPILER_WARNINGS()

NO_RUNTIME()

CFLAGS(
    -DBUILD_sqlite
    -DHAVE_USLEEP
    -DPIC
    -DSQLITE_ENABLE_COLUMN_METADATA
    -DSQLITE_ENABLE_DBSTAT_VTAB
    -DSQLITE_ENABLE_FTS3
    -DSQLITE_ENABLE_FTS3_PARENTHESIS
    -DSQLITE_ENABLE_FTS3_TOKENIZER
    -DSQLITE_ENABLE_FTS4
    -DSQLITE_ENABLE_FTS5
    -DSQLITE_ENABLE_JSON1
    -DSQLITE_ENABLE_MATH_FUNCTIONS
    -DSQLITE_ENABLE_RTREE
    -DSQLITE_ENABLE_STMT_SCANSTATUS
    -DSQLITE_ENABLE_UNLOCK_NOTIFY
    -DSQLITE_ENABLE_UPDATE_DELETE_LIMIT
    -DSQLITE_HAVE_ZLIB=1
    -DSQLITE_MAX_EXPR_DEPTH=10000
    -DSQLITE_MAX_VARIABLE_NUMBER=250000
    -DSQLITE_SECURE_DELETE
    -DSQLITE_SOUNDEX
    -DSQLITE_TEMP_STORE=1
    -DSQLITE_THREADSAFE=1
)

IF (OS_WINDOWS)
    CFLAGS(
        -DSQLITE_OS_WIN
    )
ELSE()
    CFLAGS(
        -DSQLITE_OS_UNIX
    )
ENDIF()

SRCS(
    sqlite3.c
    test_multiplex.c
)

END()
