# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)
include(FetchContent)

# Project-level configuration.
set(PROJECT_NAME "flutter_storm")
project(${PROJECT_NAME} LANGUAGES CXX)

# Pull StormLib from github and link it as a shared library
SET(STORM_SKIP_INSTALL ON CACHE BOOL "Ignore stormlib install" FORCE)
set(BUILD_SHARED_LIBS ON CACHE BOOL "Build stormlib as a shared library" FORCE)
FetchContent_Declare(
  storm
  GIT_REPOSITORY https://github.com/ladislav-zezula/StormLib.git
  GIT_TAG        3846f0b8e2c47320c6b499492496f3e3f2e76821 # v9.22
)
FetchContent_MakeAvailable(storm)

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(flutter_storm_bundled_libraries
  $<TARGET_FILE:storm>
  PARENT_SCOPE
)
