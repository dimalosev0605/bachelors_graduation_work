#include "image_handler.h"

Image_handler::Image_handler(QObject* parent)
    : QObject(parent)
{
    Image_handler_initializer* image_handler_initializer = new Image_handler_initializer;
    connect(image_handler_initializer, &Image_handler_initializer::hog_face_detector_ready, this, &Image_handler::receive_hog_face_detector);
    connect(image_handler_initializer, &Image_handler_initializer::cnn_face_detector_ready, this, &Image_handler::receive_cnn_face_detector);
    connect(image_handler_initializer, &Image_handler_initializer::shape_predictor_ready, this, &Image_handler::receive_shape_predictor);
    connect(image_handler_initializer, &Image_handler_initializer::finished, image_handler_initializer, &Image_handler_initializer::deleteLater);
    image_handler_initializer->start();
}

bool Image_handler::get_is_busy_indicator_running() const
{
    return is_busy_indicator_running;
}

void Image_handler::set_is_busy_indicator_running(const bool some_value)
{
    is_busy_indicator_running = some_value;
    emit is_busy_indicator_running_changed();
}

bool Image_handler::get_is_hog_enable() const
{
    return is_hog_enable;
}

void Image_handler::set_is_hog_enable(const bool some_value)
{
    is_hog_enable = some_value;
    emit is_hog_enable_changed();
}

bool Image_handler::get_is_cnn_enable() const
{
    return is_cnn_enable;
}

void Image_handler::set_is_cnn_enable(const bool some_value)
{
    is_cnn_enable = some_value;
    emit is_cnn_enable_changed();
}

bool Image_handler::get_is_extract_faces_enable() const
{
    return is_extract_faces_enable;
}

void Image_handler::set_is_extract_faces_enable(const bool some_value)
{
    is_extract_faces_enable = some_value;
    emit is_extract_faces_enable_changed();
}

bool Image_handler::get_is_choose_face_enable() const
{
    return is_choose_face_enable;
}

void Image_handler::set_is_choose_face_enable(const bool some_value)
{
    is_choose_face_enable = some_value;
    emit is_choose_face_enable_changed();
}

bool Image_handler::get_is_add_face_enable() const
{
    return is_add_face_enable;
}

void Image_handler::set_is_add_face_enable(const bool some_value)
{
    is_add_face_enable = some_value;
    emit is_add_face_enable_changed();
}

bool Image_handler::get_is_cancel_enabled() const
{
    return is_cancel_enabled;
}

void Image_handler::set_is_cancel_enabled(const bool some_value)
{
    is_cancel_enabled = some_value;
    emit is_cancel_enabled_changed();
}

void Image_handler::curr_image_changed(const QString& curr_img_path)
{
    ++worker_thread_id;
    modified_img_index = 0;
    if(!imgs.empty()) {
        set_is_busy_indicator_running(false);
        set_is_hog_enable(true);
        set_is_cnn_enable(true);
        set_is_extract_faces_enable(false);
        set_is_choose_face_enable(false);
        set_is_add_face_enable(false);
    }

    dlib::matrix<dlib::rgb_pixel> img;
    dlib::load_image(img, curr_img_path.toStdString());

    imgs.clear();
    imgs.push_back(std::move(img));

    send_image_data_ready_signal();
}

void Image_handler::receive_hog_face_detector(hog_face_detector_type& some_hog_face_detector)
{
    hog_face_detector = std::move(some_hog_face_detector);
    set_is_hog_enable(true);
}

void Image_handler::receive_cnn_face_detector(cnn_face_detector_type& some_cnn_face_detector)
{
    cnn_face_detector = std::move(some_cnn_face_detector);
    set_is_cnn_enable(true);
}

void Image_handler::receive_shape_predictor(dlib::shape_predictor& some_shape_predictor)
{
    shape_predictor = std::move(some_shape_predictor);
}

void Image_handler::hog()
{
    set_is_busy_indicator_running(true);
    Image_handler_worker* worker = new Image_handler_worker;

    connect(this, &Image_handler::start_hog, worker, &Image_handler_worker::hog);
    connect(worker, &Image_handler_worker::faces_ready, this, &Image_handler::faces_ready_slot);

    emit start_hog(++worker_thread_id, imgs.back(), hog_face_detector);
}

void Image_handler::cnn()
{
    set_is_busy_indicator_running(true);
    Image_handler_worker* worker = new Image_handler_worker;

    connect(this, &Image_handler::start_cnn, worker, &Image_handler_worker::cnn);
    connect(worker, &Image_handler_worker::faces_ready, this, &Image_handler::faces_ready_slot);

    emit start_cnn(++worker_thread_id, imgs.back(), cnn_face_detector);
}

void Image_handler::hog_and_cnn()
{
    set_is_busy_indicator_running(true);
    Image_handler_worker* worker = new Image_handler_worker;

    connect(this, &Image_handler::start_hog_and_cnn, worker, &Image_handler_worker::hog_and_cnn);
    connect(worker, &Image_handler_worker::faces_ready, this, &Image_handler::faces_ready_slot);

    emit start_hog_and_cnn(++worker_thread_id, imgs.back(), hog_face_detector, cnn_face_detector);
}

void Image_handler::pyr_up()
{
    set_is_busy_indicator_running(true);
    Image_handler_worker* worker = new Image_handler_worker;

    connect(this, &Image_handler::start_pyr_up, worker, &Image_handler_worker::pyr_up);
    connect(worker, &Image_handler_worker::img_ready, this, &Image_handler::img_ready_slot);

    emit start_pyr_up(++worker_thread_id, imgs.back());
}

void Image_handler::pyr_down()
{
    set_is_busy_indicator_running(true);
    Image_handler_worker* worker = new Image_handler_worker;

    connect(this, &Image_handler::start_pyr_down, worker, &Image_handler_worker::pyr_down);
    connect(worker, &Image_handler_worker::img_ready, this, &Image_handler::img_ready_slot);

    emit start_pyr_down(++worker_thread_id, imgs.back());
}

void Image_handler::resize(const int some_width, const int some_height)
{
    set_is_busy_indicator_running(true);
    Image_handler_worker* worker = new Image_handler_worker;

    connect(this, &Image_handler::start_resize, worker, &Image_handler_worker::resize);
    connect(worker, &Image_handler_worker::img_ready, this, &Image_handler::img_ready_slot);

    emit start_resize(++worker_thread_id, imgs.back(), some_width, some_height);
}

void Image_handler::extract_face()
{
    if(rects_around_faces.empty()) return;

    set_is_busy_indicator_running(true);

    if(rects_around_faces.size() > 1) {
        set_is_choose_face_enable(true);
    }

    std::vector<dlib::full_object_detection> face_shapes;
    face_shapes.reserve(rects_around_faces.size());

    for(const auto& rect : rects_around_faces) {
        const auto face_shape = shape_predictor.operator()(imgs.back(), rect);
        face_shapes.push_back(face_shape);
    }

    std::vector<dlib::matrix<dlib::rgb_pixel>> processed_faces;
    processed_faces.reserve(rects_around_faces.size());

    for(const auto& face_shape : face_shapes) {
        dlib::matrix<dlib::rgb_pixel> processed_face;
        dlib::extract_image_chip(imgs[imgs.size() - 2], dlib::get_face_chip_details(face_shape, face_chip_size, face_chip_padding), processed_face);
        processed_faces.push_back(std::move(processed_face));
    }

    if(!processed_faces.empty()) {
        const auto processed_face_w = static_cast<int>(processed_faces[0].nc());
        const auto processed_face_h = static_cast<int>(processed_faces[0].nr());

        const auto res_cols = processed_face_w * static_cast<int>(processed_faces.size());

        cv::Mat res_cv_img(processed_face_h, res_cols, CV_8UC3);
        int curr_col = 0;
        for(std::size_t i = 0; i < processed_faces.size(); ++i) {
            const auto cv_img = dlib::toMat(processed_faces[i]);
            cv_img.copyTo(res_cv_img(cv::Rect(curr_col, 0, cv_img.cols, cv_img.rows)));
            curr_col += processed_face_w;
        }

        dlib::cv_image<dlib::rgb_pixel> res_dlib_img = res_cv_img;
        dlib::matrix<dlib::rgb_pixel> img;
        dlib::assign_image(img, res_dlib_img);
        imgs.push_back(std::move(img));
        extract_face_img_index = imgs.size() - 1;

        send_image_data_ready_signal();

        set_is_extract_faces_enable(false);
        if(rects_around_faces.size() == 1) {
            set_is_add_face_enable(true);
        }
    }

    set_is_busy_indicator_running(false);
}

void Image_handler::choose_face(const double x, [[maybe_unused]]const double y)
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
    choose_face_img_index = imgs.size() - 1;

    set_is_choose_face_enable(false);
    set_is_add_face_enable(true);

    send_image_data_ready_signal();

    set_is_busy_indicator_running(false);
}

void Image_handler::faces_ready_slot(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, std::vector<dlib::rectangle>& some_rects_around_faces)
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
        set_is_extract_faces_enable(true);
        set_is_busy_indicator_running(false);
    }
    else {
        qDebug() << "Ignore image.";
    }
}

void Image_handler::img_ready_slot(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img)
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

void Image_handler::send_image_data_ready_signal()
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

void Image_handler::cancel_processing()
{
    ++worker_thread_id;
    set_is_busy_indicator_running(false);
}

void Image_handler::cancel_last_action()
{
    if(imgs.size() != 1) {
        const auto curr_index = imgs.size() - 1;

        if(curr_index == choose_face_img_index) {
            choose_face_img_index = 0;
            set_is_choose_face_enable(true);
            set_is_add_face_enable(false);
        }

        if(curr_index == extract_face_img_index) {
            extract_face_img_index = 0;
            set_is_extract_faces_enable(true);
            set_is_choose_face_enable(false);
            set_is_add_face_enable(false);
        }

        if(curr_index == find_faces_img_index) {
            find_faces_img_index = 0;
            set_is_hog_enable(true);
            set_is_cnn_enable(true);
            set_is_extract_faces_enable(false);
        }

        if(curr_index == modified_img_index) {
            modified_img_index = 0;
        }

        imgs.pop_back();
        send_image_data_ready_signal();
    }
}
