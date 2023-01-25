set(TARGET erofs_static)

set(TARGET_SRC_DIR "${PROJECT_ROOT_DIR}/lib")

set(LIBEROFS_STATIC_DEFAULTS_CFLAGS
	"-Wall"
	"-Wno-ignored-qualifiers"
	"-Wno-pointer-arith"
	"-Wno-unused-parameter"
	"-Wno-unused-function"
	"-DHAVE_FALLOCATE"
	"-DHAVE_LINUX_TYPES_H"
	"-DHAVE_LIBSELINUX"
	"-DHAVE_LIBUUID"
	"-DLZ4_ENABLED"
	"-DLZ4HC_ENABLED"
	"-DHAVE_LIBLZMA"
	"-DWITH_ANDROID"
	"-DHAVE_MEMRCHR"
	"-DHAVE_SYS_IOCTL_H"
	"-DGWINSZ_IN_SYS_IOCTL"
	"-DHAVE_SYS_SYSMACROS_H"
	"-DHAVE_PWRITE64"
	CACHE INTERNAL "liberofs_static_defaults_cflags"
)

set(liberofs_srcs
	"${TARGET_SRC_DIR}/config.c"
	"${TARGET_SRC_DIR}/io.c"
	"${TARGET_SRC_DIR}/cache.c"
	"${TARGET_SRC_DIR}/super.c"
	"${TARGET_SRC_DIR}/inode.c"
	"${TARGET_SRC_DIR}/xattr.c"
	"${TARGET_SRC_DIR}/exclude.c"
	"${TARGET_SRC_DIR}/namei.c"
	"${TARGET_SRC_DIR}/data.c"
	"${TARGET_SRC_DIR}/compress.c"
	"${TARGET_SRC_DIR}/compressor.c"
	"${TARGET_SRC_DIR}/zmap.c"
	"${TARGET_SRC_DIR}/decompress.c"
	"${TARGET_SRC_DIR}/compress_hints.c"
	"${TARGET_SRC_DIR}/hashmap.c"
	"${TARGET_SRC_DIR}/sha256.c"
	"${TARGET_SRC_DIR}/blobchunk.c"
	"${TARGET_SRC_DIR}/dir.c"
	"${TARGET_SRC_DIR}/block_list.c"
	"${TARGET_SRC_DIR}/fragments.c"
	"${TARGET_SRC_DIR}/rb_tree.c"
	"${TARGET_SRC_DIR}/dedupe.c"
	"${TARGET_SRC_DIR}/compressor_lz4.c"
	"${TARGET_SRC_DIR}/compressor_lz4hc.c"
	"${TARGET_SRC_DIR}/compressor_liblzma.c"
)

include(CheckCXXCompilerFlag)
check_cxx_compiler_flag("-Wno-deprecated-non-prototype" CFLAG_Wno-deprecated-non-prototype)
if (CFLAG_Wno-deprecated-non-prototype)
	list(APPEND LIBEROFS_STATIC_DEFAULTS_CFLAGS "-Wno-deprecated-non-prototype")
endif()

add_library(${TARGET} STATIC ${liberofs_srcs})

target_precompile_headers(${TARGET} PRIVATE "${CMAKE_BINARY_DIR}/erofs-utils-version.h")

target_include_directories(${TARGET} PRIVATE
	${liberofs_headers}
	${libcutils_headers}
	${libselinux_headers}
	${liblz4_headers}
	${liblzma_headers}
	${libpcre2_headers}
	${libe2fsprogs_headers}
)

target_compile_options(${TARGET} PRIVATE
	"$<$<COMPILE_LANGUAGE:C>:${LIBEROFS_STATIC_DEFAULTS_CFLAGS}>"
	"$<$<COMPILE_LANGUAGE:CXX>:${LIBEROFS_STATIC_DEFAULTS_CFLAGS}>"
)