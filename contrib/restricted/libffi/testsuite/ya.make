# Generated by devtools/yamaker.

RECURSE(
    libffi.bhaible
    libffi.call
    libffi.closures
    libffi.go
)

IF (NOT OS_WINDOWS AND NOT ARCH_PPC64LE)
    RECURSE(
    libffi.complex
)
ENDIF()
