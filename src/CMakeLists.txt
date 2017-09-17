cmake_minimum_required(VERSION 2.8.10)
project(pulse C CXX)

set(pulse_VERSION 0.6)

message("pulse_SOURCE_DIR = ${pulse_SOURCE_DIR}")
message("pulse_BINARY_DIR = ${pulse_BINARY_DIR}")
set(CMAKE_BUILD_TYPE "Debug")
# --------------------------------------------------
if("${CMAKE_BUILD_TYPE}" MATCHES "Debug")
  add_definitions(-DDEBUG)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -g -O0 -fPIC")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99 -g -O0 -fPIC -D_POSIX_C_SOURCE=200809")
else()
  add_definitions(-DARMA_NO_DEBUG)
  add_definitions(-DNDEBUG)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -O3 -fPIC")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99 -O3 -fPIC -D_POSIX_C_SOURCE=200809")
endif()

option(PROFILE "Compile with profiling information" OFF)
# Profiling CFLAGS.  Turn profiling information on.
if(PROFILE)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pg")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pg")
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -pg")
endif(PROFILE)

# --------------------------------------------------
#opencv
# --------------------------------------------------
message("OPENCV_BRANCH=$ENV{OPENCV_BRANCH}")
string( SUBSTRING "$ENV{OPENCV_BRANCH}" 0 4 OPENCV_MAJOR)
message("OPENCV_MAJOR=${OPENCV_MAJOR}")

if(ANDROID_NDK)
	#if(${APP_ABI} STREQUAL "armeabi-v7a" )
		#openCV 3.2.0 SDK by "make install"
		#CV_MAJOR_VERSION==3
		set(OpenCV_DIR $ENV{OPENCV_OUT}/${APP_ABI}/sdk/native/jni)
		include( "${OpenCV_DIR}/OpenCVConfig.cmake" )
		message("++++OpenCV_DIR:${OpenCV_DIR}")
		FIND_PACKAGE( OpenCV REQUIRED)
		if(OpenCV_FOUND)
			message("found")
			message( "OpenCV_INCLUDE_DIRS:${OpenCV_INCLUDE_DIRS}" )
			message( "OpenCV_INCLUDES:${OpenCV_INCLUDES}")
			message( "OpenCV_LIBRARIES:${OpenCV_LIBRARIES}")
			message( "OpenCV_LIBS:${OpenCV_LIBS}")
			message( "OpenCV_DEFINITIONS:${OpenCV_DEFINITIONS}")
			add_definitions(-DUSE_OPENCV=${USE_OPENCV})
			set(OPENCV_BRANCH $ENV{OPENCV_BRANCH})
			include_directories(${OpenCV_INCLUDE_DIRS})
		else()
			message(FATAL_ERROR "openCV not foud")
		endif()
	#endif()
else()
#opencv should be built first!
	set(OpenCV_DIR $ENV{OPENCV_OUT})
	#set(OpenCV_DIR "/home/thomas/opencv/build_2.4.13/debug")
	#set(OpenCV_DIR "/home/thomas/build/bcv-x86.gl/out/opencv/2.4.x-static/x86_64")
	#set(OpenCV_DIR "/home/thomas/opencv/build_3.2.0/debug")
	#add_definitions(-DOPENCV_VER=2)
	message("++++OpenCV_DIR:${OpenCV_DIR}")
	FIND_PACKAGE( OpenCV REQUIRED)
	if(OpenCV_FOUND)
		message("found")
		message( "OpenCV_INCLUDE_DIRS:${OpenCV_INCLUDE_DIRS}" )
		message( "OpenCV_INCLUDES:${OpenCV_INCLUDES}")
		message( "OpenCV_LIBRARIES:${OpenCV_LIBRARIES}")
		message( "OpenCV_LIBS:${OpenCV_LIBS}")
		message( "OpenCV_DEFINITIONS:${OpenCV_DEFINITIONS}")
		add_definitions(-DUSE_OPENCV=${USE_OPENCV})
		set(OPENCV_BRANCH $ENV{OPENCV_BRANCH})
		include_directories(${OpenCV_INCLUDE_DIRS})
	else()
		message(FATAL_ERROR "openCV not foud")
	endif()

	message("*** OpenCV_LIBS:${OpenCV_LIBS}")
	message("*** OpenCV_LIBRARIES:${OpenCV_LIBRARIES}")
endif()

# --------------------------------------------------
# Make a target to generate the documentation.  If Doxygen isn't installed, then
# I guess this option will just be unavailable.
if (NOT DOXYGEN_FOUND)
	find_package(Doxygen)

	if(ANDROID_NDK OR ARM_LINUX_SYSROOT)
	find_host_package(Doxygen)
	endif()

	if (DOXYGEN_FOUND)
	# Preprocess the Doxyfile.  This is done before 'make doc'.
	add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/Doxyfile
		PRE_BUILD
		COMMAND ${CMAKE_COMMAND} -D DESTDIR="${CMAKE_BINARY_DIR}" -P
			"${CMAKE_CURRENT_SOURCE_DIR}/CMake/GenerateDoxyfile.cmake"
		WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
		COMMENT "Creating Doxyfile to generate Doxygen documentation"
	)

	# Generate documentation.
	add_custom_target(doc
		COMMAND "${DOXYGEN_EXECUTABLE}" "${CMAKE_BINARY_DIR}/Doxyfile"
		DEPENDS "${CMAKE_BINARY_DIR}/Doxyfile"
		WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
		COMMENT "Generating API documentation with Doxygen"
	)

	install(DIRECTORY ${CMAKE_BINARY_DIR}/doc/html
		DESTINATION share/doc/mlpack
		COMPONENT doc
		OPTIONAL
	)
	endif (DOXYGEN_FOUND)
endif (NOT DOXYGEN_FOUND)

if(ARM_LINUX_SYSROOT OR ANDROID_NDK)
	# ---------------------------------------------------------
	# switch searching path to arm toolchains for system libs
	# ---------------------------------------------------------
	#CMAKE_FIND_ROOT_PATH_MODE : searching paths in the toolchain
	#NEVER : never searching toolchain path, so cmake will search host path
	#ONLY : searching only paths in the toolchain, so cmake won't search host PC path
	message("ARM_LINUX_SYSROOT=${ARM_LINUX_SYSROOT}")
	set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
	set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
	set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
endif()

# --------------------------------------------------
#openMP to avoid link error : omp_xxx error!
# undefined reference to `GOMP_loop_dynamic_start
find_package(OpenMP)
if(OPENMP_FOUND)
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
	add_definitions(-DENABLE_OPENMP)
endif()

# ---------------------------------------------------------
# NEVER : switch searching path to host, not NDK toolchain
# only bcv projects proprietary lib and binary are searched,
# toolchain's system binary are not searched with NO_DEFAULT_PATH.
# ---------------------------------------------------------
if(ANDROID_NDK OR ARM_LINUX_SYSROOT)
set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER )
set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER )
endif()

# --------------------------------------------------
if("${OPENCV_MAJOR}" MATCHES "3.2.")
	message("xxx OPENCV_MAJOR=${OPENCV_MAJOR}")
	if(ANDROID_NDK)
		add_executable(pulse
			main.cpp
			Pulse.cpp
			Window.cpp
			EvmGdownIIR.cpp
			profiler/Profiler.cpp
			ext/opencv.cpp
		)
		if(OpenCL_FOUND)
			target_link_libraries(pulse
				${OpenCV_LIBS}
	#			${OpenCL_LIBRARY}
				m
				log
				stdc++
			)
		else()
			target_link_libraries(pulse
				${OpenCV_LIBS}
				m
				log
				stdc++
			)
		endif()

	elseif(ARM_LINUX_SYSROOT)
		#arm embedded linux
		add_executable(pulse
				main.cpp
				Pulse.cpp
				Window.cpp
				EvmGdownIIR.cpp
				profiler/Profiler.cpp
				ext/opencv.cpp
			)
		if( OpenCL_FOUND )
		#no opencl yet
			target_link_libraries(pulse
	#			${OpenCL_LIBRARY}
				m
				stdc++
			)
		else()
			target_link_libraries(pulse
				m
				stdc++
			)
		endif()
	else()
	#ubuntu
		add_executable(pulse
			main.cpp
			Pulse.cpp
			Window.cpp
			EvmGdownIIR.cpp
			profiler/Profiler.cpp
			ext/opencv.cpp
		)
		if(OpenCL_FOUND)
			target_link_libraries(pulse
				${OpenCL_LIBRARY}
				${OpenCV_LIBS}
				m
				stdc++
			)
		else()
			target_link_libraries(pulse
				${OpenCV_LIBS}
				m
				stdc++
			)
		endif()
	endif()
endif()