if (EXISTS "${OLD_FILE}")
	file(REMOVE "${NEW_FILE}")
	file(RENAME "${OLD_FILE}" "${NEW_FILE}")
endif()
