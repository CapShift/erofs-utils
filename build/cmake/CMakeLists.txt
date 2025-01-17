cmake_minimum_required(VERSION 3.25)
project(erofs-utils LANGUAGES C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 20)

set(CMAKE_C_FLAGS "")
set(CMAKE_CXX_FLAGS "")

set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# File options
add_definitions(
	"-D_FILE_OFFSET_BITS=64"
	"-D_LARGEFILE_SOURCE"
	"-D_LARGEFILE64_SOURCE"
)

# Compile flags
set(GLOBAL_CFLAGS
	"-Wformat"
	"-Werror=format-security"
	"-no-canonical-prefixes"
	"-fdata-sections"
	"-ffunction-sections"
	"-fvisibility=hidden"
	"-fvisibility-inlines-hidden"
	"-funwind-tables"
	"-fstack-protector-strong"
	"-fno-exceptions"
	"-fno-rtti"
)
set(GLOBAL_CFLAGS_RELEASE
	"-Os"
	"-D_FORTIFY_SOURCE=2"
)

# Linker flags
set(GLOBAL_LDFLAGS
	"-fstack-protector-strong"
	"-Qunused-arguments"
)
set(GLOBAL_LDFLAGS_RELEASE)

if (CMAKE_SYSTEM_NAME MATCHES "Darwin")
	list(APPEND GLOBAL_LDFLAGS "-Wl,-dead_strip,-S")
elseif (CMAKE_SYSTEM_NAME MATCHES "Linux|Android")
	list(APPEND GLOBAL_LDFLAGS "-Wl,--no-undefined" "-static")
	list(APPEND GLOBAL_LDFLAGS_RELEASE "-Wl,--gc-sections" "-s")
	if (CMAKE_SYSTEM_NAME MATCHES "Android")
		list(APPEND GLOBAL_CFLAGS "-DANDROID" "-mllvm" "-polly")
	endif()
endif()

if (CMAKE_BUILD_TYPE STREQUAL "Release")
	list(APPEND GLOBAL_CFLAGS ${GLOBAL_CFLAGS_RELEASE})
	list(APPEND GLOBAL_LDFLAGS ${GLOBAL_LDFLAGS_RELEASE})
	if (ENABLE_FULL_LTO)
		list(APPEND GLOBAL_CFLAGS "-flto=full")
		if (NOT CMAKE_SYSTEM_NAME MATCHES "Darwin")
			list(APPEND GLOBAL_LDFLAGS "-fuse-ld=lld")
		endif ()
	endif ()
	add_definitions("-DNDEBUG")
elseif (CMAKE_BUILD_TYPE STREQUAL "Debug")
	list(APPEND GLOBAL_CFLAGS "-O0" "-g")
endif()

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
	list(APPEND GLOBAL_CFLAGS "-fdiagnostics-color=always")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
	list(APPEND GLOBAL_CFLAGS "-fcolor-diagnostics")
endif()

add_compile_options("$<$<COMPILE_LANGUAGE:C>:${GLOBAL_CFLAGS}>" "$<$<COMPILE_LANGUAGE:CXX>:${GLOBAL_CFLAGS}>")
add_link_options("$<$<LINK_LANGUAGE:C>:${GLOBAL_LDFLAGS}>" "$<$<LINK_LANGUAGE:CXX>:${GLOBAL_LDFLAGS}>")

set(LIB_DIR "${PROJECT_SOURCE_DIR}/../../src")
set(PROJECT_ROOT_DIR "${PROJECT_SOURCE_DIR}/../..")

execute_process(COMMAND sh -c
	"cd ${PROJECT_SOURCE_DIR}/../../ && scripts/get-version-number"
	OUTPUT_VARIABLE PROJECT_VERSION
)
string(REGEX REPLACE "\n$" "" PROJECT_VERSION "${PROJECT_VERSION}")
configure_file(
	"${CMAKE_CURRENT_SOURCE_DIR}/erofs-utils-version.h.in"
	"${CMAKE_BINARY_DIR}/erofs-utils-version.h"
)

# Git clone submodule
execute_process(COMMAND git submodule init)
execute_process(COMMAND git submodule update)

# Start building
add_subdirectory(lib)
add_subdirectory(erofs-tools)
