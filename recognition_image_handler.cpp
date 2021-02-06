#include "recognition_image_handler.h"

Recognition_image_handler::Recognition_image_handler(QObject *parent) : QObject(parent)
{
    Image_handler_initializer* image_handler_initializer = new Image_handler_initializer;
    connect(image_handler_initializer, &Image_handler_initializer::hog_face_detector_ready, this, &Recognition_image_handler::receive_hog_face_detector);
    connect(image_handler_initializer, &Image_handler_initializer::cnn_face_detector_ready, this, &Recognition_image_handler::receive_cnn_face_detector);
    connect(image_handler_initializer, &Image_handler_initializer::shape_predictor_ready, this, &Recognition_image_handler::receive_shape_predictor);
    connect(image_handler_initializer, &Image_handler_initializer::face_recognition_dnn_ready, this, &Recognition_image_handler::receive_face_recognition_dnn);
    connect(image_handler_initializer, &Image_handler_initializer::finished, image_handler_initializer, &Image_handler_initializer::deleteLater);
    image_handler_initializer->start();
}

void Recognition_image_handler::send_image_data_ready_signal()
{
    const auto data = dlib::image_data(imgs.back());
    Image_data image_data(data, imgs.back().nc(), imgs.back().nr());
    if(imgs.size() == 1) {
        set_is_cancel_enabled(false);
    }
    else {
        set_is_cancel_enabled(true);
    }
    emit image_data_ready(image_data);
}

bool Recognition_image_handler::get_is_busy_indicator_running() const
{
    return is_busy_indicator_running;
}

void Recognition_image_handler::set_is_busy_indicator_running(const bool some_value)
{
    is_busy_indicator_running = some_value;
    emit is_busy_indicator_running_changed();
}

bool Recognition_image_handler::get_is_hog_enable() const
{
    return is_hog_enable;
}

void Recognition_image_handler::set_is_hog_enable(const bool some_value)
{
    is_hog_enable = some_value;
    emit is_hog_enable_changed();
}

bool Recognition_image_handler::get_is_cnn_enable() const
{
    return is_cnn_enable;
}

void Recognition_image_handler::set_is_cnn_enable(const bool some_value)
{
    is_cnn_enable = some_value;
    emit is_cnn_enable_changed();
}

bool Recognition_image_handler::get_is_recognize_enable() const
{
    return is_recognize_enable;
}

void Recognition_image_handler::set_is_recognize_enable(const bool some_value)
{
    is_recognize_enable = some_value;
    emit is_recognize_enable_changed();
}

bool Recognition_image_handler::get_is_cancel_enabled() const
{
    return is_cancel_enabled;
}

void Recognition_image_handler::set_is_cancel_enabled(const bool some_value)
{
    is_cancel_enabled = some_value;
    emit is_cancel_enabled_changed();
}

void Recognition_image_handler::receive_hog_face_detector(hog_face_detector_type& some_hog_face_detector)
{
    hog_face_detector = std::move(some_hog_face_detector);
    set_is_hog_enable(true);
}

void Recognition_image_handler::receive_cnn_face_detector(cnn_face_detector_type& some_cnn_face_detector)
{
    cnn_face_detector = std::move(some_cnn_face_detector);
    set_is_cnn_enable(true);
}

void Recognition_image_handler::receive_shape_predictor(dlib::shape_predictor& some_shape_predictor)
{
    shape_predictor = std::move(some_shape_predictor);
}

void Recognition_image_handler::receive_face_recognition_dnn(face_recognition_dnn_type& some_face_recognition_dnn)
{
    face_recognition_dnn = std::move(some_face_recognition_dnn);
    set_is_recognize_enable(true);
}

void Recognition_image_handler::curr_image_changed(const QString& curr_img_path)
{
    ++worker_thread_id;
    modified_img_index = 0;
    if(!imgs.empty()) {
        set_is_busy_indicator_running(false);
        set_is_hog_enable(true);
        set_is_cnn_enable(true);
    }

    dlib::matrix<dlib::rgb_pixel> img;
    dlib::load_image(img, curr_img_path.toStdString());

    imgs.clear();
    imgs.push_back(std::move(img));

    send_image_data_ready_signal();
}

void Recognition_image_handler::hog()
{
    set_is_busy_indicator_running(true);
    Image_handler_worker* worker = new Image_handler_worker;

    connect(this, &Recognition_image_handler::start_hog, worker, &Image_handler_worker::hog);
    connect(worker, &Image_handler_worker::faces_ready, this, &Recognition_image_handler::faces_ready_slot);

    emit start_hog(++worker_thread_id, imgs.back(), hog_face_detector);
}

void Recognition_image_handler::cnn()
{
    set_is_busy_indicator_running(true);
    Image_handler_worker* worker = new Image_handler_worker;

    connect(this, &Recognition_image_handler::start_cnn, worker, &Image_handler_worker::cnn);
    connect(worker, &Image_handler_worker::faces_ready, this, &Recognition_image_handler::faces_ready_slot);

    emit start_cnn(++worker_thread_id, imgs.back(), cnn_face_detector);
}

void Recognition_image_handler::hog_and_cnn()
{
    set_is_busy_indicator_running(true);
    Image_handler_worker* worker = new Image_handler_worker;

    connect(this, &Recognition_image_handler::start_hog_and_cnn, worker, &Image_handler_worker::hog_and_cnn);
    connect(worker, &Image_handler_worker::faces_ready, this, &Recognition_image_handler::faces_ready_slot);

    emit start_hog_and_cnn(++worker_thread_id, imgs.back(), hog_face_detector, cnn_face_detector);
}

void Recognition_image_handler::pyr_up()
{
    set_is_busy_indicator_running(true);
    Image_handler_worker* worker = new Image_handler_worker;

    connect(this, &Recognition_image_handler::start_pyr_up, worker, &Image_handler_worker::pyr_up);
    connect(worker, &Image_handler_worker::img_ready, this, &Recognition_image_handler::img_ready_slot);

    emit start_pyr_up(++worker_thread_id, imgs.back());
}

void Recognition_image_handler::pyr_down()
{
    set_is_busy_indicator_running(true);
    Image_handler_worker* worker = new Image_handler_worker;

    connect(this, &Recognition_image_handler::start_pyr_down, worker, &Image_handler_worker::pyr_down);
    connect(worker, &Image_handler_worker::img_ready, this, &Recognition_image_handler::img_ready_slot);

    emit start_pyr_down(++worker_thread_id, imgs.back());
}

void Recognition_image_handler::resize(const int some_width, const int some_height)
{
    set_is_busy_indicator_running(true);
    Image_handler_worker* worker = new Image_handler_worker;

    connect(this, &Recognition_image_handler::start_resize, worker, &Image_handler_worker::resize);
    connect(worker, &Image_handler_worker::img_ready, this, &Recognition_image_handler::img_ready_slot);

    emit start_resize(++worker_thread_id, imgs.back(), some_width, some_height);
}

void Recognition_image_handler::faces_ready_slot(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, std::vector<dlib::rectangle>& some_rects_around_faces)
{
    if(worker_thread_id == some_worker_thread_id) {
        if(some_rects_around_faces.empty()) {
            qDebug() << "We did not find any faces.";
            set_is_busy_indicator_running(false);
            return;
        }
        qDebug() << "Update image.";
        imgs.push_back(std::move(some_img));
        find_faces_img_index = imgs.size() - 1;
        rects_around_faces = std::move(some_rects_around_faces);
        send_image_data_ready_signal();
        set_is_hog_enable(false);
        set_is_cnn_enable(false);
        set_is_busy_indicator_running(false);
    }
    else {
        qDebug() << "Ignore image.";
    }
}

void Recognition_image_handler::img_ready_slot(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img)
{
    if(worker_thread_id == some_worker_thread_id) {
        qDebug() << "Update image.";
        imgs.push_back(std::move(some_img));

        if(0 == modified_img_index) {
            modified_img_index = imgs.size() - 1;
        }

        send_image_data_ready_signal();
        set_is_busy_indicator_running(false);
    }
    else {
        qDebug() << "Ignore image.";
    }
}

void Recognition_image_handler::cancel_processing()
{
    ++worker_thread_id;
    set_is_busy_indicator_running(false);
}

void Recognition_image_handler::cancel_last_action()
{
    if(imgs.size() != 1) {
        const auto curr_index = imgs.size() - 1;

        if(curr_index == find_faces_img_index) {
            find_faces_img_index = 0;
            set_is_hog_enable(true);
            set_is_cnn_enable(true);
        }

        if(curr_index == modified_img_index) {
            modified_img_index = 0;
        }

        imgs.pop_back();
        send_image_data_ready_signal();
    }
}
