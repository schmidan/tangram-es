if(NOT TIZEN_SDK)
    message(SEND_ERROR "Set tizen sdk path: $TIZEN_SDK or -DTIZEN_SDK")
    return()
endif()

# set for test in other cmake files
set(PLATFORM_TIZEN ON)

# Tell SQLiteCpp to not build its own copy of SQLite, we will use the system library instead.
#set(SQLITECPP_INTERNAL_SQLITE OFF)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -fPIC")

# global compile options
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++1y -fPIC")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-omit-frame-pointer")

if (NOT ${TIZEN_DEVICE})
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=i486")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=i486")
endif()

if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-gnu-zero-variadic-macro-arguments")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
endif()

if (CMAKE_COMPILER_IS_GNUCC)
  execute_process(COMMAND ${CMAKE_CXX_COMPILER} -dumpversion
    OUTPUT_VARIABLE GCC_VERSION)
  string(REGEX MATCHALL "[0-9]+" GCC_VERSION_COMPONENTS ${GCC_VERSION})
  list(GET GCC_VERSION_COMPONENTS 0 GCC_MAJOR)
  list(GET GCC_VERSION_COMPONENTS 1 GCC_MINOR)

  message(STATUS "Using gcc ${GCC_VERSION}")
  if (GCC_VERSION VERSION_GREATER 5.1)
    message(STATUS "USE CXX11_ABI")
    add_definitions("-D_GLIBCXX_USE_CXX11_ABI=1")
  endif()
endif()

check_unsupported_compiler_version()

# compile definitions (adds -DPLATFORM_LINUX)
set(CORE_COMPILE_DEFS PLATFORM_TIZEN)

# load core library
add_subdirectory(${PROJECT_SOURCE_DIR}/core)

set(LIB_NAME tangram) # in order to have libtangram.so

add_library(${LIB_NAME} # SHARED
  ${PROJECT_SOURCE_DIR}/platforms/tizen/src/platform_tizen.cpp
  ${PROJECT_SOURCE_DIR}/platforms/tizen/src/tizen_gl.cpp
  ${PROJECT_SOURCE_DIR}/platforms/common/urlClient.cpp)

target_include_directories(${LIB_NAME}
    PUBLIC
    ${GLFW_SOURCE_DIR}/include
    ${PROJECT_SOURCE_DIR}/platforms/common)

# link to the core library, forcing all symbols to be added
# (whole-archive must be turned off after core so that lc++ symbols aren't duplicated)
target_link_libraries(${LIB_NAME}
  PUBLIC
  "-Wl,-whole-archive"
  ${CORE_LIBRARY}
  "-Wl,-no-whole-archive")

target_compile_options(${LIB_NAME}
  PUBLIC
  -fPIC)
