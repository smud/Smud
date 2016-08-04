cmake_minimum_required(VERSION 3.4)
project(Smud)

if(UNIX AND NOT APPLE)
    set(Swift "/home/user/.swiftenv/shims/swift")
else()
    set(Swift "/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin/swift")
endif()

file(GLOB_RECURSE SRC "*.swift")

add_custom_target(Smud
    COMMAND ${Swift} build
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    SOURCES ${SRC})

add_custom_target(SmudTest
    COMMAND ${Swift} test
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    SOURCES ${SRC})
