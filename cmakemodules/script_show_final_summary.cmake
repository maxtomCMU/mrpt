# ----------------------------------------------------------------------------
#   An auxiliary function to show messages:
# ----------------------------------------------------------------------------
macro(SHOW_CONFIG_LINE MSG_TEXT VALUE_BOOL)
	if(${VALUE_BOOL})
		set(VAL_TEXT "Yes")
	else(${VALUE_BOOL})
		set(VAL_TEXT " No")
	endif(${VALUE_BOOL})
	message(STATUS " ${MSG_TEXT} : ${VAL_TEXT} ${ARGV2}")
endmacro(SHOW_CONFIG_LINE)

macro(SHOW_CONFIG_LINE_SYSTEM MSG_TEXT VALUE_BOOL)
	if(${VALUE_BOOL})
		if(${VALUE_BOOL}_SYSTEM)
			set(VAL_TEXT "Yes (System)")
		else(${VALUE_BOOL}_SYSTEM)
			set(VAL_TEXT "Yes (Built-in)")
		endif(${VALUE_BOOL}_SYSTEM)
	else(${VALUE_BOOL})
		set(VAL_TEXT " No")
	endif(${VALUE_BOOL})
	message(STATUS " ${MSG_TEXT} : ${VAL_TEXT} ${ARGV2}")
endmacro(SHOW_CONFIG_LINE_SYSTEM)

# ----------------------------------------------------------------------------
#   Summary:
# ----------------------------------------------------------------------------
message(STATUS "")

message(STATUS "List of MRPT libs/modules to be built (and dependencies):")
message(STATUS "-----------------------------------------------------------------")
foreach(_LIB ${ALL_MRPT_LIBS})
	get_property(_LIB_DEP GLOBAL PROPERTY "mrpt-${_LIB}_LIB_DEPS")
	get_property(_LIB_HDRONLY GLOBAL PROPERTY "mrpt-${_LIB}_LIB_IS_HEADERS_ONLY")
	get_property(_LIB_METALIB GLOBAL PROPERTY "mrpt-${_LIB}_LIB_IS_METALIB")
	# Say whether each lib is a normal or header-only lib:
	set(_LIB_TYPE   "             ")
	if (_LIB_METALIB)
		set(_LIB_TYPE "(meta-lib)   ")
	elseif(_LIB_HDRONLY)
		set(_LIB_TYPE "(header-only)")
	endif(_LIB_METALIB)

	string(LENGTH "${_LIB}" LIBLEN)
	while(LIBLEN LESS 20)
		set(_LIB "${_LIB} ")
		string(LENGTH "${_LIB}" LIBLEN)
	endwhile()
	message(STATUS " ${_LIB} ${_LIB_TYPE} => ${_LIB_DEP}")
endforeach(_LIB)
message(STATUS "")

message(STATUS "+===========================================================================+")
message(STATUS "|         Resulting configuration for ${CMAKE_MRPT_COMPLETE_NAME}                            |")
message(STATUS "+===========================================================================+")
message(STATUS " _________________________ PLATFORM _____________________________")
message(STATUS " Host                        : "             ${CMAKE_HOST_SYSTEM_NAME} ${CMAKE_HOST_SYSTEM_VERSION} ${CMAKE_HOST_SYSTEM_PROCESSOR})
if(CMAKE_CROSSCOMPILING)
message(STATUS " Target                      : "         ${CMAKE_SYSTEM_NAME} ${CMAKE_SYSTEM_VERSION} ${CMAKE_SYSTEM_PROCESSOR})
endif(CMAKE_CROSSCOMPILING)
message(STATUS " Architecture (uname -m)     : " ${CMAKE_MRPT_ARCH})
message(STATUS " CMAKE_INSTALL_FULL_LIBDIR   : " ${CMAKE_INSTALL_FULL_LIBDIR})
SHOW_CONFIG_LINE("Is the system big endian?  " CMAKE_MRPT_IS_BIG_ENDIAN)
message(STATUS " Word size (32/64 bit)       : ${CMAKE_MRPT_WORD_SIZE}")
message(STATUS " CMake version               : " ${CMAKE_VERSION})
message(STATUS " CMake generator             : "  ${CMAKE_GENERATOR})
message(STATUS " CMake build tool            : " ${CMAKE_BUILD_TOOL})
if (UNIX)
  execute_process(COMMAND "date" "-u" "-d" "@${CMAKE_SOURCE_DATE_EPOCH}" "+%Y-%m-%d" OUTPUT_VARIABLE MRPT_BUILD_DATE OUTPUT_STRIP_TRAILING_WHITESPACE)
endif(UNIX)
message(STATUS " MRPT SOURCE_DATE_EPOCH      : ${CMAKE_SOURCE_DATE_EPOCH} (${MRPT_BUILD_DATE})")

message(STATUS " Compiler                    : ${CMAKE_CXX_COMPILER} Version: ${CMAKE_CXX_COMPILER_VERSION}")
if(NOT CMAKE_GENERATOR MATCHES "Xcode|Visual Studio")
	message(STATUS " Configuration               : "  ${CMAKE_BUILD_TYPE})
endif(NOT CMAKE_GENERATOR MATCHES "Xcode|Visual Studio")

message(STATUS " C++ flags                   : ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE}}")
message(STATUS " clang-tidy checks           : ${CLANG_TIDY_CHECKS}")

message(STATUS "")
message(STATUS " __________________________ OPTIONS _____________________________")
SHOW_CONFIG_LINE("Build MRPT as a shared library?  " CMAKE_MRPT_BUILD_SHARED_LIB_ONOFF)

if(MRPT_AUTODETECT_SSE)
	set(STR_SSE_DETECT_MODE "Automatic")
else(MRPT_AUTODETECT_SSE)
	set(STR_SSE_DETECT_MODE "Manually set")
endif(MRPT_AUTODETECT_SSE)
message(STATUS " Use SIMD optimizations?           : SSE2=" ${CMAKE_MRPT_HAS_SSE2} " SSE3=" ${CMAKE_MRPT_HAS_SSE3} " SSE4.1=" ${CMAKE_MRPT_HAS_SSE4_1} " SSE4.2=" ${CMAKE_MRPT_HAS_SSE4_2} " SSE4a=" ${CMAKE_MRPT_HAS_SSE4_A} " [" ${STR_SSE_DETECT_MODE} "]")

if($ENV{VERBOSE})
	SHOW_CONFIG_LINE("Additional checks even in Release  " CMAKE_MRPT_ALWAYS_CHECKS_DEBUG)
	SHOW_CONFIG_LINE("Additional matrix checks           " CMAKE_MRPT_ALWAYS_CHECKS_DEBUG_MATRICES)
endif($ENV{VERBOSE})
message(STATUS " Install prefix                    : ${CMAKE_INSTALL_PREFIX}")
message(STATUS " C++ config header                 : ${MRPT_CONFIG_FILE_INCLUDE_DIR}")
message(STATUS "")

if($ENV{VERBOSE})
	message(STATUS " _________________________ COMPILER OPTIONS _____________________")
	message(STATUS "Compiler:                  ${CMAKE_CXX_COMPILER} Version: ${CMAKE_CXX_COMPILER_VERSION} ")
	message(STATUS "  C++ flags (Release):       ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}")
	message(STATUS "  C++ flags (Debug):         ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")
	message(STATUS "  Executable link flags (Release):    ${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
	message(STATUS "  Executable link flags (Debug):      ${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS_DEBUG}")
	message(STATUS "  Lib link flags (Release):    ${CMAKE_SHARED_LINKER_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
	message(STATUS "  Lib link flags (Debug):      ${CMAKE_SHARED_LINKER_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS_DEBUG}")
	message(STATUS "")
endif($ENV{VERBOSE})

message(STATUS " _____________________ MANDATORY LIBRARIES ______________________")
SHOW_CONFIG_LINE_SYSTEM("eigen3                              " CMAKE_MRPT_HAS_EIGEN "[Version: ${MRPT_EIGEN_VERSION}]")
message(STATUS " - Assumed max. EIGEN_MAX_ALIGN_BYTES         : ${EIGEN_MAX_ALIGN_BYTES}")
message(STATUS " - Assumed max. EIGEN_MAX_STATIC_ALIGN_BYTES  : ${EIGEN_MAX_STATIC_ALIGN_BYTES}")
SHOW_CONFIG_LINE_SYSTEM("zlib (compression)                  " CMAKE_MRPT_HAS_ZLIB)
message(STATUS "")

message(STATUS " ______________________ OPTIONAL LIBRARIES ______________________")
SHOW_CONFIG_LINE_SYSTEM("Assimp (3D models)                  " CMAKE_MRPT_HAS_ASSIMP "[Version: ${ASSIMP_VERSION}]")
SHOW_CONFIG_LINE_SYSTEM("ffmpeg libs (Video streaming)       " CMAKE_MRPT_HAS_FFMPEG "[avcodec ${LIBAVCODEC_VERSION}, avutil ${LIBAVUTIL_VERSION}, avformat ${LIBAVFORMAT_VERSION}]")
SHOW_CONFIG_LINE_SYSTEM("gtest (Google unit testing library) " CMAKE_MRPT_HAS_GTEST )
SHOW_CONFIG_LINE_SYSTEM("jsoncpp (JSON format serialization) " CMAKE_MRPT_HAS_JSONCPP "[Version: ${jsoncpp_VERSION}]")
SHOW_CONFIG_LINE_SYSTEM("libjpeg (jpeg)                      " CMAKE_MRPT_HAS_JPEG)
SHOW_CONFIG_LINE_SYSTEM("liblas (ASPRS LAS LiDAR format)     " CMAKE_MRPT_HAS_LIBLAS)
SHOW_CONFIG_LINE       ("mexplus                             " CMAKE_MRPT_HAS_MATLAB)
SHOW_CONFIG_LINE_SYSTEM("Octomap                             " CMAKE_MRPT_HAS_OCTOMAP "[Version: ${OCTOMAP_VERSION}]")
SHOW_CONFIG_LINE_SYSTEM("OpenCV (Image manipulation)         " CMAKE_MRPT_HAS_OPENCV "[Version: ${MRPT_OPENCV_VERSION}]")
SHOW_CONFIG_LINE_SYSTEM("OpenGL                              " CMAKE_MRPT_HAS_OPENGL_GLUT)
SHOW_CONFIG_LINE_SYSTEM("GLUT                                " CMAKE_MRPT_HAS_GLUT)
SHOW_CONFIG_LINE_SYSTEM("PCAP (Wireshark logs for Velodyne)  " CMAKE_MRPT_HAS_LIBPCAP)
SHOW_CONFIG_LINE_SYSTEM("PCL (Pointscloud library)           " CMAKE_MRPT_HAS_PCL  "[Version: ${PCL_VERSION}]")
SHOW_CONFIG_LINE_SYSTEM("SuiteSparse                         " CMAKE_MRPT_HAS_SUITESPARSE)
SHOW_CONFIG_LINE("VTK                                 " CMAKE_MRPT_HAS_VTK)
SHOW_CONFIG_LINE_SYSTEM("wxWidgets                           " CMAKE_MRPT_HAS_WXWIDGETS "[Version: ${wxWidgets_VERSION_STRING}]")
SHOW_CONFIG_LINE_SYSTEM("yamlcpp (YAML file format)          " CMAKE_MRPT_HAS_YAMLCPP "[Version: ${LIBYAMLCPP_VERSION}]")
message(STATUS  "")

message(STATUS " ______________________ GUI LIBRARIES ______________________")
SHOW_CONFIG_LINE       ("wxWidgets                           " CMAKE_MRPT_HAS_WXWIDGETS)
SHOW_CONFIG_LINE       ("Qt5                                 " CMAKE_MRPT_HAS_Qt5)
message(STATUS  "")

message(STATUS " _______________________ WRAPPERS/BINDINGS ______________________")
SHOW_CONFIG_LINE_SYSTEM("Matlab / mex files        " CMAKE_MRPT_HAS_MATLAB "[Version: ${MATLAB_VERSION}]")
SHOW_CONFIG_LINE("Python bindings (pymrpt)  " CMAKE_MRPT_HAS_PYTHON_BINDINGS)
SHOW_CONFIG_LINE(" - dep: Boost found?      " Boost_FOUND)
SHOW_CONFIG_LINE(" - dep: PythonLibs found? " PYTHONLIBS_FOUND)
#SHOW_CONFIG_LINE("ROS1 (ros_comm)           " CMAKE_MRPT_HAS_ROS)
message(STATUS "")

message(STATUS " _____________________ HARDWARE & SENSORS _______________________")
SHOW_CONFIG_LINE_SYSTEM("libdc1394-2 (FireWire capture)      " CMAKE_MRPT_HAS_LIBDC1394_2)
SHOW_CONFIG_LINE("DUO3D Camera libs                   " CMAKE_MRPT_HAS_DUO3D)
SHOW_CONFIG_LINE("Flir FlyCapture2                    " CMAKE_MRPT_HAS_FLYCAPTURE2)
SHOW_CONFIG_LINE("Flir Triclops                       " CMAKE_MRPT_HAS_TRICLOPS)
if(UNIX)
SHOW_CONFIG_LINE_SYSTEM("libftdi (USB)                       " CMAKE_MRPT_HAS_FTDI "[Version: ${LIBFTDI_VERSION_STRING}]")
endif(UNIX)
message(STATUS " National Instruments...")
SHOW_CONFIG_LINE("...NIDAQmx?                         " CMAKE_MRPT_HAS_NIDAQMX)
SHOW_CONFIG_LINE("...NIDAQmx Base?                    " CMAKE_MRPT_HAS_NIDAQMXBASE)
SHOW_CONFIG_LINE_SYSTEM("NITE2 library                       " CMAKE_MRPT_HAS_NITE2)
SHOW_CONFIG_LINE_SYSTEM("OpenKinect libfreenect              " CMAKE_MRPT_HAS_FREENECT)
SHOW_CONFIG_LINE_SYSTEM("OpenNI2                             " CMAKE_MRPT_HAS_OPENNI2)
SHOW_CONFIG_LINE_SYSTEM("Phidgets                            " CMAKE_MRPT_HAS_PHIDGET)
SHOW_CONFIG_LINE("RoboPeak LIDAR                      " CMAKE_MRPT_HAS_ROBOPEAK_LIDAR)
SHOW_CONFIG_LINE_SYSTEM("SwissRanger 3/4000 3D camera        " CMAKE_MRPT_HAS_SWISSRANGE )
SHOW_CONFIG_LINE_SYSTEM("Videre SVS stereo camera            " CMAKE_MRPT_HAS_SVS)
if(UNIX)
SHOW_CONFIG_LINE_SYSTEM("libudev (requisite for XSensMT4)    " CMAKE_MRPT_HAS_LIBUDEV)
endif(UNIX)
SHOW_CONFIG_LINE_SYSTEM("xSENS MT 3rd generation             " CMAKE_MRPT_HAS_xSENS_MT3)
SHOW_CONFIG_LINE_SYSTEM("xSENS MT 4th generation             " CMAKE_MRPT_HAS_xSENS_MT4)
SHOW_CONFIG_LINE_SYSTEM("Intersense sensors                  " CMAKE_MRPT_HAS_INTERSENSE)
message(STATUS  "")

# Final warnings:
if (NOT CMAKE_MRPT_HAS_OPENCV AND NOT DISABLE_OPENCV)
	message(STATUS "")
	message(STATUS "***********************************************************************")
	message(STATUS "* WARNING: It's STRONGLY recommended to build MRPT with OpenCV support.")
	message(STATUS "*  To do so, set OpenCV_DIR to its CMake build dir. If you want to go ")
	message(STATUS "*  on without OpenCV, proceed to build instead. ")
	message(STATUS "***********************************************************************")
	message(STATUS "")
endif(NOT CMAKE_MRPT_HAS_OPENCV AND NOT DISABLE_OPENCV)
