cmake_minimum_required(VERSION 3.16)
project(CalcApp VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt5 REQUIRED COMPONENTS Core Quick Widgets)

set(SOURCES
    main.cpp
)

qt5_add_resources(QRC_SOURCES resources.qrc)

add_executable(${PROJECT_NAME}
    ${SOURCES}
    ${QRC_SOURCES}
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt5::Core
    Qt5::Quick
    Qt5::Widgets
)
