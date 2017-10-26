 # project name
project (com.github.allen-b1.news)

# the oldest stable cmake version we support
cmake_minimum_required (VERSION 2.6)

# tell cmake where its modules can be found in our project directory
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/src)

# where we install data directory (if we have any)
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")

# what to call that directory where we install data too
set (PKGDATADIR "${DATADIR}/com.github.allen-b1.news")

set (EXEC_NAME "com.github.allen-b1.news")
set (VERSION "0.1")
set (VERSION_INFO "initial")

set (DEPS_PACKAGES
    gtk+-3.0
    granite
    webkit2gtk-4.0
    libxml-2.0
)

find_package (PkgConfig)
pkg_check_modules (DEPS REQUIRED ${DEPS_PACKAGES})

add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

# make sure we have vala
find_package(Vala REQUIRED)
# make sure we use vala
include(ValaVersion)
# make sure it's the desired version of vala
ensure_vala_version("0.16" MINIMUM)

#------------------------------------------------------------------------------------------

# files we want to compile
include(ValaPrecompile)
vala_precompile(VALA_C ${EXEC_NAME}
    src/news.vala
    src/NewsAboutDialog.vala
    src/NewsHeaderBar.vala
    src/NewsList.vala
    src/NewsPanel.vala
    src/NewsParse.vala
    src/widgets.vala

# tell what libraries to use when compiling
PACKAGES
    gtk+-3.0
    granite
    webkit2gtk-4.0
    libxml-2.0
)

# tell cmake what to call the executable we just made
add_executable(${EXEC_NAME} ${VALA_C})

# install the binaries we just made
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)

#add the data directory and activated the cmakelists in that folder
add_subdirectory (data)
