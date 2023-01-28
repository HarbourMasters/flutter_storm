# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

# Project-level configuration.
set(PROJECT_NAME "flutter_storm")
project(${PROJECT_NAME} LANGUAGES CXX)

# Invoke the build for native code shared with the other target platforms.
set(STORM_GIT_REPO https://github.com/ladislav-zezula/StormLib.git)
set(STORM_GIT_COMMIT 3235d01eab95af50c589a615bd8d492f911369f7)
SET(STORM_SKIP_INSTALL ON CACHE BOOL "Ignore stormlib install" FORCE)
add_definitions(-DSTORMLIB_NO_AUTO_LINK)
FetchContent_Declare(StormLib GIT_REPOSITORY ${STORM_GIT_REPO} GIT_TAG ${STORM_GIT_COMMIT})
FetchContent_GetProperties(StormLib)
if(NOT stormlib_POPULATED)
  FetchContent_Populate(StormLib)
  add_subdirectory(${stormlib_SOURCE_DIR} ${stormlib_BINARY_DIR})
  include_directories(${stormlib_SOURCE_DIR}/src)
endif()

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(flutter_storm_bundled_libraries
  $<TARGET_FILE:storm>
  PARENT_SCOPE
)
