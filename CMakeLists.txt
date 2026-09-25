# Copyright (c) 2024-2026 Daemon Developers
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Some generated files will have this string in their name,
# we don't control it, but we need to know it before hand.
set(SAIGO_CLANG_VERSION "21")

# Saigo system name and architecture names.
set(SAIGO_SYSTEM_NAME "nacl")
set(SAIGO_ARCH_NAMES "x86_64" "i686" "arm")

cmake_minimum_required(VERSION 3.10)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

project(SaigoNativeClientToolchain LANGUAGES NONE)

include(ExternalProject)

include(SaigoHelpers)
include(SaigoSetup)

AddGitProject("clang"
	"llvm-project"
	"https://chromium.googlesource.com/native_client/nacl-llvm-project-v10.git"
	"9c7f0369cfdd591e580c5ccfc1f00fedee58029f"
	"0001-cmake-accept-llvm-enable-lto-auto-option.patch"
)

AddGitProject("binutils-x86"
	"binutils-x86"
	"https://chromium.googlesource.com/native_client/nacl-binutils.git"
	"1d8592cc9f02cc9aeaef992c296376a8fd4c8761"
	"binutils/0001-gprof-makefile-fix-building-m-files.patch"
	"binutils/0002-config-sub-enable-riscv64-and-loong64.patch"
	"binutils/0003-libiberty-waitpid-c-only-compile-waitpid-when-have-waitpid.patch"
	"binutils/0004-ld-makefile-in-do-not-build-libldtestplug-la-testplug-lo.patch"
	"binutils/0005-config-sub-enable-arm64.patch"
)

AddGitProject("binutils-arm"
	"binutils-arm"
	"https://chromium.googlesource.com/native_client/nacl-binutils.git"
	"47a96d057be116b4dc6289f54c873d086f320915"
	"binutils/0001-gprof-makefile-fix-building-m-files.patch"
	"binutils/0002-config-sub-enable-riscv64-and-loong64.patch"
	"binutils/0003-libiberty-waitpid-c-only-compile-waitpid-when-have-waitpid.patch"
	"binutils/0004-ld-makefile-in-do-not-build-libldtestplug-la-testplug-lo.patch"
	"binutils/0005-config-sub-enable-arm64.patch"
)

AddGitProject("gdb"
	"gdb"
	"https://chromium.googlesource.com/native_client/nacl-gdb"
	"ef0bd30c46a9066309396c37b10a8ff9a726faf3"
	"binutils/0002-config-sub-enable-riscv64-and-loong64.patch"
	"binutils/0003-libiberty-waitpid-c-only-compile-waitpid-when-have-waitpid.patch"
	"binutils/0005-config-sub-enable-arm64.patch"
	"0001-gdb-amd64-linux-nat-c-fix-ps-get-thread-area-signature.patch"
	"0002-gdb-gdbserver-proc-service-c-fix-ps-lgetfpregs-signature.patch"
	"0003-gdb-gdbserver-linux-x86-low-c-fix-ps-get-thread-area-signature.patch"
	"0004-gdb-gdbserver-proc-service-c-fix-ps-lsetfpregs-signature.patch"
	"0005-readline-input-c-include-conio-h-on-mingw.patch"
	"0006-readline-rltty-c-include-sys-ioctl-h-on-macos.patch"
	"0007-readline-terminal-c-include-sys-ioctl-h-on-macos.patch"
	"0008-gdb-add-mini-termcap-c.patch"
	"0009-gdb-configure-ac-add-mini-termcap-o.patch"
	"0010-gdb-configure-add-mini-termcap-o.patch"
	"0011-gdb-makefile-in-add-mini-termcap-c.patch"
	"0012-gdb-configure-ac-implement-with-mini-termcap.patch"
	"0013-gdb-configure-implement-with-mini-termcap.patch"
)

AddGitProject("nacl"
	"native_client"
	"https://github.com/DaemonEngine/native_client.git"
	"ae29840014b5c08c7733ee9257741d421723255a"
)

option(BUILD_BINUTILS "Build the binutils." ON)

include(saigolibs-tarballs.cmake)

if (BUILD_CLANG)
	if (USE_LTO)
		if (NOT MINGW)
			set(LLVM_LTO "${FLTO_VALUE}")
		endif()
	else()
		set(LLVM_LTO "OFF")
	endif()

	set(ENV{CCACHE_PREFIX} "${PATH_ICECC}")

	AddCompilerCmakeArgs(CLANG "ASM;C;CXX")

	list(APPEND CLANG_ARGS ${EP_CMAKE_ARGS})

	SetLlvmTargetsToBuild("${SAIGO_ARCH_NAMES}" "|")

	ExternalProject_Add(clang-binaries
		${EP_OPTIONS_CLANG}
		SOURCE_SUBDIR llvm
		LIST_SEPARATOR "|"
		CMAKE_GENERATOR "${EP_GENERATOR}"
		CMAKE_ARGS
			${CLANG_ARGS}

			"-DLLVM_TARGETS_TO_BUILD=${LLVM_TARGETS_TO_BUILD}"
			"-DLLVM_DEFAULT_TARGET_TRIPLE=${TRIPLE_TARGET}"
			"-DLLVM_HOST_TRIPLE=${TRIPLE_HOST}"
			"-DLLVM_CCACHE_BUILD=${USE_CCACHE}"
			"-DLLVM_ENABLE_LTO=${LLVM_LTO}"

			-DCLANG_LINK_CLANG_DYLIB=OFF
			-DCLANG_INCLUDE_DOCS=OFF
			-DCLANG_INCLUDE_TESTS=OFF

			-DLLVM_APPEND_VC_REV=OFF
			-DLLVM_BUILD_LLVM_DYLIB=OFF
			-DLLVM_BUILD_TESTS=OFF
			-DLLVM_BUILD_UTILS=OFF
			-DLLVM_ENABLE_ASSERTIONS=OFF
			-DLLVM_ENABLE_LIBCXX=OFF
			-DLLVM_ENABLE_LIBXML2=OFF
			-DLLVM_ENABLE_PROJECTS=clang
			-DLLVM_ENABLE_RUNTIMES=
			-DLLVM_ENABLE_Z3_SOLVER=OFF
			-DLLVM_ENABLE_ZLIB=OFF
			-DLLVM_ENABLE_ZSTD=OFF
			-DLLVM_INCLUDE_TESTS=OFF
			-DLLVM_INCLUDE_UTILS=OFF
			-DLLVM_INSTALL_TOOLCHAIN_ONLY=ON
			-DLLVM_INSTALL_UTILS=OFF
			-DLLVM_LINK_LLVM_DYLIB=OFF
			-DLLVM_USE_SYMLINKS=ON

			-DCLANG_TOOL_AMDGPU_ARCH_BUILD=OFF
			-DCLANG_TOOL_APINOTES_TEST_BUILD=OFF
			-DCLANG_TOOL_CLANG_CHECK_BUILD=OFF
			-DCLANG_TOOL_CLANG_DIFF_BUILD=OFF
			-DCLANG_TOOL_CLANG_EXTDEF_MAPPING_BUILD=OFF
			-DCLANG_TOOL_CLANG_FORMAT_BUILD=OFF
			-DCLANG_TOOL_CLANG_FUZZER_BUILD=OFF
			-DCLANG_TOOL_CLANG_IMPORT_TEST_BUILD=OFF
			-DCLANG_TOOL_CLANG_INSTALLAPI_BUILD=OFF
			-DCLANG_TOOL_CLANG_LINKER_WRAPPER_BUILD=OFF
			-DCLANG_TOOL_CLANG_NVLINK_WRAPPER_BUILD=OFF
			-DCLANG_TOOL_CLANG_OFFLOAD_BUNDLER_BUILD=OFF
			-DCLANG_TOOL_CLANG_OFFLOAD_PACKAGER_BUILD=OFF
			-DCLANG_TOOL_CLANG_REFACTOR_BUILD=OFF
			-DCLANG_TOOL_CLANG_REPL_BUILD=OFF
			-DCLANG_TOOL_CLANG_SCAN_DEPS_BUILD=OFF
			-DCLANG_TOOL_CLANG_SHLIB_BUILD=OFF
			-DCLANG_TOOL_CLANG_SYCL_LINKER_BUILD=OFF
			-DCLANG_TOOL_C_INDEX_TEST_BUILD=OFF
			-DCLANG_TOOL_DIAGTOOL_BUILD=OFF
			-DCLANG_TOOL_DICTIONARY_BUILD=OFF
			-DCLANG_TOOL_DRIVER_BUILD=ON
			-DCLANG_TOOL_HANDLE_CXX_BUILD=OFF
			-DCLANG_TOOL_HANDLE_LLVM_BUILD=OFF
			-DCLANG_TOOL_LIBCLANG_BUILD=OFF
			-DCLANG_TOOL_NVPTX_ARCH_BUILD=OFF
			-DCLANG_TOOL_SCAN_BUILD_BUILD=OFF
			-DCLANG_TOOL_SCAN_BUILD_PY_BUILD=OFF
			-DCLANG_TOOL_SCAN_VIEW_BUILD=OFF

			-DLLVM_TOOL_BOLT_BUILD=OFF
			-DLLVM_TOOL_BUGPOINT_BUILD=OFF
			-DLLVM_TOOL_BUGPOINT_PASSES_BUILD=OFF
			-DLLVM_TOOL_CLANG_BUILD=ON
			-DLLVM_TOOL_CLANG_TOOLS_EXTRA_BUILD=OFF
			-DLLVM_TOOL_COMPILER_RT_BUILD=OFF
			-DLLVM_TOOL_CROSS_PROJECT_TESTS_BUILD=OFF
			-DLLVM_TOOL_DRAGONEGG_BUILD=OFF
			-DLLVM_TOOL_DSYMUTIL_BUILD=OFF
			-DLLVM_TOOL_DXIL_DIS_BUILD=OFF
			-DLLVM_TOOL_FLANG_BUILD=OFF
			-DLLVM_TOOL_GOLD_BUILD=OFF
			-DLLVM_TOOL_LIBC_BUILD=OFF
			-DLLVM_TOOL_LIBCLC_BUILD=OFF
			-DLLVM_TOOL_LIBCXXABI_BUILD=OFF
			-DLLVM_TOOL_LIBCXX_BUILD=OFF
			-DLLVM_TOOL_LIBUNWIND_BUILD=OFF
			-DLLVM_TOOL_LLC_BUILD=OFF
			-DLLVM_TOOL_LLDB_BUILD=OFF
			-DLLVM_TOOL_LLD_BUILD=OFF
			-DLLVM_TOOL_LLI_BUILD=OFF
			-DLLVM_TOOL_LTO_BUILD=OFF
			-DLLVM_TOOL_MLIR_BUILD=OFF
			-DLLVM_TOOL_OBJ2YAML_BUILD=OFF
			-DLLVM_TOOL_OPENMP_BUILD=OFF
			-DLLVM_TOOL_OPT_BUILD=OFF
			-DLLVM_TOOL_OPT_VIEWER_BUILD=OFF
			-DLLVM_TOOL_POLLY_BUILD=OFF
			-DLLVM_TOOL_PSTL_BUILD=OFF
			-DLLVM_TOOL_REDUCE_CHUNK_LIST_BUILD=OFF
			-DLLVM_TOOL_REMARKS_SHLIB_BUILD=OFF
			-DLLVM_TOOL_SANCOV_BUILD=OFF
			-DLLVM_TOOL_SANSTATS_BUILD=OFF
			-DLLVM_TOOL_SPIRV_TOOLS_BUILD=OFF
			-DLLVM_TOOL_VERIFY_USELISTORDER_BUILD=OFF
			-DLLVM_TOOL_VFABI_DEMANGLE_FUZZER_BUILD=OFF
			-DLLVM_TOOL_XCODE_TOOLCHAIN_BUILD=OFF
			-DLLVM_TOOL_YAML2OBJ_BUILD=OFF

			-DLLVM_TOOL_LLVM_AR_BUILD=OFF
			-DLLVM_TOOL_LLVM_AS_BUILD=OFF
			-DLLVM_TOOL_LLVM_AS_FUZZER_BUILD=OFF
			-DLLVM_TOOL_LLVM_BCANALYZER_BUILD=OFF
			-DLLVM_TOOL_LLVM_CAT_BUILD=OFF
			-DLLVM_TOOL_LLVM_CFI_VERIFY_BUILD=OFF
			-DLLVM_TOOL_LLVM_CGDATA_BUILD=OFF
			-DLLVM_TOOL_LLVM_CONFIG_BUILD=OFF
			-DLLVM_TOOL_LLVM_COV_BUILD=OFF
			-DLLVM_TOOL_LLVM_C_TEST_BUILD=OFF
			-DLLVM_TOOL_LLVM_CTXPROF_UTIL_BUILD=OFF
			-DLLVM_TOOL_LLVM_CVTRES_BUILD=OFF
			-DLLVM_TOOL_LLVM_CXXDUMP_BUILD=OFF
			-DLLVM_TOOL_LLVM_CXXFILT_BUILD=OFF
			-DLLVM_TOOL_LLVM_CXXMAP_BUILD=OFF
			-DLLVM_TOOL_LLVM_DEBUGINFO_ANALYZER_BUILD=OFF
			-DLLVM_TOOL_LLVM_DEBUGINFOD_BUILD=OFF
			-DLLVM_TOOL_LLVM_DEBUGINFOD_FIND_BUILD=OFF
			-DLLVM_TOOL_LLVM_DIFF_BUILD=OFF
			-DLLVM_TOOL_LLVM_DIS_BUILD=OFF
			-DLLVM_TOOL_LLVM_DIS_FUZZER_BUILD=OFF
			-DLLVM_TOOL_LLVM_DLANG_DEMANGLE_FUZZER_BUILD=OFF
			-DLLVM_TOOL_LLVM_DRIVER_BUILD=OFF
			-DLLVM_TOOL_LLVM_DWARFDUMP_BUILD=OFF
			-DLLVM_TOOL_LLVM_DWARFUTIL_BUILD=OFF
			-DLLVM_TOOL_LLVM_DWP_BUILD=OFF
			-DLLVM_TOOL_LLVM_EXEGESIS_BUILD=OFF
			-DLLVM_TOOL_LLVM_EXTRACT_BUILD=OFF
			-DLLVM_TOOL_LLVM_GSYMUTIL_BUILD=OFF
			-DLLVM_TOOL_LLVM_IFS_BUILD=OFF
			-DLLVM_TOOL_LLVM_ISEL_FUZZER_BUILD=OFF
			-DLLVM_TOOL_LLVM_ITANIUM_DEMANGLE_FUZZER_BUILD=OFF
			-DLLVM_TOOL_LLVM_JITLINK_BUILD=OFF
			-DLLVM_TOOL_LLVM_JITLISTENER_BUILD=OFF
			-DLLVM_TOOL_LLVM_LIBTOOL_DARWIN_BUILD=OFF
			-DLLVM_TOOL_LLVM_LINK_BUILD=OFF
			-DLLVM_TOOL_LLVM_LIPO_BUILD=OFF
			-DLLVM_TOOL_LLVM_LTO2_BUILD=OFF
			-DLLVM_TOOL_LLVM_LTO_BUILD=OFF
			-DLLVM_TOOL_LLVM_MCA_BUILD=OFF
			-DLLVM_TOOL_LLVM_MC_ASSEMBLE_FUZZER_BUILD=OFF
			-DLLVM_TOOL_LLVM_MC_BUILD=OFF
			-DLLVM_TOOL_LLVM_MC_DISASSEMBLE_FUZZER_BUILD=OFF
			-DLLVM_TOOL_LLVM_MICROSOFT_DEMANGLE_FUZZER_BUILD=OFF
			-DLLVM_TOOL_LLVM_ML_BUILD=OFF
			-DLLVM_TOOL_LLVM_MODEXTRACT_BUILD=OFF
			-DLLVM_TOOL_LLVM_MT_BUILD=OFF
			-DLLVM_TOOL_LLVM_NM_BUILD=OFF
			-DLLVM_TOOL_LLVM_OBJCOPY_BUILD=OFF
			-DLLVM_TOOL_LLVM_OBJDUMP_BUILD=OFF
			-DLLVM_TOOL_LLVM_OPT_FUZZER_BUILD=OFF
			-DLLVM_TOOL_LLVM_OPT_REPORT_BUILD=OFF
			-DLLVM_TOOL_LLVM_PDBUTIL_BUILD=OFF
			-DLLVM_TOOL_LLVM_PROFDATA_BUILD=OFF
			-DLLVM_TOOL_LLVM_PROFGEN_BUILD=OFF
			-DLLVM_TOOL_LLVM_RC_BUILD=OFF
			-DLLVM_TOOL_LLVM_READOBJ_BUILD=OFF
			-DLLVM_TOOL_LLVM_READTAPI_BUILD=OFF
			-DLLVM_TOOL_LLVM_REDUCE_BUILD=OFF
			-DLLVM_TOOL_LLVM_REMARKUTIL_BUILD=OFF
			-DLLVM_TOOL_LLVM_RTDYLD_BUILD=OFF
			-DLLVM_TOOL_LLVM_RUST_DEMANGLE_FUZZER_BUILD=OFF
			-DLLVM_TOOL_LLVM_SHLIB_BUILD=OFF
			-DLLVM_TOOL_LLVM_SIM_BUILD=OFF
			-DLLVM_TOOL_LLVM_SIZE_BUILD=OFF
			-DLLVM_TOOL_LLVM_SPECIAL_CASE_LIST_FUZZER_BUILD=OFF
			-DLLVM_TOOL_LLVM_SPLIT_BUILD=OFF
			-DLLVM_TOOL_LLVM_STRESS_BUILD=OFF
			-DLLVM_TOOL_LLVM_STRINGS_BUILD=OFF
			-DLLVM_TOOL_LLVM_SYMBOLIZER_BUILD=OFF
			-DLLVM_TOOL_LLVM_TLI_CHECKER_BUILD=OFF
			-DLLVM_TOOL_LLVM_UNDNAME_BUILD=OFF
			-DLLVM_TOOL_LLVM_XRAY_BUILD=OFF
			-DLLVM_TOOL_LLVM_YAML_NUMERIC_PARSER_FUZZER_BUILD=OFF
			-DLLVM_TOOL_LLVM_YAML_PARSER_FUZZER_BUILD=OFF
		BUILD_COMMAND
			${CMAKE_COMMAND} -E env ${BUILD_ENV}
				${CMAKE_COMMAND} --build .
		INSTALL_COMMAND ${CMAKE_COMMAND} --install . --strip
	)

	add_dependencies(clang clang-binaries)

	# On Windows the base name is clang,
	# elsewhere it is clang-21 with a clang symlink.
	if (YOKAI_TARGET_SYSTEM_WINDOWS)
		set(CLANG_BASE_NAME "clang")
	else()
		set(CLANG_BASE_NAME "clang-${SAIGO_CLANG_VERSION}")

		list(APPEND clangPrefixToolNames
			"clang"
		)

		list(APPEND clangUselessFiles
			"bin/clang${CMAKE_EXECUTABLE_SUFFIX}"
		)
	endif()

	PrefixBinaryNames(clang
		"${CLANG_BASE_NAME}"
		"${SAIGO_SYSTEM_NAME}"
	)

	list(APPEND clangPrefixToolNames
		"clang++"
		"clang-cpp"
	)

	AddPrefixBinaryAliases(clang
		"${CLANG_BASE_NAME}"
		"${clangPrefixToolNames}"
		"${SAIGO_SYSTEM_NAME}"
	)

	set(clangToolNames
		"clang"
		"clang++"
	)

	AddBinaryAliases(clang
		"${clangToolNames}"
		"${SAIGO_SYSTEM_NAME}"
		"${SAIGO_ARCH_NAMES}"
	)

	list(APPEND clangUselessFiles
		"bin/clang++${CMAKE_EXECUTABLE_SUFFIX}"
		"bin/clang-cl${CMAKE_EXECUTABLE_SUFFIX}"
		"bin/clang-cpp${CMAKE_EXECUTABLE_SUFFIX}"
		"bin/hmaptool"
		"lib/cmake/llvm/LLVMConfigExtensions.cmake"
	)

	DeleteUselessFiles(clang "${clangUselessFiles}")
endif()

if (BUILD_BINUTILS)
	add_custom_target(binutils ALL)

	foreach(binutilsArchName IN ITEMS "x86" "arm")
		add_dependencies(binutils binutils-${binutilsArchName})

		string(TOUPPER "${binutilsArchName}" binutilsArchSlug)

		if (BUILD_BINUTILS_${binutilsArchSlug})
			list(APPEND binutilsArchNames "${binutilsArchName}")
		endif()
	endforeach()

	if (NOT "${binutilsArchNames}" STREQUAL "")
		list(APPEND BINUTILS_C_FLAGS ${EP_C_FLAGS})
		list(APPEND BINUTILS_EXE_LINKER_FLAGS ${EP_EXE_LINKER_FLAGS})

		EnableConfigureLTO("BINUTILS")

		ListToString("BINUTILS_C_FLAGS")
		ListToString("BINUTILS_EXE_LINKER_FLAGS")

		AddCompilerConfigureEnv("BINUTILS" "C")

		list(APPEND BINUTILS_ENV ${CONFIGURE_ENV} ${BUILD_ENV})

		list(APPEND BINUTILS_ARGS ${CONFIGURE_ARGS})
	endif()

	foreach(binutilsArchName IN LISTS binutilsArchNames)
		string(TOUPPER "${binutilsArchName}" binutilsArchSlug)

		set(binutilsArchName_x86 "x86_64")
		set(binutilsArchName_arm "arm")

		set(binutilsPrimaryArchName "${binutilsArchName_${binutilsArchName}}")
		set(binutilsPrimaryTarget "${binutilsPrimaryArchName}-nacl")

		if ("${binutilsArchName}" STREQUAL "x86")
			AddTargetConfigureArgs("BINUTILS_${binutilsArchSlug}")
		elseif ("${binutilsArchName}" STREQUAL "arm")
			list(APPEND "BINUTILS_${binutilsArchSlug}_ARGS"
				"--target=${binutilsPrimaryTarget}"
				"--enable-targets=${binutilsPrimaryTarget}"
				"--program-prefix=${binutilsPrimaryTarget}-"
			)
		endif()

		if ("${binutilsArchName}" STREQUAL "x86")
			set(INSTALL_TARGET "install-strip")
			set(POST_INSTALL_COMMAND
				${CMAKE_COMMAND} -E true
			)
		elseif ("${binutilsArchName}" STREQUAL "arm")
			set(INSTALL_TARGET "install")
			set(POST_INSTALL_COMMAND
				"${TRIPLE_STRIP}"
					"${CMAKE_INSTALL_PREFIX}/bin/${binutilsPrimaryTarget}-as${CMAKE_EXECUTABLE_SUFFIX}"
			)
		endif()

		ExternalProject_Add(binutils-${binutilsArchName}-binaries
			${EP_OPTIONS_BINUTILS_${binutilsArchSlug}}
			CONFIGURE_COMMAND
				"${SOURCE_DIR_BINUTILS_${binutilsArchSlug}}/configure"
					${BINUTILS_ENV}
					${BINUTILS_ARGS}
					${BINUTILS_${binutilsArchSlug}_ARGS}
					--disable-gdb
					--disable-gold
					--disable-plugins
					--disable-sim
					--without-zlib
			BUILD_COMMAND
				$(MAKE)
					${BINUTILS_ENV}
			INSTALL_COMMAND
				$(MAKE)
					${BINUTILS_ENV}
					"DESTDIR=${CMAKE_INSTALL_PREFIX}"
					"${INSTALL_TARGET}"
				&& ${POST_INSTALL_COMMAND}
		)

		add_dependencies(binutils-${binutilsArchName} binutils-${binutilsArchName}-binaries)
		add_dependencies(binutils binutils-${binutilsArchName})

		if ("${binutilsArchName}" STREQUAL "x86")
			set(binutilsToolNames
				"ar"
				"nm"
				"ranlib"
				"strip"
			)

			AddBinaryAliases(binutils-${binutilsArchName}
				"${binutilsToolNames}"
				"${SAIGO_SYSTEM_NAME}"
				"${SAIGO_ARCH_NAMES}"
			)

			# Make sure those aliases for executables from binutils-x86
			# never replace the executables from binutils-arm.
			add_custom_target(binutils-${binutilsArchName}-x86-binaries)
			add_dependencies(binutils-${binutilsArchName}-x86-binaries binutils-${binutilsArchName}-binaries)
			add_custom_target(binutils-${binutilsArchName}-x86)
			add_dependencies(binutils-${binutilsArchName}-x86 binutils-${binutilsArchName}-x86-binaries)

			set(binutilsX86OnlyToolNames
				"ld"
				"as"
			)

			AddBinaryAliases(binutils-${binutilsArchName}-x86
				"${binutilsX86OnlyToolNames}"
				"${SAIGO_SYSTEM_NAME}"
				"${binutilsPrimaryArchName};i686"
			)
		endif()

		set(binutilsDirectoryToolNames
			"ld"
			"as"
		)

		AddDirectoryBinaryAliases(binutils-${binutilsArchName}
			"${binutilsDirectoryToolNames}"
			"${SAIGO_SYSTEM_NAME}"
			"${binutilsPrimaryArchName}"
		)

		if ("${binutilsArchName}" STREQUAL "arm")
			AddDirectoryAliases(binutils-${binutilsArchName}
				"${SAIGO_SYSTEM_NAME}"
				"${SAIGO_PRIMARY_ARCH_NAME}"
				"${binutilsPrimaryArchName}"
			)
		endif()

		if ("${binutilsArchName}" STREQUAL "x86")
			set(BINUTILS_TARGET_PREFIX "${CMAKE_INSTALL_PREFIX}/${binutilsPrimaryTarget}")

			add_custom_target(binutils-${binutilsArchName}-lib64-alias
				ALL
				COMMAND
					${CMAKE_COMMAND} -E make_directory
						"${BINUTILS_TARGET_PREFIX}"
				COMMAND
					${CMAKE_COMMAND} -E remove_directory
						"${BINUTILS_TARGET_PREFIX}/lib64"
				COMMAND
					${CMAKE_COMMAND} -E create_symlink
						lib "${BINUTILS_TARGET_PREFIX}/lib64"
				DEPENDS binutils-${binutilsArchName}-binaries
			)

			add_dependencies(binutils-${binutilsArchName}-aliases binutils-${binutilsArchName}-lib64-alias)
		endif()

		set(binutilsDeleteTargetPrefix_x86 "${SAIGO_SYSTEM_NAME}")
		set(binutilsDeleteTargetPrefix_arm "${binutilsPrimaryTarget}")

		set(binutilsDeleteTargetPrefix "${binutilsDeleteTargetPrefix_${binutilsArchName}}")

		set(binutilsUselessFiles
			# This is the same as ld, just there for -fuse-ld=* to not use the default
			# linker but bfd is already the default and the only option so no one
			# has any reason to set -fuse-ld=bfd to switch from bfd to bfd.
			"bin/${binutilsDeleteTargetPrefix}-ld.bfd${CMAKE_EXECUTABLE_SUFFIX}"
		)

		if ("${binutilsArchName}" STREQUAL "arm")
			list(APPEND binutilsUselessFiles
				"bin/${binutilsDeleteTargetPrefix}-addr2line${CMAKE_EXECUTABLE_SUFFIX}"
				"bin/${binutilsDeleteTargetPrefix}-c++filt${CMAKE_EXECUTABLE_SUFFIX}"
				"bin/${binutilsDeleteTargetPrefix}-elfedit${CMAKE_EXECUTABLE_SUFFIX}"
				"bin/${binutilsDeleteTargetPrefix}-gprof${CMAKE_EXECUTABLE_SUFFIX}"
				"bin/${binutilsDeleteTargetPrefix}-objcopy${CMAKE_EXECUTABLE_SUFFIX}"
				"bin/${binutilsDeleteTargetPrefix}-objdump${CMAKE_EXECUTABLE_SUFFIX}"
				"bin/${binutilsDeleteTargetPrefix}-readelf${CMAKE_EXECUTABLE_SUFFIX}"
				"bin/${binutilsDeleteTargetPrefix}-size${CMAKE_EXECUTABLE_SUFFIX}"
				"bin/${binutilsDeleteTargetPrefix}-strings${CMAKE_EXECUTABLE_SUFFIX}"
			)
		endif()

		list(APPEND binutilsUselessFiles
			"share/info/as.info"
			"share/info/bfd.info"
			"share/info/binutils.info"
			"share/info/configure.info"
			"share/info/dir"
			"share/info/gprof.info"
			"share/info/ld.info"
			"share/info/standards.info"
			"share/man/man1/${binutilsDeleteTargetPrefix}-addr2line.1"
			"share/man/man1/${binutilsDeleteTargetPrefix}-ar.1"
			"share/man/man1/${binutilsDeleteTargetPrefix}-as.1"
			"share/man/man1/${binutilsDeleteTargetPrefix}-c++filt.1"
			"share/man/man1/${binutilsDeleteTargetPrefix}-dlltool.1"
			"share/man/man1/${binutilsDeleteTargetPrefix}-elfedit.1"
			"share/man/man1/${binutilsDeleteTargetPrefix}-gprof.1"
			"share/man/man1/${binutilsDeleteTargetPrefix}-ld.1"
			"share/man/man1/${binutilsDeleteTargetPrefix}-nlmconv.1"
			"share/man/man1/${binutilsDeleteTargetPrefix}-nm.1"
			"share/man/man1/${binutilsDeleteTargetPrefix}-objcopy.1"
			"share/man/man1/${binutilsDeleteTargetPrefix}-objdump.1"
			"share/man/man1/${binutilsDeleteTargetPrefix}-ranlib.1"
			"share/man/man1/${binutilsDeleteTargetPrefix}-readelf.1"
			"share/man/man1/${binutilsDeleteTargetPrefix}-size.1"
			"share/man/man1/${binutilsDeleteTargetPrefix}-strings.1"
			"share/man/man1/${binutilsDeleteTargetPrefix}-strip.1"
			"share/man/man1/${binutilsDeleteTargetPrefix}-windmc.1"
			"share/man/man1/${binutilsDeleteTargetPrefix}-windres.1"
			"${binutilsPrimaryTarget}/bin/ar${CMAKE_EXECUTABLE_SUFFIX}"
			"${binutilsPrimaryTarget}/bin/ld.bfd${CMAKE_EXECUTABLE_SUFFIX}"
			"${binutilsPrimaryTarget}/bin/nm${CMAKE_EXECUTABLE_SUFFIX}"
			"${binutilsPrimaryTarget}/bin/objcopy${CMAKE_EXECUTABLE_SUFFIX}"
			"${binutilsPrimaryTarget}/bin/objdump${CMAKE_EXECUTABLE_SUFFIX}"
			"${binutilsPrimaryTarget}/bin/ranlib${CMAKE_EXECUTABLE_SUFFIX}"
			"${binutilsPrimaryTarget}/bin/strip${CMAKE_EXECUTABLE_SUFFIX}"
		)

		DeleteUselessFiles(binutils-${binutilsArchName} "${binutilsUselessFiles}")
	endforeach()

	if (BUILD_BINUTILS_X86 AND BUILD_BINUTILS_ARM)
		# Make sure aliases for the reusable executables from binutils-x86
		# replace the executables from binutils-arm.
		add_dependencies(binutils-x86-aliases binutils-arm-binaries)
	endif()
endif()

if (BUILD_GDB)
	list(APPEND GDB_C_FLAGS ${EP_C_FLAGS})
	list(APPEND GDB_EXE_LINKER_FLAGS ${EP_EXE_LINKER_FLAGS})

	AddCompilerFlags("GDB" "C"
		"-fcommon"
	)

	EnableConfigureLTO("GDB")

	AddCompilerDefinitions("GDB" "-D_GNU_SOURCE")

	AddCompilerConfigureEnv("GDB" "C")

	list(APPEND GDB_ENV ${CONFIGURE_ENV} ${BUILD_ENV})

	AddTargetConfigureArgs("GDB")

	list(APPEND GDB_ARGS ${CONFIGURE_ARGS})

	if (YOKAI_TARGET_SYSTEM_WINDOWS)
		list(APPEND GDB_ARGS "--disable-win32-registry")
	endif()

	if (NOT YOKAI_TARGET_SYSTEM_WINDOWS)
		list(APPEND GDB_ARGS "--with-mini-termcap")
	endif()

	# There is no working install-strip target.
	# The gdbserver cannot be built when nacl targets are set.
	ExternalProject_Add(gdb-binaries
		${EP_OPTIONS_GDB}
		CONFIGURE_COMMAND
			"${SOURCE_DIR_GDB}/configure"
				${GDB_ENV}
				${GDB_ARGS}
				--disable-gdbserver
				--without-python
				--without-lzma
				--disable-sim
				--disable-tui
				--without-expat
				--without-zlib
		BUILD_COMMAND
			$(MAKE)
				${GDB_ENV}
		INSTALL_COMMAND
			$(MAKE)
				${GDB_ENV}
				"DESTDIR=${CMAKE_INSTALL_PREFIX}"
				install
			&& "${TRIPLE_STRIP}"
				"${CMAKE_INSTALL_PREFIX}/bin/nacl-gdb${CMAKE_EXECUTABLE_SUFFIX}"
	)

	add_dependencies(gdb gdb-binaries)

	set(gdbUselessFiles
		"include/gdb/jit-reader.h"
		"share/gdb/python/gdb/command/bound_registers.py"
		"share/gdb/python/gdb/command/explore.py"
		"share/gdb/python/gdb/command/frame_filters.py"
		"share/gdb/python/gdb/command/__init__.py"
		"share/gdb/python/gdb/command/pretty_printers.py"
		"share/gdb/python/gdb/command/prompt.py"
		"share/gdb/python/gdb/command/type_printers.py"
		"share/gdb/python/gdb/FrameDecorator.py"
		"share/gdb/python/gdb/FrameIterator.py"
		"share/gdb/python/gdb/frames.py"
		"share/gdb/python/gdb/function/__init__.py"
		"share/gdb/python/gdb/function/strfns.py"
		"share/gdb/python/gdb/__init__.py"
		"share/gdb/python/gdb/printing.py"
		"share/gdb/python/gdb/prompt.py"
		"share/gdb/python/gdb/types.py"
		"share/gdb/syscalls/amd64-linux.xml"
		"share/gdb/syscalls/arm-linux.xml"
		"share/gdb/syscalls/gdb-syscalls.dtd"
		"share/gdb/syscalls/i386-linux.xml"
		"share/gdb/syscalls/mips-n32-linux.xml"
		"share/gdb/syscalls/mips-n64-linux.xml"
		"share/gdb/syscalls/mips-o32-linux.xml"
		"share/gdb/syscalls/ppc64-linux.xml"
		"share/gdb/syscalls/ppc-linux.xml"
		"share/gdb/syscalls/sparc64-linux.xml"
		"share/gdb/syscalls/sparc-linux.xml"
		"share/gdb/system-gdbinit/elinos.py"
		"share/gdb/system-gdbinit/wrs-linux.py"
		"share/info/dir"
		"share/info/annotate.info"
		"share/info/bfd.info"
		"share/info/configure.info"
		"share/info/gdb.info"
		"share/info/gdb.info-1"
		"share/info/gdb.info-2"
		"share/info/gdb.info-3"
		"share/info/gdb.info-4"
		"share/info/gdb.info-5"
		"share/info/gdb.info-6"
		"share/info/gdb.info-7"
		"share/info/stabs.info"
		"share/info/standards.info"
		"share/man/man1/gdb.1"
		"share/man/man1/gdbserver.1"
		"share/man/man5/gdbinit.5"
	)

	DeleteUselessFiles(gdb "${gdbUselessFiles}")
endif()

if (BUILD_NACL)
	option(BUILD_NACL_INCLUDE "Build the nacl include." ON)
endif()

if (BUILD_NACL AND BUILD_NACL_INCLUDE)
	set(src_lib "${SOURCE_DIR_NACL}/pnacl/support/clang_direct")
	set(dst_lib "${CMAKE_INSTALL_PREFIX}/arm-nacl/lib")

	set(src_include "${SOURCE_DIR_NACL}/src/include/nacl")
	set(dst_include "${CMAKE_INSTALL_PREFIX}/x86_64-nacl/include/nacl")

	set(lib_file_list
		"nacl-arm-macros.s"
	)

	set(include_file_list
		"nacl_exception.h"
		"nacl_minidump.h"
		"simd.h"
	)

	set(include_command
		${CMAKE_COMMAND} -E true
	)

	foreach(kind IN ITEMS lib include)
		list(APPEND include_command
			&& ${CMAKE_COMMAND} -E make_directory "${dst_${kind}}"
		)

		foreach(${kind}_file IN LISTS ${kind}_file_list)
			list(APPEND include_command
				&& ${CMAKE_COMMAND} -E copy_if_different
					"${src_${kind}}/${${kind}_file}" "${dst_${kind}}/${${kind}_file}"
			)
		endforeach()
	endforeach()

	ExternalProject_Add(nacl-include
		${EP_OPTIONS_NACL}
		CONFIGURE_COMMAND echo
		BUILD_COMMAND echo
		INSTALL_COMMAND ${include_command}
	)
endif()

if (BUILD_SAIGOLIBS)
	# x86_64-nacl/include and arm-nacl/include are exactly the same
	# but exactly one header more in x86_64-nacl/include:
	#   dynamic_annotations.h
	# x86_64-nacl/share and arm-nacl/share are exactly the same

	add_custom_target(saigolibs-arm-core-alias
		ALL
		COMMAND
			${CMAKE_COMMAND} -E remove_directory
				"${CMAKE_INSTALL_PREFIX}/arm-nacl/include"
		COMMAND
			${CMAKE_COMMAND} -E create_symlink
				"../x86_64-nacl/include" "${CMAKE_INSTALL_PREFIX}/arm-nacl/include"
		DEPENDS saigolibs-x86_64-core-binaries saigolibs-arm-core-binaries
			saigolibs-x86_64-libcxx-binaries saigolibs-arm-libcxx-binaries
	)

	add_custom_target(saigolibs-arm-libcxx-alias
		ALL
		COMMAND
			${CMAKE_COMMAND} -E remove_directory
				"${CMAKE_INSTALL_PREFIX}/arm-nacl/share"
		COMMAND
			${CMAKE_COMMAND} -E create_symlink
				"../x86_64-nacl/share" "${CMAKE_INSTALL_PREFIX}/arm-nacl/share"
		DEPENDS saigolibs-x86_64-libcxx-binaries saigolibs-arm-libcxx-binaries
	)

	add_custom_target(saigolibs-aliases)
	add_dependencies(saigolibs saigolibs-aliases)
	add_dependencies(saigolibs-aliases saigolibs-arm-core-alias)
	add_dependencies(saigolibs-aliases saigolibs-arm-libcxx-alias)
endif()

# This intentionally do not delete `${CMAKE_INSTALL_PREFIX}` but the
# unmodified `${CMAKE_CURRENT_BINARY_DIR}/install` default value we set
# ourselves, and will then fail to delete the directory when customized,
# just in case someone does: `cmake -DCMAKE_INSTALL_PREFIX=/usr`…
add_custom_target(distclean
    COMMAND
		${CMAKE_COMMAND} -E remove_directory
			"${CMAKE_CURRENT_BINARY_DIR}/install"
	COMMAND
		${CMAKE_COMMAND} --build "${CMAKE_CURRENT_BINARY_DIR}" --target clean
)
