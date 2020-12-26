#include "image_handler.h"

Image_handler::Image_handler(QObject* parent)
    : QObject(parent)
{
    Image_handler_initializer* image_handler_initializer = new Image_handler_initializer(this);
    connect(image_handler_initializer, &Image_handler_initializer::hog_face_detector_ready, this, &Image_handler::receive_hog_face_detector);
    connect(image_handler_initializer, &Image_handler_initializer::shape_predictor_ready, this, &Image_handler::receive_shape_predictor);
    connect(image_handler_initializer, &Image_handler_initializer::finished, image_handler_initializer, &Image_handler_initializer::deleteLater);
    image_handler_initializer->start();
}

void Image_handler::curr_image_changed(const QString& curr_img_path)
{
//    qDebug() << "In Image_handler::curr_image_changed()";

//    qDebug() << "curr_img_path = " << curr_img_path;

    dlib::load_image(img, curr_img_path.toStdString());

    const auto data = dlib::image_data(img);
    Image_data image_data(data, img.nc(), img.nr());

    emit image_data_ready(image_data);
}

void Image_handler::receive_hog_face_detector(const hog_face_detector_type& some_hog_face_detector)
{
    qDebug() << "In receive_hog_face_detector(), thread: " << QThread::currentThread();
    hog_face_detector = some_hog_face_detector;
}

void Image_handler::receive_shape_predictor(const dlib::shape_predictor& some_shape_predictor)
{
    qDebug() << "In receive_shape_predictor(), thread: " << QThread::currentThread();
    shape_predictor = some_shape_predictor;
}
