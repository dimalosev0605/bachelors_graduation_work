#include "image_handler_initializer.h"

Image_handler_initializer::Image_handler_initializer(QObject* parent)
    : QThread(parent)
{
    qDebug() << this << " created in thread: " << QThread::currentThread();
}

void Image_handler_initializer::run()
{
    qDebug() << "Initialize in thread: " << QThread::currentThread();

    dlib::deserialize("shape_predictor_5_face_landmarks.dat") >> shape_predictor;
    dlib::deserialize("mmod_human_face_detector.dat") >> cnn_face_detector;
    dlib::deserialize("dlib_face_recognition_resnet_model_v1.dat") >> face_recognition_dnn;

    hog_face_detector = dlib::get_frontal_face_detector();

    emit shape_predictor_ready(shape_predictor);
    emit hog_face_detector_ready(hog_face_detector);
    emit cnn_face_detector_ready(cnn_face_detector);
    emit face_recognition_dnn_ready(face_recognition_dnn);
}

Image_handler_initializer::~Image_handler_initializer()
{
    qDebug() << this << " destroyed in thread " << QThread::currentThread();
}
