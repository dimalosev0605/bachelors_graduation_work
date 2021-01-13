#include "auto_image_handler.h"

Auto_image_handler::Auto_image_handler(QObject *parent) : QObject(parent)
{
    Image_handler_initializer* image_handler_initializer = new Image_handler_initializer;
    connect(image_handler_initializer, &Image_handler_initializer::hog_face_detector_ready, this, &Auto_image_handler::receive_hog_face_detector);
    connect(image_handler_initializer, &Image_handler_initializer::cnn_face_detector_ready, this, &Auto_image_handler::receive_cnn_face_detector);
    connect(image_handler_initializer, &Image_handler_initializer::shape_predictor_ready, this, &Auto_image_handler::receive_shape_predictor);
    connect(image_handler_initializer, &Image_handler_initializer::finished, image_handler_initializer, &Image_handler_initializer::deleteLater);
    image_handler_initializer->start();
}

void Auto_image_handler::curr_image_changed(const QString& curr_img_path)
{
    dlib::load_image(img_with_target_face, curr_img_path.toStdString());
}

void Auto_image_handler::receive_hog_face_detector(hog_face_detector_type& some_hog_face_detector)
{
    hog_face_detector = std::move(some_hog_face_detector);
}

void Auto_image_handler::receive_cnn_face_detector(cnn_face_detector_type& some_cnn_face_detector)
{
    cnn_face_detector = std::move(some_cnn_face_detector);
    // Image_handler_initializer emits signal for this slot last of all.
    set_is_ok_enable(true);
}

void Auto_image_handler::receive_shape_predictor(dlib::shape_predictor& some_shape_predictor)
{
    shape_predictor = std::move(some_shape_predictor);
}

bool Auto_image_handler::get_is_ok_enable() const
{
    return is_ok_enable;
}

void Auto_image_handler::set_is_ok_enable(const bool some_value)
{
    is_ok_enable = some_value;
    emit is_ok_enable_changed();
}

void Auto_image_handler::process_target_face()
{
    set_is_busy_indicator_running(true);

    Image_handler_worker* worker = new Image_handler_worker;

    connect(this, &Auto_image_handler::start_process_target_face, worker, &Image_handler_worker::process_target_face);
//    connect() // на мессейдж ошибки
    connect(worker, &Image_handler_worker::img_ready, this, &Auto_image_handler::img_ready_slot);

    emit start_process_target_face(++worker_thread_id, img_with_target_face, hog_face_detector, cnn_face_detector, shape_predictor, face_chip_size, face_chip_padding);
}

bool Auto_image_handler::get_is_busy_indicator_running() const
{
    return is_busy_indicator_running;
}

void Auto_image_handler::set_is_busy_indicator_running(const bool some_value)
{
    is_busy_indicator_running = some_value;
    emit is_busy_indicator_running_changed();
}

void Auto_image_handler::img_ready_slot(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img)
{
    if(worker_thread_id == some_worker_thread_id) {
        qDebug() << "Update target face image.";
        target_face = some_img;
        send_image_data_ready_signal();
        set_is_busy_indicator_running(false);
    }
    else {
        qDebug() << "Ignore target face image.";
    }
}

void Auto_image_handler::send_image_data_ready_signal()
{
    const auto data = dlib::image_data(target_face);
    Image_data image_data(data, target_face.nc(), target_face.nr());
    emit image_data_ready(image_data);
}


