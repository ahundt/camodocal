include(CompareVersionStrings)
include(DependencyUtilities)
include(FindPackageHandleStandardArgs)

# Prevent CMake from finding libraries in the installation folder on Windows.
# There might already be an installation from another compiler
if(DEPENDENCY_PACKAGE_ENABLE)
  list(REMOVE_ITEM CMAKE_SYSTEM_PREFIX_PATH  "${CMAKE_INSTALL_PREFIX}")
  list(REMOVE_ITEM CMAKE_SYSTEM_LIBRARY_PATH "${CMAKE_INSTALL_PREFIX}/bin")
endif()


# Enable C++11
include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)

if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64") 
	ADD_DEFINITIONS(-fPIC)
endif(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")

if(COMPILER_SUPPORTS_CXX11)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
elseif(COMPILER_SUPPORTS_CXX0X)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
else()
    message(FATAL_ERROR "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support, or our tests failed to detect it correctly. Please use a different C++ compiler or report this problem to the developers.")
endif()

############### Library finding #################
# Performs the search and sets the variables    #
camodocal_required_dependency(BLAS)
camodocal_optional_dependency(CUDA)
camodocal_required_dependency(Eigen3)
camodocal_required_dependency(LAPACK)
camodocal_required_dependency(SuiteSparse)

camodocal_optional_dependency(GTest)
camodocal_optional_dependency(OpenMP)
camodocal_optional_dependency(Glog)
camodocal_optional_dependency(Gflags)
camodocal_optional_dependency(TBB)
camodocal_optional_dependency(OpenCV)

# Consider making this impossible to use external Ceres again due to the following possible issue:
# https://github.com/ceres-solver/ceres-solver/issues/155
# essentially, invsible ABI changes are possible depending on eigen flags
# and the best way to prevent this is to compile everything internally, including ceres
#camodocal_optional_dependency(Ceres)
camodocal_optional_dependency(Threads)

# enable GPU enhanced SURF features
if(CUDA_FOUND)
    add_definitions(-DHAVE_CUDA)
	message(STATUS "defined HAVE_CUDA")

    set(CUDA_CUDART_LIBRARY_OPTIONAL ${CUDA_CUDART_LIBRARY})
endif()

if(OpenCV_FOUND)
	message(STATUS "OpenCV version: "${OpenCV_VERSION})
    if(NOT OpenCV_VERSION VERSION_LESS "3.0.0")
        add_definitions(-DHAVE_OPENCV3)
		message(STATUS "defined HAVE_OPENCV3")
    endif()
endif()

# OSX RPATH
if(APPLE)
   set(CMAKE_MACOSX_RPATH ON)
endif()

##### Boost #####
# Expand the next statement if newer boost versions than 1.40.0 are released
set(Boost_ADDITIONAL_VERSIONS "1.40" "1.40.0" "1.49" "1.49.0")

find_package(Boost 1.40 REQUIRED COMPONENTS filesystem program_options serialization system thread)

# MSVC seems to be the only compiler requiring date_time
if(MSVC)
  find_package(Boost 1.40 REQUIRED date_time)
endif(MSVC)

# No auto linking, so this option is useless anyway
mark_as_advanced(Boost_LIB_DIAGNOSTIC_DEFINITIONS)
