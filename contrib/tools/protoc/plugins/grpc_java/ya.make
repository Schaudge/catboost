IF (HOST_OS_DARWIN AND HOST_ARCH_X86_64 OR
    HOST_OS_LINUX AND HOST_ARCH_X86_64 OR
    HOST_OS_WINDOWS AND HOST_ARCH_X86_64)
    ENABLE(VALID_HOST_PLATFORM_FOR_PREBUILT_GRPC_JAVA)
ENDIF()

IF (NOT USE_PREBUILT_TOOLS OR NOT VALID_HOST_PLATFORM_FOR_PREBUILT_GRPC_JAVA)
    PROGRAM()

    

    NO_COMPILER_WARNINGS()

    PEERDIR(
        contrib/libs/protoc
    )

    SRCDIR(contrib/libs/grpc-java/compiler/src/java_plugin/cpp)

    SRCS(
        java_plugin.cpp
        java_generator.cpp
    )

    END()
ELSE()
    PREBUILT_PROGRAM()

    PEERDIR(build/external_resources/arcadia_grpc_java)

    PRIMARY_OUTPUT(${ARCADIA_GRPC_JAVA_RESOURCE_GLOBAL}/grpc_java${MODULE_SUFFIX})

    END()
ENDIF()
