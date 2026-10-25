# ****************************************************************************
#  Project:  LibCMaker
#  Purpose:  A CMake build scripts for build libraries with CMake
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2026 NikitaFeodonit
#
#    This file is part of the LibCMaker project.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published
#    by the Free Software Foundation, either version 3 of the License,
#    or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#    See the GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program. If not, see <http://www.gnu.org/licenses/>.
# ****************************************************************************


#-----------------------------------------------------------------------
# Library version
#

set(Dawn_VERSION "157" CACHE STRING "Dawn_VERSION")
set(Dawn_sha256
  "76912fb346c9bccd748764eec377e52a6dcd1e64e93e03ca0b412f24822c28ad"
  CACHE STRING "Dawn_sha256"
)


#-----------------------------------------------------------------------
# Update Dawn to new version
#-----------------------------------------------------------------------

if(FALSE)
# if(TRUE)
  include("${CMAKE_CURRENT_LIST_DIR}/update_Dawn.cmake")
  cmr_print_status("Exit after update Dawn")
  cmr_print_error("======== STOP ========")
endif()


#-----------------------------------------------------------------------
# Dawn options
#-----------------------------------------------------------------------

option(DAWN_FETCH_DEPENDENCIES "Use fetch_dawn_dependencies.py as an alternative to using depot_tools" OFF)

option(DAWN_ENABLE_INSTALL "Enable install step for Dawn libraries" ON)
option(DAWN_ENABLE_D3D11 "Enable compilation of the D3D11 backend" OFF)
option(DAWN_BUILD_SAMPLES "Enables building Dawn's samples" OFF)
option(DAWN_BUILD_TESTS "Enables building Dawn's tests" OFF)
option(TINT_BUILD_TESTS "Build tests" OFF)

if(BUILD_SHARED_LIBS)
  set(_DAWN_BUILD_MONOLITHIC_LIBRARY "SHARED")
else()
  set(_DAWN_BUILD_MONOLITHIC_LIBRARY "STATIC")
endif()

# Handling of the type of monolithic library to build, if any.
set(DAWN_BUILD_MONOLITHIC_LIBRARY ${_DAWN_BUILD_MONOLITHIC_LIBRARY}
  CACHE STRING "Build monolithic library: SHARED, STATIC, or OFF."
)


#-----------------------------------------------------------------------
# Unpack, configure and build the required libraries
#-----------------------------------------------------------------------

# If DAWN_BUILD_MONOLITHIC_LIBRARY is set then BUILD_SHARED_LIBS must be OFF.
if(DEFINED CACHE{BUILD_SHARED_LIBS})
  set(_STORE_CACHE__BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})
  set(BUILD_SHARED_LIBS OFF CACHE BOOL "BUILD_SHARED_LIBS" FORCE)
endif()
if(DEFINED BUILD_SHARED_LIBS AND NOT DEFINED CACHE{BUILD_SHARED_LIBS})
  set(_STORE__BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})
  set(BUILD_SHARED_LIBS OFF)
endif()


include(FetchContent)

FetchContent_Declare(
  Dawn
  URL "${CMAKE_CURRENT_LIST_DIR}/source/dawn-m${Dawn_VERSION}.tar.xz"
  URL_HASH "SHA256=${Dawn_sha256}"
  OVERRIDE_FIND_PACKAGE
)

FetchContent_MakeAvailable(Dawn)


# Restore BUILD_SHARED_LIBS.
if(DEFINED _STORE_CACHE__BUILD_SHARED_LIBS)
  set(BUILD_SHARED_LIBS ${_STORE_CACHE__BUILD_SHARED_LIBS} CACHE BOOL "BUILD_SHARED_LIBS" FORCE)
endif()
if(DEFINED _STORE__BUILD_SHARED_LIBS)
  set(BUILD_SHARED_LIBS ${_STORE__BUILD_SHARED_LIBS})
endif()
