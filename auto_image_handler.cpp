#include "auto_image_handler.h"

Auto_image_handler::Auto_image_handler(QObject *parent) : QObject(parent)
{
    Image_handler_initializer* image_handler_initializer = new Image_handler_initializer;
    connect(image_handler_initializer, &Image_handler_initializer::hog_face_detector_ready, this, &Auto_image_handler::receive_hog_face_detector);
    connect(image_handler_initializer, &Image_handler_initializer::cnn_face_detector_ready, this, &Auto_image_handler::receive_cnn_face_detector);
    connect(image_handler_initializer, &Image_handler_initializer::shape_predictor_ready, this, &Auto_image_handler::receive_shape_predictor);
    connect(image_handler_initializer, &Image_handler_initializer::face_recognition_dnn_ready, this, &Auto_image_handler::receive_face_recognition_dnn);
    connect(image_handler_initializer, &Image_handler_initializer::finished, image_handler_initializer, &Image_handler_initializer::deleteLater);
    image_handler_initializer->start();
}

void Auto_image_handler::curr_image_changed(const QString& curr_img_path)
{
    if(!imgs.empty()) {
        set_is_busy_indicator_running(false);
        set_is_choose_face_enable(false);
        set_is_cancel_visible(false);
        set_is_handle_remaining_imgs_visible(false);
        set_is_ok_enable(true);
    }

    dlib::matrix<dlib::rgb_pixel> img;
    dlib::load_image(img, curr_img_path.toStdString());

    imgs.clear();
    imgs.push_back(std::move(img));
}

void Auto_image_handler::receive_hog_face_detector(hog_face_detector_type& some_hog_face_detector)
{
    hog_face_detector = std::move(some_hog_face_detector);
}

void Auto_image_handler::receive_cnn_face_detector(cnn_face_detector_type& some_cnn_face_detector)
{
    cnn_face_detector = std::move(some_cnn_face_detector);
}

void Auto_image_handler::receive_face_recognition_dnn(face_recognition_dnn_type& some_face_recognition_dnn)
{
    face_recognition_dnn = std::move(some_face_recognition_dnn);
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

bool Auto_image_handler::get_is_choose_face_enable() const
{
    return is_choose_face_enable;
}

void Auto_image_handler::set_is_choose_face_enable(const bool some_value)
{
    is_choose_face_enable = some_value;
    emit is_choose_face_enable_changed();
}

bool Auto_image_handler::get_is_cancel_visible() const
{
    return is_cancel_visible;
}

void Auto_image_handler::set_is_cancel_visible(const bool some_value)
{
    is_cancel_visible = some_value;
    emit is_cancel_visible_changed();
}

bool Auto_image_handler::get_is_handle_remaining_imgs_visible() const
{
    return is_handle_remaining_imgs_visible;
}

void Auto_image_handler::set_is_handle_remaining_imgs_visible(const bool some_value)
{
    is_handle_remaining_imgs_visible = some_value;
    emit is_handle_remaining_imgs_visible_changed();
}

void Auto_image_handler::search_target_face()
{
    set_is_busy_indicator_running(true);

    Image_handler_worker* worker = new Image_handler_worker;

    connect(this, &Auto_image_handler::start_search_target_face, worker, &Image_handler_worker::search_target_face);
    connect(worker, &Image_handler_worker::message, this, &Auto_image_handler::receive_message);
    connect(worker, &Image_handler_worker::target_faces_ready, this, &Auto_image_handler::target_face_ready);

    emit start_search_target_face(++worker_thread_id, imgs.back(), hog_face_detector, shape_predictor, face_chip_size, face_chip_padding);
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

void Auto_image_handler::send_image_data_ready_signal()
{
    const auto data = dlib::image_data(imgs.back());
    Image_data image_data(data, imgs.back().nc(), imgs.back().nr());
    emit image_data_ready(image_data);
}

void Auto_image_handler::receive_message(const QString& some_message, const int some_worker_thread_id)
{
    if(worker_thread_id == some_worker_thread_id) {
        set_is_busy_indicator_running(false);
        emit message(some_message);
    }
    else {
        qDebug() << "Ignore message.";
    }
}

void Auto_image_handler::cancel_processing()
{
    ++worker_thread_id;
    set_is_busy_indicator_running(false);
}

void Auto_image_handler::cancel_last_action()
{
    if(imgs.size() != 1) {
        imgs.pop_back();
        set_is_choose_face_enable(true);
        set_is_cancel_visible(false);
        set_is_handle_remaining_imgs_visible(false);
        send_image_data_ready_signal();
    }
}

void Auto_image_handler::target_face_ready(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, const int number_of_faces)
{
    if(worker_thread_id == some_worker_thread_id) {
        qDebug() << "Update target face image.";
        imgs.push_back(some_img);
        send_image_data_ready_signal();
        if(number_of_faces > 1) {
            set_is_choose_face_enable(true);
        }
        else {
            set_is_handle_remaining_imgs_visible(true);
        }
        set_is_ok_enable(false);
        set_is_busy_indicator_running(false);
    }
    else {
        qDebug() << "Ignore target face image.";
    }
}

void Auto_image_handler::choose_face(const double x, [[maybe_unused]]const double y)
{
    set_is_busy_indicator_running(true);

    const int face_size = static_cast<int>(face_chip_size);
    const int face_number = static_cast<int>(x) / face_size;

    const auto cv_img = dlib::toMat(imgs.back());

    cv::Mat selected_face_cv_img = cv_img(cv::Rect(face_number * face_size, 0, face_size, face_size));

    dlib::cv_image<dlib::rgb_pixel> selected_face_dlib_cv_img = selected_face_cv_img;
    dlib::matrix<dlib::rgb_pixel> img;
    dlib::assign_image(img, selected_face_dlib_cv_img);
    imgs.push_back(std::move(img));

    send_image_data_ready_signal();

    set_is_cancel_visible(true);
    set_is_choose_face_enable(false);
    set_is_handle_remaining_imgs_visible(true);
    set_is_busy_indicator_running(false);
}

void Auto_image_handler::handle_remaining_images(const QVector<QString>& some_selected_imgs_paths)
{
    set_is_busy_indicator_running(true);

    Image_handler_worker* worker = new Image_handler_worker;

    connect(this, &Auto_image_handler::start_handle_remaining_images, worker, &Image_handler_worker::handle_remaining_images);
    connect(worker, &Image_handler_worker::remaining_images_ready, this, &Auto_image_handler::remaining_images_ready);
    connect(worker, &Image_handler_worker::message, this, &Auto_image_handler::receive_progress_message);
    emit start_handle_remaining_images(++worker_thread_id, hog_face_detector, shape_predictor, face_recognition_dnn, imgs.back(), some_selected_imgs_paths, face_chip_size, face_chip_padding);
}

void Auto_image_handler::remaining_images_ready(const int some_worker_thread_id, std::vector<std::tuple<dlib::matrix<dlib::rgb_pixel>, dlib::matrix<dlib::rgb_pixel>>>& some_imgs)
{
    if(worker_thread_id == some_worker_thread_id) {
        for(std::size_t i = 0; i < some_imgs.size(); ++i) {
            emit image_ready(Image_data(dlib::image_data(std::get<0>(some_imgs[i])), std::get<0>(some_imgs[i]).nc(), std::get<0>(some_imgs[i]).nr()),
                             Image_data(dlib::image_data(std::get<1>(some_imgs[i])), std::get<1>(some_imgs[i]).nc(), std::get<1>(some_imgs[i]).nr()));
        }
        if(!some_imgs.empty()) {
            emit all_remaining_images_received();
        }
        set_is_busy_indicator_running(false);
    }
    else {
        qDebug() << "Ignore target face image.";
    }
}

void Auto_image_handler::receive_progress_message(const QString& some_message, const int some_worker_thread_id)
{
    if(worker_thread_id == some_worker_thread_id) {
        qDebug() << "progress: " << some_message;
    }
    else {
        qDebug() << "Ignore progress.";
    }
}
