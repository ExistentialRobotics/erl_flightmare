# Download and unpack eigen at configure time
message(STATUS "Getting yaml-cpp...")

configure_file(cmake/yaml_download.cmake
               ${PROJECT_SOURCE_DIR}/externals/yaml-download/CMakeLists.txt)

execute_process(
  COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" .
  RESULT_VARIABLE result
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/externals/yaml-download
  OUTPUT_QUIET ERROR_QUIET)
if(result)
  message(FATAL_ERROR "CMake step for yaml-cpp failed: ${result}")
endif()
execute_process(
  COMMAND ${CMAKE_COMMAND} --build .
  RESULT_VARIABLE result
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/externals/yaml-download
  OUTPUT_QUIET ERROR_QUIET)
if(result)
  message(FATAL_ERROR "Build step for yaml failed: ${result}")
endif()

message(STATUS "Yaml downloaded!")
#
# --- Build yaml-cpp after download ---
#
message(STATUS "Configuring yaml-cpp...")

# Configure step (creates externals/yaml-build)
execute_process(
  COMMAND
    ${CMAKE_COMMAND} -S "${PROJECT_SOURCE_DIR}/externals/yaml-src" -B
    "${PROJECT_SOURCE_DIR}/externals/yaml-build" -DYAML_CPP_BUILD_TESTS=OFF
    -DYAML_CPP_INSTALL=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON
  RESULT_VARIABLE result)
if(result)
  message(FATAL_ERROR "Failed to configure yaml-cpp: ${result}")
endif()

message(STATUS "Building yaml-cpp...")

# Build step (creates libyaml-cpp.a)
execute_process(
  COMMAND ${CMAKE_COMMAND} --build "${PROJECT_SOURCE_DIR}/externals/yaml-build"
  RESULT_VARIABLE result)
if(result)
  message(FATAL_ERROR "Failed to build yaml-cpp: ${result}")
endif()

message(STATUS "yaml-cpp built successfully!")

# add_subdirectory(${PROJECT_SOURCE_DIR}/externals/yaml-src
# ${PROJECT_SOURCE_DIR}/externals/yaml-build EXCLUDE_FROM_ALL)
add_library(yaml-cpp STATIC IMPORTED)
set_target_properties(
  yaml-cpp
  PROPERTIES IMPORTED_LOCATION
             "${PROJECT_SOURCE_DIR}/externals/yaml-build/libyaml-cpp.a"
             INTERFACE_INCLUDE_DIRECTORIES
             "${PROJECT_SOURCE_DIR}/externals/yaml-src/include")

target_compile_options(yaml-cpp INTERFACE -fPIC -w)

# include_directories(SYSTEM "${PROJECT_SOURCE_DIR}/externals/yaml-src/include")
# link_directories("${PROJECT_SOURCE_DIR}/externals/yaml-build")
