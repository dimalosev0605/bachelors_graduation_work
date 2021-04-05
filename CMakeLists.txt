cmake_minimum_required(VERSION 3.5)

project(face_rec_diplom LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt5 COMPONENTS Core Quick QuickControls2 LinguistTools REQUIRED)
find_package(dlib REQUIRED)
find_package(OpenCV REQUIRED)

set(TRANSLATIONS_DIR "${CMAKE_SOURCE_DIR}/translations")
file(GLOB TS_FILES "${TRANSLATIONS_DIR}/*.ts")
qt5_add_translation(QM_FILES ${TS_FILES})

include_directories(${OpenCV_INCLUDE_DIRS})

add_executable(face_rec_diplom
  main.cpp
  qml.qrc
  ${QM_FILES}

  file_system/dir_names.h
  file_system/dir_paths.h
  file_system/dir_paths.cpp
  file_system/default_dir_creator.h
  file_system/default_dir_creator.cpp
  file_system/individual_file_manager.h
  file_system/individual_file_manager.cpp
  file_system/individual_checker.h
  file_system/individual_checker.cpp
  file_system/janitor.h
  file_system/janitor.cpp

  models/selected_imgs.h
  models/selected_imgs.cpp
  models/base_people.h
  models/base_people.cpp
  models/available_people.h
  models/available_people.cpp
  models/selected_people.h
  models/selected_people.cpp

  image_provider.h
  image_provider.cpp

  image_data.h
  image_data.cpp

  image_handler.h
  image_handler.cpp

  auto_image_handler.h
  auto_image_handler.cpp

  recognition_image_handler.h
  recognition_image_handler.cpp

  image_handler_initializer.h
  image_handler_initializer.cpp

  image_handler_worker.h
  image_handler_worker.cpp

  video_capture.h
  video_capture.cpp

  style_control.h
  style_control.cpp

  language_switcher.h
  language_switcher.cpp

  video_file_capture.h
  video_file_capture.cpp
)


target_compile_definitions(face_rec_diplom
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(face_rec_diplom
  PRIVATE Qt5::Core Qt5::Quick dlib::dlib Qt5::QuickControls2 ${OpenCV_LIBS})
