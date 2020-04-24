MACRO(PARENTDIRLIST result curdir)
  SET(dirlist "")
  SET(tmpcurdir ${curdir})
  WHILE(NOT ${tmpcurdir} STREQUAL  "/")
    get_filename_component(parent ${tmpcurdir} DIRECTORY)
    LIST(APPEND dirlist ${parent})
    SET(tmpcurdir ${parent})
  ENDWHILE()
  SET(${result} ${dirlist})
ENDMACRO()
