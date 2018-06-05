project (com.github.allen-b1.news)
cmake_minimum_required (VERSION 2.6)

# tell cmake where its modules can be found in our project directory
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/src)

# where we install data directory (if we have any)
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/com.github.allen-b1.news")

set (EXEC_NAME "com.github.allen-b1.news")
set (RELEASE_NAME "Browse the news")
set (COMMENT "Browse the news")
set (VERSION "1.0")
set (VERSION_INFO "v1.0 release")

find_package(PkgConfig)

pkg_check_modules(DEPS REQUIRED gtk+-3.0 glib-2.0 webkit2gtk-4.0 granite libxml-2.0)
add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.16" MINIMUM)

include(ValaPrecompile)
vala_precompile(VALA_C ${EXEC_NAME}
    src/Application.vala
    src/NewsHeaderBar.vala
    src/NewsList.vala
    src/NewsPanel.vala
    src/NewsParse.vala
    src/NewsNotebook.vala

PACKAGES
    gtk+-3.0
    webkit2gtk-4.0
    granite
    libxml-2.0
)

add_executable(${EXEC_NAME} ${VALA_C})
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)

# install our .desktop file so the Applications menu will see it
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.allen-b1.news.desktop DESTINATION ${DATADIR}/applications/)

# install icon
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.allen-b1.news.svg DESTINATION ${DATADIR}/icons/hicolor/128x128/apps)

# install our .appdata.xml file so AppCenter will see it
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.allen-b1.news.appdata.xml DESTINATION ${DATADIR}/metainfo/)
