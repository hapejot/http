# generated file
cmake_minimum_required( VERSION 2.8 )
project(http)
include_directories( include )
add_definitions(-DBUILDNO="TEST")

## Install the executable to <install_directory>/bin
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/bin)
## Install libraries (if any) to <install_directory>/bin
set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/bin )

file(GLOB WEB http.w)
# file(GLOB TEX http.tex)
set(TEX http.tex)
set(EXE run_http)
set(PDF http.pdf)

list(APPEND SOURCES ${CMAKE_CURRENT_BINARY_DIR}/dummy.c  )

add_library(http SHARED ${SOURCES})
add_executable( ${EXE} http.c )
target_link_libraries( ${EXE} PUBLIC http )
install( TARGETS ${EXE} RUNTIME DESTINATION bin )

add_executable( httpd-min  websocket_threaded_example.c )
target_link_libraries( httpd-min microhttpd pthread )
install( TARGETS httpd-min RUNTIME DESTINATION bin )


add_custom_command( OUTPUT ${SOURCES} http.c
                    COMMAND ctangle ${WEB}
                    DEPENDS ${WEB} )
add_custom_command( OUTPUT ${TEX} 
                    COMMAND cweave ${WEB}
                    DEPENDS ${WEB})
add_custom_command( OUTPUT ${PDF} 
                    COMMAND pdftex ${TEX} 
                    COMMAND ${CMAKE_COMMAND} -E make_directory ${PROJECT_SOURCE_DIR}/doc
                    COMMAND ${CMAKE_COMMAND} -E copy ${PDF} ${PROJECT_SOURCE_DIR}/doc
                    DEPENDS ${TEX} )
add_custom_target( doc ALL DEPENDS ${PDF} )
