# NSX adapter for the TFLM runtime carried by helia-rt.
#
# This module deliberately selects only helia-rt's reference or upstream
# CMSIS-NN backend. The Ambiq HELIA backend remains owned by nsx-helia-rt.

cmake_minimum_required(VERSION 3.21)

if(NOT DEFINED NSX_BOARD_FLAGS_TARGET)
    message(FATAL_ERROR
        "nsx-tflite-micro: NSX_BOARD_FLAGS_TARGET must be defined before this module is added.")
endif()

if(NOT DEFINED NSX_SOC_FAMILY)
    message(FATAL_ERROR
        "nsx-tflite-micro: NSX_SOC_FAMILY must be defined before this module is added.")
endif()

set(NSX_TFLITE_MICRO_BACKEND "reference" CACHE STRING
    "TFLM kernel backend: reference | cmsis_nn")
set_property(CACHE NSX_TFLITE_MICRO_BACKEND PROPERTY STRINGS
    "reference" "cmsis_nn")

set(_nsx_tflite_micro_backends reference cmsis_nn)
if(NOT NSX_TFLITE_MICRO_BACKEND IN_LIST _nsx_tflite_micro_backends)
    message(FATAL_ERROR
        "nsx-tflite-micro: invalid NSX_TFLITE_MICRO_BACKEND='${NSX_TFLITE_MICRO_BACKEND}'. "
        "Accepted values: reference, cmsis_nn.")
endif()

set(NSX_TFLITE_MICRO_VARIANT "release-with-logs" CACHE STRING
    "TFLM build variant: debug | release-with-logs | release")
set_property(CACHE NSX_TFLITE_MICRO_VARIANT PROPERTY STRINGS
    "debug" "release-with-logs" "release")
string(REPLACE "-" "_" _nsx_tflite_micro_build_type "${NSX_TFLITE_MICRO_VARIANT}")

# TFLITE_MICRO_ROOT is normally the sibling helia-rt-source project in an NSX
# workspace. Keep HELIA_RT_TFLM_ROOT as a compatibility alias for profiler
# and existing source-build scripts.
if(NOT TFLITE_MICRO_ROOT AND HELIA_RT_TFLM_ROOT)
    set(TFLITE_MICRO_ROOT "${HELIA_RT_TFLM_ROOT}")
endif()
set(_nsx_tflite_micro_root_candidates
    "${TFLITE_MICRO_ROOT}"
    "${CMAKE_CURRENT_LIST_DIR}/../helia-rt-source"
    "${CMAKE_CURRENT_LIST_DIR}/../helia-rt"
    "${CMAKE_CURRENT_LIST_DIR}")

set(_nsx_tflite_micro_root "")
foreach(_candidate IN LISTS _nsx_tflite_micro_root_candidates)
    if(_candidate AND EXISTS "${_candidate}/cmake/helia_rt_sources.cmake")
        get_filename_component(_nsx_tflite_micro_root "${_candidate}" ABSOLUTE)
        break()
    endif()
endforeach()
if(NOT _nsx_tflite_micro_root)
    message(FATAL_ERROR
        "nsx-tflite-micro: could not locate the helia-rt source tree. "
        "Set -DTFLITE_MICRO_ROOT=<helia-rt checkout> (or "
        "-DHELIA_RT_TFLM_ROOT=<helia-rt checkout>). Searched: "
        "${_nsx_tflite_micro_root_candidates}")
endif()
set(TFLITE_MICRO_ROOT "${_nsx_tflite_micro_root}" CACHE PATH
    "helia-rt source tree used by nsx-tflite-micro" FORCE)

if(NSX_TFLITE_MICRO_BACKEND STREQUAL "cmsis_nn")
    set(NSX_TFLITE_MICRO_CMSIS_NN_TARGET "nsx::arm_cmsis_nn" CACHE STRING
        "Upstream CMSIS-NN target used by nsx-tflite-micro")
    if(NOT TARGET "${NSX_TFLITE_MICRO_CMSIS_NN_TARGET}")
        message(FATAL_ERROR
            "nsx-tflite-micro: CMSIS-NN backend requires target "
            "'${NSX_TFLITE_MICRO_CMSIS_NN_TARGET}'. Add the arm-cmsis-nn "
            "module first, or set -DNSX_TFLITE_MICRO_CMSIS_NN_TARGET=<target>.")
    endif()
    set(HELIA_RT_CMSISNN_TARGET "${NSX_TFLITE_MICRO_CMSIS_NN_TARGET}"
        CACHE STRING "CMSIS-NN target used by helia-rt" FORCE)
    set(HELIA_RT_ENABLE_CMSIS_NN ON CACHE BOOL "" FORCE)
else()
    unset(NSX_TFLITE_MICRO_CMSIS_NN_TARGET CACHE)
    unset(HELIA_RT_CMSISNN_TARGET CACHE)
    set(HELIA_RT_ENABLE_CMSIS_NN OFF CACHE BOOL "" FORCE)
endif()
set(HELIA_RT_ENABLE_HELIA OFF CACHE BOOL "" FORCE)
set(HELIA_RT_BUILD_TYPE "${_nsx_tflite_micro_build_type}" CACHE STRING "" FORCE)
set(HELIA_RT_STATIC_MEMORY ON CACHE BOOL "" FORCE)
set(HELIA_RT_DISABLE_X86_NEON OFF CACHE BOOL "" FORCE)
set(HELIA_RT_PROVIDE_DEBUG_LOG OFF CACHE BOOL "" FORCE)

if(TARGET helia_rt::reference OR TARGET helia_rt::cmsis_nn)
    message(FATAL_ERROR
        "nsx-tflite-micro: helia-rt has already been added to this build. "
        "Add this module once and let it own the helia-rt source targets.")
endif()

set(_nsx_tflite_micro_backend_target "helia_rt_${NSX_TFLITE_MICRO_BACKEND}")
set(_nsx_tflite_micro_backend_alias "helia_rt::${NSX_TFLITE_MICRO_BACKEND}")

message(STATUS "nsx-tflite-micro: backend=${NSX_TFLITE_MICRO_BACKEND}, "
               "variant=${NSX_TFLITE_MICRO_VARIANT}, source=${TFLITE_MICRO_ROOT}")

add_subdirectory("${TFLITE_MICRO_ROOT}" tflite-micro-src EXCLUDE_FROM_ALL)

target_link_libraries(${_nsx_tflite_micro_backend_target} PRIVATE
    ${NSX_BOARD_FLAGS_TARGET})

# Helia-RT's CMSIS-NN kernel wrappers use the literal Include/ prefix. The
# wrapper target exports both the repository root and Include/, but retain the
# source-root parent here for externally supplied CMSIS-NN targets as well.
if(NSX_TFLITE_MICRO_BACKEND STREQUAL "cmsis_nn")
    target_include_directories(${_nsx_tflite_micro_backend_target} PRIVATE
        "$<TARGET_PROPERTY:${NSX_TFLITE_MICRO_CMSIS_NN_TARGET},SOURCE_DIR>")
endif()

# Match helia-rt's Cortex-M debug-log glue so DebugLog() resolves through the
# NSX SoC HAL and does not pull the host fprintf implementation into firmware.
add_library(nsx_tflite_micro_glue OBJECT
    "${TFLITE_MICRO_ROOT}/tensorflow/lite/micro/cortex_m_generic/debug_log.cc")
target_link_libraries(nsx_tflite_micro_glue PRIVATE
    ${NSX_BOARD_FLAGS_TARGET}
    nsx_soc_hal)
target_include_directories(nsx_tflite_micro_glue PRIVATE
    "${TFLITE_MICRO_ROOT}"
    "${TFLITE_MICRO_ROOT}/third_party_static/flatbuffers/include"
    "${TFLITE_MICRO_ROOT}/third_party_static/gemmlowp")
target_compile_definitions(nsx_tflite_micro_glue PRIVATE
    TF_LITE_STATIC_MEMORY)

add_library(nsx_tflite_micro INTERFACE)
add_library(nsx::tflite_micro ALIAS nsx_tflite_micro)
target_sources(nsx_tflite_micro INTERFACE
    $<TARGET_OBJECTS:nsx_tflite_micro_glue>)
target_link_libraries(nsx_tflite_micro INTERFACE
    ${_nsx_tflite_micro_backend_alias})
