cmake_minimum_required(VERSION 3.21)
project(nsx_tflite_micro_smoke LANGUAGES C CXX)

if(NOT DEFINED TFLITE_MICRO_ROOT)
    message(FATAL_ERROR "TFLITE_MICRO_ROOT must point to a Helia-RT source checkout")
endif()
if(NOT EXISTS "${TFLITE_MICRO_ROOT}/cmake/helia_rt_sources.cmake")
    message(FATAL_ERROR "TFLITE_MICRO_ROOT is not a Helia-RT source checkout")
endif()

option(NSX_TFLITE_MICRO_SMOKE_BUILD_EXECUTABLE
       "Build the host link smoke executable" ON)
set(NSX_TFLITE_MICRO_SMOKE_ARM_CMSIS_NN_ROOT "" CACHE PATH
    "Optional arm-cmsis-nn module checkout for a real CMSIS-NN smoke")

add_library(nsx_smoke_board_flags INTERFACE)
add_library(nsx_soc_hal INTERFACE)
set(NSX_BOARD_FLAGS_TARGET nsx_smoke_board_flags)
set(NSX_SOC_FAMILY smoke)

if(NSX_TFLITE_MICRO_BACKEND STREQUAL "cmsis_nn")
    if(NSX_TFLITE_MICRO_SMOKE_ARM_CMSIS_NN_ROOT)
        add_subdirectory("${NSX_TFLITE_MICRO_SMOKE_ARM_CMSIS_NN_ROOT}"
                         arm-cmsis-nn)
    else()
        # Configure-only contract smoke: a real build supplies the target
        # from the arm-cmsis-nn module and its public include directories.
        add_library(nsx_smoke_arm_cmsis_nn INTERFACE)
        add_library(nsx::arm_cmsis_nn ALIAS nsx_smoke_arm_cmsis_nn)
    endif()
endif()

get_filename_component(_module_root "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
add_subdirectory("${_module_root}" nsx-tflite-micro)

if(NSX_TFLITE_MICRO_SMOKE_BUILD_EXECUTABLE)
    add_executable(nsx_tflite_micro_smoke main.cc)
    target_link_libraries(nsx_tflite_micro_smoke PRIVATE nsx::tflite_micro)
endif()
