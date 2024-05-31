# Set compiler flags
set(CMAKE_CXX_STANDARD 17)
add_compile_options(-Wall -Wextra -Wpedantic -Werror=return-type)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
if (NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
  add_definitions(-O3)
endif(NOT CMAKE_BUILD_TYPE STREQUAL "Debug")

# Find catkin macros and libraries
find_package(ament_cmake REQUIRED)
find_package(Boost REQUIRED COMPONENTS chrono date_time filesystem program_options system thread timer)
find_package(Eigen3 REQUIRED)
find_package(libnabo REQUIRED)

########################
## Library definition ##
########################

include_directories(
  ${CMAKE_SOURCE_DIR}
  ${CMAKE_SOURCE_DIR}/pointmatcher
  ${CMAKE_SOURCE_DIR}/pointmatcher/DataPointsFilters
  ${CMAKE_SOURCE_DIR}/pointmatcher/DataPointsFilters/utils
  ${CMAKE_SOURCE_DIR}/testing
  SYSTEM
    ${EIGEN3_INCLUDE_DIR}
    ${Boost_INCLUDE_DIRS}
)

# Libpointmatcher
add_library(pointmatcher STATIC
  ${POINTMATCHER_SRC}
  ${POINTMATCHER_HEADERS}
)
ament_target_dependencies(pointmatcher libnabo)

target_link_libraries(pointmatcher
  Boost::chrono
  Boost::date_time
  Boost::filesystem
  Boost::program_options
  Boost::thread
  Boost::timer
  Boost::system
  yaml-cpp
)

# Testing utils
add_library(pointmatcher_testing STATIC
  pointmatcher/testing/utils_filesystem.cpp
  pointmatcher/testing/utils_filesystem.h
  pointmatcher/testing/utils_geometry.cpp
  pointmatcher/testing/utils_geometry.h
  pointmatcher/testing/utils_gtest.cpp
  pointmatcher/testing/utils_registration.cpp
  pointmatcher/testing/utils_transformations.cpp
  pointmatcher/testing/RegistrationTestCase.cpp
  pointmatcher/testing/RegistrationTestResult.cpp
  pointmatcher/testing/TransformationError.cpp
)
add_dependencies(pointmatcher_testing
  pointmatcher
)
target_link_libraries(pointmatcher_testing
  Boost::chrono
  Boost::date_time
  Boost::filesystem
  Boost::program_options
  Boost::thread
  Boost::timer
  Boost::system
  yaml-cpp
)

#############
## Install ##
#############
install(
  TARGETS
    pointmatcher
    pointmatcher_testing
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
)

install(
  DIRECTORY ${CMAKE_SOURCE_DIR}/pointmatcher/
  DESTINATION include/pointmatcher
)

##########
## Test ##
##########
find_package(cmake_code_coverage QUIET)
if(BUILD_TESTING)
  find_package(ament_cmake_gtest REQUIRED)

  # Symbol that controls whether data used for tests should be saved to disk for debugging.
  set(SAVE_TEST_DATA_TO_DISK 0)
  add_definitions(-DSAVE_TEST_DATA_TO_DISK=${SAVE_TEST_DATA_TO_DISK})
  ament_add_gtest(test_pointmatcher
      utest/utest.cpp
      utest/ui/DataFilters.cpp
      utest/ui/DataPoints.cpp
      utest/ui/ErrorMinimizers.cpp
      utest/ui/Inspectors.cpp
      utest/ui/IO.cpp
      utest/ui/Loggers.cpp
      utest/ui/Matcher.cpp
      utest/ui/Outliers.cpp
      utest/ui/PointCloudGenerator.cpp
      utest/ui/Transformations.cpp
      utest/ui/octree/Octree.cpp
      utest/ui/icp/GeneralTests.cpp
      utest/ui/icp/Conditioning.cpp
  )
  add_dependencies(test_pointmatcher
    pointmatcher
    pointmatcher_testing
  )
  target_include_directories(test_pointmatcher PRIVATE
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/pointmatcher
    ${CMAKE_SOURCE_DIR}/pointmatcher/DataPointsFilters
    ${CMAKE_SOURCE_DIR}/pointmatcher/DataPointsFilters/utils
    ${CMAKE_SOURCE_DIR}/testing
  )
  target_include_directories(test_pointmatcher SYSTEM PUBLIC
    ${EIGEN3_INCLUDE_DIR}
    ${Boost_INCLUDE_DIRS}
    ${catkin_INCLUDE_DIRS}
  )
  target_link_libraries(test_pointmatcher
    pointmatcher
    pointmatcher_testing
    yaml-cpp
    ${catkin_LIBRARIES}
  )

  set(TEST_DATA_FOLDER "${CMAKE_SOURCE_DIR}/examples/data/")
  add_definitions(-DUTEST_TEST_DATA_PATH="${TEST_DATA_FOLDER}/")

  ##################
  # Code_coverage ##
  ##################
  if(cmake_code_coverage_FOUND)
    add_gtest_coverage(
      TEST_BUILD_TARGETS
        test_pointmatcher
      SOURCE_EXCLUDE_PATTERN
        ${PROJECT_SOURCE_DIR}/utest/*
        ${PROJECT_SOURCE_DIR}/utest/ui/*
    )
  endif()
endif(CATKIN_ENABLE_TESTING)

#################
## Clang_tools ##
#################
find_package(cmake_clang_tools QUIET)
if(cmake_clang_tools_FOUND)
  add_default_clang_tooling(
    DISABLE_CLANG_FORMAT
  )
endif(cmake_clang_tools_FOUND)

ament_export_include_directories(${CMAKE_SOURCE_DIR} ${EIGEN3_INCLUDE_DIR})
ament_export_libraries(yaml-cpp pointmatcher pointmatcher_testing)
ament_export_dependencies(libnabo)

ament_package()
