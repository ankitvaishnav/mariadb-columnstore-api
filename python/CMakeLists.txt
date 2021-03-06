cmake_minimum_required(VERSION 2.8.11)

include_directories(..)

IF(UNIX)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D__FILENAME__='\"$(subst ${CMAKE_SOURCE_DIR}/,,$(abspath $<))\"'")
ENDIF(UNIX)
IF(WIN32)
    #TODO find a way to define the __FILENAME__ in Windows so that the debug output doesn't contain the absolute path.
    #set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D__FILENAME__=\"$(notdir $<)\"")
ENDIF(WIN32)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DBUILDING_MYMCSAPI")

set(PYTHON2_AVAILABLE 0)
set(PYTHON3_AVAILABLE 0)

#Checking for Python versions and setting executables
execute_process(COMMAND python -c "import sys; print(sys.version_info[0]);" OUTPUT_VARIABLE PYTHON_VERSION_AVAILABLE OUTPUT_STRIP_TRAILING_WHITESPACE)
IF(PYTHON_VERSION_AVAILABLE EQUAL 2)
  set(PYTHON2_AVAILABLE 1)
  execute_process(COMMAND python -c "import sys; print(sys.executable);" OUTPUT_VARIABLE PYTHON2_EXECUTABLE OUTPUT_STRIP_TRAILING_WHITESPACE)
ENDIF(PYTHON_VERSION_AVAILABLE EQUAL 2)
IF(PYTHON_VERSION_AVAILABLE EQUAL 3)
  set(PYTHON3_AVAILABLE 1)
  execute_process(COMMAND python -c "import sys; print(sys.executable);" OUTPUT_VARIABLE PYTHON3_EXECUTABLE OUTPUT_STRIP_TRAILING_WHITESPACE)
ENDIF(PYTHON_VERSION_AVAILABLE EQUAL 3)
execute_process(COMMAND python3 -c "import sys; print(sys.version_info[0]);" OUTPUT_VARIABLE PYTHON_VERSION_AVAILABLE OUTPUT_STRIP_TRAILING_WHITESPACE)
IF(PYTHON_VERSION_AVAILABLE EQUAL 3)
  set(PYTHON3_AVAILABLE 1)
  execute_process(COMMAND python3 -c "import sys; print(sys.executable);" OUTPUT_VARIABLE PYTHON3_EXECUTABLE OUTPUT_STRIP_TRAILING_WHITESPACE)
ENDIF(PYTHON_VERSION_AVAILABLE EQUAL 3)

#Checking for Python2 if the Python.h exists
IF(PYTHON2_AVAILABLE)
  MESSAGE(STATUS "Found Python2 interpreter")
  #Getting the include dir
  execute_process(COMMAND ${PYTHON2_EXECUTABLE} -c "import distutils.sysconfig; print(distutils.sysconfig.get_python_inc());" OUTPUT_VARIABLE PYTHON2_INCLUDE_DIR OUTPUT_STRIP_TRAILING_WHITESPACE)
  #Checking for Python.h
  IF(EXISTS "${PYTHON2_INCLUDE_DIR}/Python.h")
    MESSAGE(STATUS "Found Python2 header file Python.h")
    #Check for Python library in Windows
    IF(WIN32)
      find_library(
        PYTHON2_LIBRARY
        NAMES python27 python
        HINTS "${PYTHON2_INCLUDE_DIR}/../libs" $ENV{PYTHON2_LIBRARY_DIRECTORY}
      )
      if (${PYTHON2_LIBRARY} STREQUAL "PYTHON2_LIBRARY-NOTFOUND")
        MESSAGE(WARNING "Could not find a usable Python 2 library!\nYou can hint cmake by setting the environment variable PYTHON2_LIBRARY_DIRECTORY.")
        set(PYTHON2_AVAILABLE 0)
      ELSE()
        MESSAGE(STATUS "Found Python2 library: ${PYTHON2_LIBRARY}")
      ENDIF()
    ENDIF(WIN32)
  ELSE(EXISTS "${PYTHON2_INCLUDE_DIR}/Python.h")
    MESSAGE(WARNING "NOT found Python2 header file Python.h")
    set(PYTHON2_AVAILABLE 0)
  ENDIF(EXISTS "${PYTHON2_INCLUDE_DIR}/Python.h")
ELSE(PYTHON2_AVAILABLE)
  MESSAGE(WARNING "NOT found Python2 interpreter")
ENDIF(PYTHON2_AVAILABLE)

#Checking for Python3 if Python.h exists
IF(PYTHON3_AVAILABLE)
  MESSAGE(STATUS "Found Python3 interpreter")
  #Getting the include dir
  execute_process(COMMAND ${PYTHON3_EXECUTABLE} -c "import distutils.sysconfig; print(distutils.sysconfig.get_python_inc());" OUTPUT_VARIABLE PYTHON3_INCLUDE_DIR OUTPUT_STRIP_TRAILING_WHITESPACE)
  #Checking for Python.h
  IF(EXISTS "${PYTHON3_INCLUDE_DIR}/Python.h")
    MESSAGE(STATUS "Found Python3 header file Python.h")
    #Check for Python library in Windows
    IF(WIN32)
      find_library(
        PYTHON3_LIBRARY
        NAMES python38 python37 python36 python35 python34 python33 python32 python31 python30 python
        HINTS "${PYTHON3_INCLUDE_DIR}/../libs" $ENV{PYTHON3_LIBRARY_DIRECTORY}
      )
      if (${PYTHON3_LIBRARY} STREQUAL "PYTHON3_LIBRARY-NOTFOUND")
        MESSAGE(WARNING "Could not find a usable Python 3 library!\nYou can hint cmake by setting the environment variable PYTHON3_LIBRARY_DIRECTORY.")
        set(PYTHON3_AVAILABLE 0)
      ELSE()
        MESSAGE(STATUS "Found Python3 library: ${PYTHON3_LIBRARY}")
      ENDIF()
    ENDIF(WIN32)
  ELSE(EXISTS "${PYTHON3_INCLUDE_DIR}/Python.h")
    MESSAGE(WARNING "NOT found Python3 header file Python.h")
    set(PYTHON3_AVAILABLE 0)
  ENDIF(EXISTS "${PYTHON3_INCLUDE_DIR}/Python.h")
ELSE(PYTHON3_AVAILABLE)
  MESSAGE(WARNING "NOT found Python3 interpreter")
ENDIF(PYTHON3_AVAILABLE)

#Abort if no Python development environment can be found
IF(NOT PYTHON2_AVAILABLE AND NOT PYTHON3_AVAILABLE)
  MESSAGE(FATAL_ERROR "Python2 or Python3 including headers are required for build")
ENDIF()

#Abort during packaging if Python2 and Python3 are not available
IF(DEB OR RPM)
  IF(NOT (${PYTHON2_AVAILABLE} AND ${PYTHON3_AVAILABLE}))
    MESSAGE(FATAL_ERROR "Python2 and Python3 including headers are required for package build")
  ENDIF(NOT (${PYTHON2_AVAILABLE} AND ${PYTHON3_AVAILABLE}))
ENDIF(DEB OR RPM)


#Checking for SWIG
find_package(SWIG 3 REQUIRED)

# Build pymcsapi
IF(PYTHON2_AVAILABLE OR PYTHON3_AVAILABLE)
  IF(PYTHON2_AVAILABLE)
    configure_file("${CMAKE_CURRENT_SOURCE_DIR}/pymcsapi.i" "${CMAKE_CURRENT_SOURCE_DIR}/python2/pymcsapi.i" COPYONLY)
    add_subdirectory(python2)
  ENDIF(PYTHON2_AVAILABLE)
  
  IF(PYTHON3_AVAILABLE)
    configure_file("${CMAKE_CURRENT_SOURCE_DIR}/pymcsapi.i" "${CMAKE_CURRENT_SOURCE_DIR}/python3/pymcsapi.i" COPYONLY)
    add_subdirectory(python3)
  ENDIF(PYTHON3_AVAILABLE)

  #BUILD THE PYMCSAPI DOCUMENTATION
  if (BUILD_DOCS)
    add_subdirectory(docs)
  endif (BUILD_DOCS)
ENDIF(PYTHON2_AVAILABLE OR PYTHON3_AVAILABLE)

#MAKE DETECTED PYTHON VARIABLES USABLE FROM PARENT_SCOPE
set(PYTHON2_AVAILABLE ${PYTHON2_AVAILABLE} PARENT_SCOPE)
set(PYTHON3_AVAILABLE ${PYTHON3_AVAILABLE} PARENT_SCOPE)
set(PYTHON2_EXECUTABLE ${PYTHON2_EXECUTABLE} PARENT_SCOPE)
set(PYTHON3_EXECUTABLE ${PYTHON3_EXECUTABLE} PARENT_SCOPE)
IF(UNIX)
  set(PYTHON2_SITE_PACKAGES ${PYTHON2_SITE_PACKAGES} PARENT_SCOPE)
  set(PYTHON3_SITE_PACKAGES ${PYTHON3_SITE_PACKAGES} PARENT_SCOPE)
ENDIF(UNIX)
IF(WIN32)
  set(PYTHON2_PYMCSAPI_PY ${PYTHON2_PYMCSAPI_PY} PARENT_SCOPE)
  set(PYTHON3_PYMCSAPI_PY ${PYTHON3_PYMCSAPI_PY} PARENT_SCOPE)
  set(PYTHON2_VERSION ${PYTHON2_VERSION} PARENT_SCOPE)
  set(PYTHON3_VERSION ${PYTHON3_VERSION} PARENT_SCOPE)
ENDIF(WIN32)

