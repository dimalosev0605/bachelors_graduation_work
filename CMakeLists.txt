cmake_minimum_required(VERSION 3.5)

project(face_rec_diplom LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt5 COMPONENTS Core Quick REQUIRED)
find_package(dlib REQUIRED)
find_package(OpenCV REQUIRED)

include_directories(${OpenCV_INCLUDE_DIRS})

add_executable(face_rec_diplom
  main.cpp
  qml.qrc

  file_system/dir_names.h
  file_system/dir_paths.h
  file_system/dir_paths.cpp
  file_system/default_dir_creator.h
  file_system/default_dir_creator.cpp
  file_system/individual_file_manager.h
  file_system/individual_file_manager.cpp
  file_system/individual_checker.h
  file_system/individual_checker.cpp

  models/selected_imgs.h
  models/selected_imgs.cpp
  models/all_people.h
  models/all_people.cpp

  image_provider.h
  image_provider.cpp

  image_data.h
  image_data.cpp

  image_handler.h
  image_handler.cpp

  auto_image_handler.h
  auto_image_handler.cpp

  image_handler_initializer.h
  image_handler_initializer.cpp

  image_handler_worker.h
  image_handler_worker.cpp
)


target_compile_definitions(face_rec_diplom
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(face_rec_diplom
  PRIVATE Qt5::Core Qt5::Quick dlib::dlib ${OpenCV_LIBS})
