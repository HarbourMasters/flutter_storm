# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)
include(FetchContent)

# Project-level configuration.
set(PROJECT_NAME "flutter_storm")

project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "flutter_storm_plugin")

# Any new source files that you add to the plugin should be added here.
list(APPEND PLUGIN_SOURCES
  "flutter_storm_plugin.cpp"
  "flutter_storm_plugin.h"
)

add_definitions("/wd4018")
add_definitions("/wd4101")
add_definitions("/wd4267")
add_definitions("/wd4334")
add_definitions("/wd4244")

#=================== StormLib ===================

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

#================================================

# Define the plugin library target. Its name must not be changed (see comment
# on PLUGIN_NAME above).
add_library(${PLUGIN_NAME} SHARED
  "include/flutter_storm/flutter_storm_plugin_c_api.h"
  "flutter_storm_plugin_c_api.cpp"
  ${PLUGIN_SOURCES}
)

# Apply a standard set of build settings that are configured in the
# application-level CMakeLists.txt. This can be removed for plugins that want
# full control over build settings.
apply_standard_settings(${PLUGIN_NAME})

# Symbols are hidden by default to reduce the chance of accidental conflicts
# between plugins. This should not be removed; any symbols that should be
# exported should be explicitly exported with the FLUTTER_PLUGIN_EXPORT macro.
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

# Source include directories and library dependencies. Add any plugin-specific
# dependencies here.
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include" )

target_link_libraries(${PLUGIN_NAME} PRIVATE storm flutter flutter_wrapper_plugin )

target_compile_options(${PLUGIN_NAME}
  PRIVATE "/wd4101;/wd4267;/wd4334;/wd4244"
)

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(flutter_storm_bundled_libraries
  ""
  PARENT_SCOPE
)