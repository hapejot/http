# generated file
cmake_minimum_required( VERSION 2.8 )
project(http)

set( CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR})
set( CMAKE_PREFIX_PATH ${CMAKE_SOURCE_DIR}/${CMAKE_HOST_SYSTEM_NAME} )
message(${CMAKE_SOURCE_DIR}/${CMAKE_HOST_SYSTEM_NAME} )



find_package(microhttp)
find_package(pthread)
find_package(hape_c)

include_directories(    include  
                        ${CMAKE_HOST_SYSTEM_NAME} 
                        ${HAPE_INCLUDE} )

add_definitions(-DBUILDNO="TEST" -DHAVE_STRUCT_TIMESPEC)

## Install the executable to <install_directory>/bin
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/bin)
## Install libraries (if any) to <install_directory>/bin
set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/bin )

file(GLOB WEB http.w)
set(LEXER ${PROJECT_SOURCE_DIR}/lexer.re )
# file(GLOB TEX http.tex)
set(TEX http.tex)
set(EXE run_http)
set(PDF http.pdf)

list(APPEND SOURCES ${CMAKE_CURRENT_BINARY_DIR}/dummy.c  )

add_library(http  ${SOURCES})
target_link_libraries( http PUBLIC ${PTHREAD_LIB} )

add_executable( ${EXE} http.c )
target_link_libraries( ${EXE} PUBLIC http )
target_link_libraries( ${EXE} PUBLIC ${HTTP_LIB} ${PTHREAD_LIB} )
install( TARGETS ${EXE} RUNTIME DESTINATION bin )

# add_executable( httpd-min  websocket_threaded_example.c lexer.c  )
# target_link_libraries( httpd-min PUBLIC ${HTTP_LIB} ${PTHREAD_LIB} )
# install( TARGETS httpd-min RUNTIME DESTINATION bin )

# add_executable( static-files  fileserver_example.c )
# target_link_libraries( static-files PUBLIC ${HTTP_LIB} ${PTHREAD_LIB} )
# install( TARGETS static-files RUNTIME DESTINATION bin )

add_custom_command( OUTPUT ${SOURCES} http.c
                    COMMAND ctangle ${WEB} || true
                    DEPENDS ${WEB} )
add_custom_command( OUTPUT ${TEX} 
                    COMMAND cweave ${WEB} || true
                    DEPENDS ${WEB})
add_custom_command( OUTPUT ${PDF} 
                    COMMAND pdftex ${TEX} 
                    COMMAND ${CMAKE_COMMAND} -E make_directory ${PROJECT_SOURCE_DIR}/doc
                    COMMAND ${CMAKE_COMMAND} -E copy ${PDF} ${PROJECT_SOURCE_DIR}/doc
                    DEPENDS ${TEX} )
add_custom_command( OUTPUT lexer.c
                    COMMAND re2c ${LEXER} -o lexer.c -ci )
add_custom_target( doc ALL DEPENDS ${PDF} )
