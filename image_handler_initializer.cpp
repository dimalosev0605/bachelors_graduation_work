#include "image_handler_initializer.h"

Initialization_flags operator | (Initialization_flags lhs, Initialization_flags rhs) {
    using T = std::underlying_type<Initialization_flags>::type;
    return static_cast<Initialization_flags>(static_cast<T>(lhs) | static_cast<T>(rhs));
}

Initialization_flags operator & (Initialization_flags lhs, Initialization_flags rhs) {
    using T = std::underlying_type<Initialization_flags>::type;
    return static_cast<Initialization_flags>(static_cast<T>(lhs) & static_cast<T>(rhs));
}

Image_handler_initializer::Image_handler_initializer(Initialization_flags some_initialization_flags, QObject* parent)
    : QThread(parent),
      initialization_flags(some_initialization_flags)
{
    qDebug() << this << " created in thread: " << QThread::currentThread();
}

void Image_handler_initializer::run()
{
    qDebug() << "Initialize in thread: " << QThread::currentThread();

    if(static_cast<bool>(initialization_flags & Initialization_flags::Hog_face_detector)) {
        qDebug() << "hog";
        hog_face_detector = dlib::get_frontal_face_detector();
        emit hog_face_detector_ready(hog_face_detector);
    }

    if(static_cast<bool>(initialization_flags & Initialization_flags::Shape_predictor)) {
        qDebug() << "shape";
        dlib::deserialize("shape_predictor_5_face_landmarks.dat") >> shape_predictor;
        emit shape_predictor_ready(shape_predictor);
    }

    if(static_cast<bool>(initialization_flags & Initialization_flags::Cnn_face_detector)) {
        qDebug() << "cnn";
        dlib::deserialize("mmod_human_face_detector.dat") >> cnn_face_detector;
        emit cnn_face_detector_ready(cnn_face_detector);
    }

    if(static_cast<bool>(initialization_flags & Initialization_flags::Face_recognition_dnn)) {
        qDebug() << "recognize";
        dlib::deserialize("dlib_face_recognition_resnet_model_v1.dat") >> face_recognition_dnn;
        emit face_recognition_dnn_ready(face_recognition_dnn);
    }
}

Image_handler_initializer::~Image_handler_initializer()
{
    qDebug() << this << " destroyed in thread " << QThread::currentThread();
}
