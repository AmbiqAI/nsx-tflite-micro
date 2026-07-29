cmake_minimum_required(VERSION 3.21)

set(_root "${CMAKE_CURRENT_LIST_DIR}/..")

file(READ "${_root}/nsx-module.yaml" _module)
string(REGEX MATCH
    "module:[ \t]*\n[ \t]+name:[ \t]*nsx-tflite-micro[ \t]*\n[ \t]+type:[ \t]*runtime[ \t]*\n[ \t]+version:[ \t]*\"((0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)(-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?)\""
    _module_version_match "${_module}")
if(NOT _module_version_match)
    message(FATAL_ERROR "nsx-module.yaml does not declare a valid module version")
endif()
set(_module_version "${CMAKE_MATCH_1}")

file(READ "${_root}/version.txt" _version_file)
string(STRIP "${_version_file}" _version_file)
if(NOT _module_version STREQUAL _version_file)
    message(FATAL_ERROR
        "Module version ${_module_version} does not match version.txt "
        "${_version_file}")
endif()

file(READ "${_root}/.release-please-manifest.json" _manifest)
string(REGEX MATCH
    "\"\\.\"[ \t]*:[ \t]*\"((0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)(-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?)\""
    _manifest_version_match "${_manifest}")
if(NOT _manifest_version_match)
    message(FATAL_ERROR "Release Please manifest does not declare a valid version")
endif()
set(_manifest_version "${CMAKE_MATCH_1}")
if(NOT _module_version STREQUAL _manifest_version)
    message(FATAL_ERROR
        "Module version ${_module_version} does not match manifest version "
        "${_manifest_version}")
endif()

foreach(_required IN ITEMS CHANGELOG.md LICENSE PROVENANCE.md RELEASE.md version.txt)
    if(NOT EXISTS "${_root}/${_required}")
        message(FATAL_ERROR "Missing release foundation file: ${_required}")
    endif()
endforeach()

file(READ "${_root}/PROVENANCE.md" _provenance)
foreach(_pin IN ITEMS
    "7c1b162c0fd2336876b69daaa20c87a1e7e2f508"
    "41e0cf520fe68d5e22298f98e1a0ffda1196f8d8")
    if(NOT _provenance MATCHES "${_pin}")
        message(FATAL_ERROR "Missing pinned dependency provenance: ${_pin}")
    endif()
endforeach()

message(STATUS
    "Release metadata contract passed for nsx-tflite-micro ${_module_version}")
