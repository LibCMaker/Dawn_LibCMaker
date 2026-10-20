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

set(upd_DAWN_SRC_URL "https://dawn.googlesource.com/dawn.git")
set(upd_DAWN_BRANCH  "1e897275172a23f27b0022fa6beae3084ed54a9b")


#-----------------------------------------------------------------------
# Paths
#

set(upd_SRC_NAME "dawn-m${Dawn_VERSION}")
set(upd_ARCHIVE_DIR "${CMAKE_CURRENT_LIST_DIR}/source")

set(upd_PATCH_DIR  "${upd_ARCHIVE_DIR}/patch/${upd_SRC_NAME}")
set(upd_DAWN_SRC_DIR        "${upd_ARCHIVE_DIR}/${upd_SRC_NAME}")


#-----------------------------------------------------------------------
# TODO
#

find_package(Git 2.17.1 REQUIRED)
find_package(Python REQUIRED COMPONENTS Interpreter)

if(Python_VERSION VERSION_LESS 3.8)
  cmr_print_error("Dawn requires python 3.8+.")
endif()

find_program(tar_EXECUTABLE "tar" REQUIRED)
message(STATUS "Found tar: ${tar_EXECUTABLE}")

find_program(xz_EXECUTABLE "xz" REQUIRED)
message(STATUS "Found xz: ${xz_EXECUTABLE}")


#-----------------------------------------------------------------------
# TODO
#

if(NOT EXISTS ${upd_DAWN_SRC_DIR})
  cmr_print_status(
    "Download Dawn sources from\n  '${upd_DAWN_SRC_URL}'\nto\n  '${upd_DAWN_SRC_DIR}'"
  )
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E make_directory ${upd_DAWN_SRC_DIR}
    RESULT_VARIABLE error_RESULT
  )
  if(error_RESULT)
    cmr_print_error("Failed make_directory: ${error_RESULT}")
  endif()
  execute_process(
    COMMAND ${GIT_EXECUTABLE} init --quiet
    WORKING_DIRECTORY ${upd_DAWN_SRC_DIR}
    RESULT_VARIABLE error_RESULT
  )
  if(error_RESULT)
    cmr_print_error("Failed git init: ${error_RESULT}")
  endif()
  execute_process(
    COMMAND ${GIT_EXECUTABLE} remote add origin ${upd_DAWN_SRC_URL}
    WORKING_DIRECTORY ${upd_DAWN_SRC_DIR}
    RESULT_VARIABLE error_RESULT
  )
  if(error_RESULT)
    cmr_print_error("Failed git remote: ${error_RESULT}")
  endif()
  execute_process(
    COMMAND ${GIT_EXECUTABLE} fetch --depth 1 origin ${upd_DAWN_BRANCH}
    WORKING_DIRECTORY ${upd_DAWN_SRC_DIR}
    RESULT_VARIABLE error_RESULT
  )
  if(error_RESULT)
    cmr_print_error("Failed git fetch: ${error_RESULT}")
  endif()
  execute_process(
    COMMAND ${GIT_EXECUTABLE} checkout --quiet FETCH_HEAD
    WORKING_DIRECTORY ${upd_DAWN_SRC_DIR}
    RESULT_VARIABLE error_RESULT
  )
  if(error_RESULT)
    cmr_print_error("Failed git checkout: ${error_RESULT}")
  endif()
endif()


#-----------------------------------------------------------------------
# TODO
#

function(upd_apply_dawn_source_patch _name)
  set(${_name}_STAMP
    "${upd_ARCHIVE_DIR}/patch__${_name}__.stamp"
  )
  if(NOT EXISTS ${${_name}_STAMP})
    cmr_print_status("Apply Dawn source patch: '${_name}'")
    set(${_name}_FILE
      "${upd_PATCH_DIR}/${_name}"
    )
    execute_process(
      COMMAND ${GIT_EXECUTABLE} apply ${${_name}_FILE}
      #COMMAND ${GIT_EXECUTABLE} apply --reverse ${${_name}_FILE}
      WORKING_DIRECTORY ${upd_DAWN_SRC_DIR}
      RESULT_VARIABLE error_RESULT
    )
    if(error_RESULT)
      cmr_print_error("Failed git apply: ${error_RESULT}")
    endif()
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E touch ${${_name}_STAMP}
    )
  endif()
endfunction()

# upd_apply_dawn_source_patch("p.patch")


#-----------------------------------------------------------------------
# TODO
#

set(fetch_dawn_dependencies_STAMP
  "${upd_ARCHIVE_DIR}/tools__fetch_dawn_dependencies.stamp"
)
if(NOT EXISTS ${fetch_dawn_dependencies_STAMP})
  cmr_print_status("Run 'tools/fetch_dawn_dependencies.py'")
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E env ${dawn_ENV}
      ${Python_EXECUTABLE}
        "${upd_DAWN_SRC_DIR}/tools/fetch_dawn_dependencies.py"
          --shallow
          --directory ${upd_DAWN_SRC_DIR}
    WORKING_DIRECTORY ${upd_DAWN_SRC_DIR}
    RESULT_VARIABLE error_RESULT
  )
  if(error_RESULT)
    cmr_print_error("Failed run 'tools/fetch_dawn_dependencies.py': ${error_RESULT}")
  endif()
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E touch ${fetch_dawn_dependencies_STAMP}
  )
endif()


#-----------------------------------------------------------------------
# TODO
#

set(tar_create_STAMP
  "${upd_ARCHIVE_DIR}/tools__tar-create.stamp"
)
if(NOT EXISTS ${tar_create_STAMP})
  cmr_print_status("Run tar --create")
  execute_process(
    COMMAND ${tar_EXECUTABLE}
      # --verbose
      --create
      --file "${upd_SRC_NAME}__NEW.tar.xz"
      --use-compress-program "${xz_EXECUTABLE} --threads=${cmr_BUILD_MULTIPROC_CNT}"
      "${upd_SRC_NAME}"
    WORKING_DIRECTORY ${upd_ARCHIVE_DIR}
    RESULT_VARIABLE error_RESULT
  )
  if(error_RESULT)
    cmr_print_error("Failed create tar: ${error_RESULT}")
  endif()
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E touch ${tar_create_STAMP}
  )
endif()
