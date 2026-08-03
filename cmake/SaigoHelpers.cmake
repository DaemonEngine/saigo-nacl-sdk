macro(FindTool SLUG FILE NAME ENABLEMENT)
	set("DEFAULT_${SLUG}" "${ENABLEMENT}")

	find_program(PATH_${SLUG} NAMES "${FILE}")

	if (NOT PATH_${SLUG})
		set("DEFAULT_${SLUG}" OFF)
	endif()

	option("USE_${SLUG}" "Enable ${NAME} when possible." "${DEFAULT_${SLUG}}")

	if (PATH_${SLUG})
		if (USE_${SLUG})
			message(STATUS "${NAME} available and used")
		else()
			message(STATUS "${NAME} available but not used")
		endif()
	else()
		message(STATUS "${NAME} not available")
	endif()
endmacro()

macro(ListToString NAME)
	list(JOIN ${NAME} " " ${NAME}_STRING)
endmacro()

macro(AddGitProject NAME DIR URL TAG)
	string(TOUPPER "${NAME}" SLUG)
	string(REPLACE "-" "_" SLUG "${SLUG}")
	set(GIT_REPOSITORY_${SLUG} "${URL}" CACHE STRING "${NAME} git repository location.")
	mark_as_advanced(GIT_REPOSITORY_${SLUG})

	set(REPOSITORY_DIR_${SLUG} "${DIR}")
	set(REPOSITORY_TAG_${SLUG} "${TAG}")

	if (CLONE_SHARED_REPOSITORIES)
		option(CLONE_${SLUG} "Clone the ${NAME} repository." ON)

		if (CLONE_${SLUG})
			set(patch_list "${ARGN}")

			if (patch_list)
				list(APPEND PATCH_${SLUG}
					git reset --hard "${REPOSITORY_TAG_${SLUG}}")

				foreach(patch_file IN LISTS patch_list)
					list(APPEND PATCH_${SLUG}
						&& git am "${CMAKE_SOURCE_DIR}/patches/${DIR}/${patch_file}")
				endforeach()

				list(APPEND PATCH_${SLUG}
					&& git rebase --committer-date-is-author-date "${REPOSITORY_TAG_${SLUG}}")
			else()
				set(PATCH_${SLUG} echo)
			endif()

			ExternalProject_Add("${REPOSITORY_DIR_${SLUG}}-shared-repository"
				SOURCE_DIR "${DIR}"
				GIT_REPOSITORY "${GIT_REPOSITORY_${SLUG}}"
				GIT_TAG "${TAG}"
				PATCH_COMMAND "${PATCH_${SLUG}}"
				CONFIGURE_COMMAND echo
				BUILD_COMMAND echo
				INSTALL_COMMAND echo
			)
		endif()
	else()
		option(BUILD_${SLUG} "Build the ${NAME}." ON)

		if (BUILD_${SLUG})
			add_custom_target("${NAME}" ALL)
		endif()
	endif()

	if (SHARED_REPOSITORIES_DIR)
		set(SOURCE_DIR_${SLUG} "${SHARED_REPOSITORIES_DIR}/${DIR}")

		set(EP_OPTIONS_${SLUG}
			SOURCE_DIR "${SOURCE_DIR_${SLUG}}"
		)
	else()
		set(EP_SOURCE_DIR_${SLUG} "${EXTERNAL_PROJECT_SOURCES_DIR}/${DIR}")
		set(SOURCE_DIR_${SLUG} "${CMAKE_BINARY_DIR}/${EP_SOURCE_DIR_${SLUG}}")
		set(REPOSITORY_${SLUG} "${GIT_REPOSITORY_${SLUG}}")

		set(EP_OPTIONS_${SLUG}
			SOURCE_DIR "${EP_SOURCE_DIR_${SLUG}}"
			GIT_REPOSITORY "${REPOSITORY_${SLUG}}"
			GIT_TAG "${REPOSITORY_TAG_${SLUG}}"
			PATCH_COMMAND "${PATCH_${SLUG}}"
		)
	endif()
endmacro()

macro(AddTarProject PARENT_NAME NAME SUBDIR URL)
	string(TOUPPER "${PARENT_NAME}" PARENT_SLUG)
	string(TOUPPER "${NAME}" SLUG)
	set(TARGET_SLUG "${PARENT_SLUG}_${SLUG}")
	set(TARGET_NAME "${PARENT_NAME}-${NAME}")

	if (NOT DEFINED BUILD_${PARENT_SLUG})
		option(BUILD_${PARENT_SLUG} "Build the ${PARENT_NAME}." "${DEFAULT_BUILD}")
	endif()

	if (BUILD_${PARENT_SLUG})
		if (NOT TARGET "${PARENT_NAME}")
			add_custom_target("${PARENT_NAME}" ALL)
		endif()
	endif()

	set(DIR "${TARGET_NAME}")
	set(SUBDIR_${TARGET_SLUG} "${SUBDIR}")

	set(TARBALL_${TARGET_SLUG} ${URL} CACHE STRING "${TARGET_NAME} repository.")
	mark_as_advanced(TARBALL_${TARGET_SLUG})

	if (SHARED_REPOSITORIES_DIR)
		set(SOURCE_DIR_${TARGET_SLUG} "${SHARED_REPOSITORIES_DIR}/${DIR}")
	else()
		set(SOURCE_DIR_${TARGET_SLUG} "${EXTERNAL_PROJECT_SOURCES_DIR}/${DIR}")
	endif()

	if (CLONE_SHARED_REPOSITORIES)
		option(CLONE_${TARGET_SLUG} "Clone the ${TARGET_NAME}." ON)

		if (CLONE_${TARGET_SLUG})
			ExternalProject_Add("${TARGET_NAME}-directory"
				URL "${URL}"
				SOURCE_DIR "${SOURCE_DIR_${TARGET_SLUG}}"
				CONFIGURE_COMMAND echo
				BUILD_COMMAND echo
				INSTALL_COMMAND echo
				DOWNLOAD_EXTRACT_TIMESTAMP ON
			)
		endif()
	else()
		option(BUILD_${TARGET_SLUG} "Build the ${TARGET_NAME}." ON)
	endif()

	if (SHARED_REPOSITORIES_DIR)
		set(SOURCE_DIR_${TARGET_SLUG} ${SHARED_REPOSITORIES_DIR}/${DIR})

		set(EP_OPTIONS_${TARGET_SLUG}
			SOURCE_DIR "${SOURCE_DIR_${TARGET_SLUG}}"
		)
	else()
		set(EP_SOURCE_DIR_${TARGET_SLUG} ${EXTERNAL_PROJECT_SOURCES_DIR}/${DIR})
		set(SOURCE_DIR_${TARGET_SLUG} "${CMAKE_BINARY_DIR}/${EP_SOURCE_DIR_${SLUG}}")

		set(EP_OPTIONS_${TARGET_SLUG}
			SOURCE_DIR "${EP_SOURCE_DIR_${TARGET_SLUG}}"
			URL "${URL}"
		)
	endif()

	if (BUILD_${PARENT_SLUG} AND BUILD_${TARGET_SLUG})
		ExternalProject_Add("${TARGET_NAME}-binaries"
			${EP_OPTIONS_${TARGET_SLUG}}
			CONFIGURE_COMMAND echo
			BUILD_COMMAND echo
			INSTALL_COMMAND
				${CMAKE_COMMAND} -E make_directory
					"${CMAKE_INSTALL_PREFIX}/${SUBDIR_${TARGET_SLUG}}"
			COMMAND
				${CMAKE_COMMAND} -E copy_directory
					"${SOURCE_DIR_${TARGET_SLUG}}"
					"${CMAKE_INSTALL_PREFIX}/${SUBDIR_${TARGET_SLUG}}"
			DOWNLOAD_EXTRACT_TIMESTAMP ON
		)

		add_dependencies(${PARENT_NAME} ${TARGET_NAME}-binaries)
	endif()
endmacro()

function(PrefixBinaryNames targetName toolNames systemName)
	set(renamesName ${targetName}-${systemName}-${targetName}-renames)
	add_custom_target(${renamesName} ALL)
	add_dependencies(${targetName} ${renamesName})
	add_dependencies(${renamesName} ${targetName}-binaries)

	foreach(toolName ${toolNames})
		set(oldPath "${toolName}${CMAKE_EXECUTABLE_SUFFIX}")
		set(newFile "${systemName}-${toolName}")
		set(newPath "${newFile}${CMAKE_EXECUTABLE_SUFFIX}")
		set(renameName "${targetName}-${newFile}")

		add_custom_target(${renameName}
			COMMAND
				${CMAKE_COMMAND}
					"-DOLD_FILE=${CMAKE_INSTALL_PREFIX}/bin/${oldPath}"
					"-DNEW_FILE=${CMAKE_INSTALL_PREFIX}/bin/${newPath}"
					-P "${CMAKE_SOURCE_DIR}/cmake/SaigoRenameWhenNeeded.cmake"
			DEPENDS ${targetName}-binaries
			VERBATIM
		)

		add_dependencies(${renamesName} ${renameName})
	endforeach()
endfunction()

function(AddPrefixBinaryAliases targetName referenceName toolNames systemName)
	set(renamesName ${targetName}-${targetPrefix}${targetName}-aliases)
	add_custom_target(${renamesName} ALL)
	add_dependencies(${targetName} ${renamesName})
	add_dependencies(${renamesName} ${targetName}-binaries)

	foreach(toolName ${toolNames})
		set(referencePath "${systemName}-${referenceName}${CMAKE_EXECUTABLE_SUFFIX}")
		set(aliasFile "${systemName}-${toolName}")
		set(aliasName "${targetName}-${aliasFile}")
		set(aliasPath "${CMAKE_INSTALL_PREFIX}/bin/${aliasFile}${CMAKE_EXECUTABLE_SUFFIX}")

		add_custom_target(${aliasName}
			ALL
			COMMAND
				${CMAKE_COMMAND} -E remove
					"${aliasPath}"
			COMMAND
				${CMAKE_COMMAND} -E create_symlink
					"${referencePath}" "${aliasPath}"
			DEPENDS ${targetName}-binaries
		)

		add_dependencies(${targetName} ${aliasName})
	endforeach()
endfunction()

function(AddBinaryAliases targetName toolNames systemName archNames)
	set(aliasesName ${targetName}-aliases)
	add_custom_target(${aliasesName} ALL)
	add_dependencies(${targetName} ${aliasesName})
	add_dependencies(${aliasesName} ${targetName}-binaries)

	foreach(archName ${archNames})
		foreach(toolName ${toolNames})
			set(referencePath "${systemName}-${toolName}${CMAKE_EXECUTABLE_SUFFIX}")
			set(aliasFile "${archName}-${systemName}-${toolName}")
			set(aliasPath "${CMAKE_INSTALL_PREFIX}/bin/${aliasFile}${CMAKE_EXECUTABLE_SUFFIX}")
			set(aliasName "${targetName}-${aliasFile}")

			add_custom_target(${aliasName}
				ALL
				COMMAND
					${CMAKE_COMMAND} -E remove
						"${aliasPath}"
				COMMAND
					${CMAKE_COMMAND} -E create_symlink
						"${referencePath}" "${aliasPath}"
				DEPENDS ${targetName}-binaries
			)

			add_dependencies(${aliasesName} ${aliasName})
		endforeach()
	endforeach()
endfunction()

function(AddDirectoryBinaryAliases targetName toolNames systemName primaryArchName)
	set(aliasesName ${targetName}-directory-binary-aliases)
	add_custom_target(${aliasesName} ALL)
	add_dependencies(${targetName} ${aliasesName})
	add_dependencies(${aliasesName} ${targetName}-binaries)

	set(referenceName "${primaryArchName}-${systemName}")

	foreach(toolName ${toolNames})
		set(toolPath "${CMAKE_INSTALL_PREFIX}/${referenceName}/bin/${toolName}${CMAKE_EXECUTABLE_SUFFIX}")
		set(referencePath "../../bin/${systemName}-${toolName}${CMAKE_EXECUTABLE_SUFFIX}")

		add_custom_target(${targetName}-${toolName}-alias
			ALL
			COMMAND
				${CMAKE_COMMAND} -E remove
					"${toolPath}"
			COMMAND
				${CMAKE_COMMAND} -E create_symlink
					"${referencePath}" "${toolPath}"
			DEPENDS ${targetName}-binaries
		)

		add_dependencies(${aliasesName} ${targetName}-${toolName}-alias)
	endforeach()
endfunction()

function(AddDirectoryAliases targetName systemName primaryArchName archNames)
	set(aliasesName ${targetName}-directory-aliases)
	add_custom_target(${aliasesName} ALL)
	add_dependencies(${targetName} ${aliasesName})
	add_dependencies(${aliasesName} ${targetName}-binaries)

	set(referenceName "${primaryArchName}-${systemName}")

	foreach(archName ${archNames})
		set(aliasDir "${archName}-${systemName}")
		set(aliasPath "${CMAKE_INSTALL_PREFIX}/${aliasDir}")
		set(aliasName "${targetName}-${aliasDir}")

		add_custom_target(${aliasName}-directory
			ALL
			COMMAND 
				${CMAKE_COMMAND} -E make_directory
					"${aliasPath}"
			DEPENDS ${targetName}-binaries
		)

		add_dependencies(${aliasesName} ${aliasName}-directory)

		add_custom_target(${aliasName}-bin-directory
			ALL
			COMMAND
				${CMAKE_COMMAND} -E remove_directory
					"${aliasPath}/bin"
			COMMAND
				${CMAKE_COMMAND} -E create_symlink
					"../${referenceName}/bin" "${aliasPath}/bin"
			DEPENDS ${aliasName}-directory
		)

		add_dependencies(${aliasesName} ${aliasName}-bin-directory)

		add_custom_target(${aliasName}-lib-directory
			ALL
			COMMAND
				${CMAKE_COMMAND} -E make_directory
					"${aliasPath}/lib"
			DEPENDS ${aliasName}-directory
		)

		add_dependencies(${aliasesName} ${aliasName}-lib-directory)

		add_custom_target(${aliasName}-ldscripts-directory
			ALL
			COMMAND
				${CMAKE_COMMAND} -E remove_directory
					"${aliasPath}/lib/ldscripts"
			COMMAND
				${CMAKE_COMMAND} -E create_symlink
					"../../${referenceName}/lib/ldscripts" "${aliasPath}/lib/ldscripts"
			DEPENDS ${aliasName}-lib-directory
		)

		add_dependencies(${aliasesName} ${aliasName}-ldscripts-directory)
	endforeach()
endfunction()

function(DeleteUselessFiles targetName filePaths)
	foreach(filePath IN LISTS filePaths)
		list(APPEND deleteCommands
			COMMAND
				${CMAKE_COMMAND} -E remove "${CMAKE_INSTALL_PREFIX}/${filePath}"
		)
	endforeach()

	set(deletesName ${targetName}-deletes)

	add_custom_target(${deletesName}
		ALL
		${deleteCommands}
		DEPENDS ${targetName}-binaries
	)

	add_dependencies(${targetName} ${deletesName})
endfunction()

macro(AddCompilerFlags NAME LANGS)
	foreach(LANG IN ITEMS ${LANGS})
		foreach(FLAG IN ITEMS ${ARGN})
			string(TOUPPER "FLAG_${FLAG}" FLAG_SLUG)
			string(REGEX REPLACE "[^A-Z0-9]" "_" FLAG_SLUG "${FLAG_SLUG}")
			string(REGEX REPLACE "_+" "_" FLAG_SLUG "${FLAG_SLUG}")

			if ("${${FLAG_SLUG}}" STREQUAL "")
				check_compiler_flag("${LANG}" "${FLAG}" ${FLAG_SLUG})
			endif()

			if (${FLAG_SLUG})
				list(APPEND ${NAME}_${LANG}_FLAGS "${FLAG}")
			endif()
		endforeach()
	endforeach()
endmacro()

macro(AddCompilerDefinitions NAME)
	foreach(FLAG IN ITEMS ${ARGN})
		list(APPEND ${NAME}_DEFINITIONS ${FLAG})
	endforeach()
endmacro()

macro(AddConfigureEnv NAME)
	foreach(VAR IN ITEMS ${ARGN})
		list(APPEND ${NAME}_ENV "${VAR}")
	endforeach()
endmacro()

macro(AddToolConfigureEnv NAME VALUE)
	AddConfigureEnv("CONFIGURE" "${NAME}=${VALUE}")
endmacro()

macro(AddTripleToolConfigureEnv NAME PATH)
	find_program(PATH_TRIPLE_${NAME} NAMES "${TRIPLE_HOST}-${PATH}")

	if (PATH_TRIPLE_${NAME})
		set(TRIPLE_${NAME} "${PATH_TRIPLE_${NAME}}")
	else()
		set(TRIPLE_${NAME} "${PATH}")
	endif()

	AddToolConfigureEnv("${NAME}" "${TRIPLE_${NAME}}")
endmacro()

macro(EnableConfigureLTO NAME)
	if (USE_LTO)
		list(APPEND ${NAME}_C_FLAGS ${LTO_FLAGS})

		if (YOKAI_C_COMPILER_MINGW)
			AddCompilerDefinitions("${NAME}" "-Dffs=__builtin_ffs")
		endif()

		list(APPEND ${NAME}_EXE_LINKER_FLAGS ${${NAME}_CFLAGS})
	endif()
endmacro()

macro(AddCompilerConfigureEnv NAME LANGS)
	ListToString("${NAME}_DEFINITIONS")

	foreach(LANG IN ITEMS ${LANGS})
		list(APPEND ${NAME}_${LANG}_FLAGS ${MOLD_COMPILER_FLAGS} ${${NAME}_DEFINITIONS})

		ListToString("${NAME}_${LANG}_FLAGS")

		AddConfigureEnv("${NAME}" "CFLAGS=${${NAME}_${LANG}_FLAGS_STRING}")
	endforeach()

	list(APPEND ${NAME}_EXE_LINKER_FLAGS ${MOLD_EXE_LINKER_FLAGS})

	ListToString("${NAME}_EXE_LINKER_FLAGS")

	AddConfigureEnv("${NAME}" "LDFLAGS=${${NAME}_EXE_LINKER_FLAGS_STRING}")
endmacro()

macro(AddTargetConfigureArgs NAME)
	list(APPEND ${NAME}_ARGS
			"--target=${TRIPLE_TARGET}"
			"--enable-targets=${CONFIGURE_TRIPLE_TARGETS}"
			"--program-prefix=${CONFIGURE_PROGRAM_PREFIX}"
	)
endmacro()

macro(AddCompilerCmakeArgs NAME LANGS)
	foreach(LANG IN ITEMS ${LANGS})
		list(APPEND ${NAME}_${LANG}_FLAGS ${EP_${LANG}_FLAGS} ${MOLD_COMPILER_FLAGS})

		ListToString(${NAME}_${LANG}_FLAGS)

		list(APPEND ${NAME}_ARGS 
			"-DCMAKE_${LANG}_COMPILER_LAUNCHER=${EP_COMPILER_LAUNCHER}"
			"-DCMAKE_${LANG}_COMPILER=${EP_${LANG}_COMPILER}"
			"-DCMAKE_${LANG}_FLAGS=${${NAME}_${LANG}_FLAGS_STRING}"
		)
	endforeach()

	list(APPEND ${NAME}_EXE_LINKER_FLAGS ${EP_EXE_LINKER_FLAGS} ${MOLD_EXE_LINKER_FLAGS})

	ListToString(${NAME}_EXE_LINKER_FLAGS)

	list(APPEND ${NAME}_ARGS "-DCMAKE_EXE_LINKER_FLAGS=${${NAME}_EXE_LINKER_FLAGS_STRING}")
endmacro()
