cmake_minimum_required(VERSION 3.16)
project(CalcApp VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt5 REQUIRED COMPONENTS Core Quick QuickControls2 Gui)
find_package(Boost REQUIRED)

include_directories(${CMAKE_SOURCE_DIR}/src)
include_directories(${Boost_INCLUDE_DIRS})

set(SOURCES
    main.cpp
    src/calcengine.cpp
)

set(HEADERS
    src/calcengine.h
)

qt5_add_resources(QRC_SOURCES resources.qrc)

add_executable(${PROJECT_NAME}
    ${SOURCES}
    ${HEADERS}
    ${QRC_SOURCES}
)


target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt5::Core
    Qt5::Quick
    Qt5::QuickControls2
)

include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
)
FetchContent_MakeAvailable(googletest)

set(TEST_SOURCES
    tests/calctest.cpp
    src/calcengine.cpp
)

add_executable(CalcAppTests ${TEST_SOURCES})

target_link_libraries(CalcAppTests PRIVATE
    Qt5::Core
    Qt5::Gui
    Qt5::Quick
    Boost::headers
    GTest::gtest_main
)
