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

    connect(this, &Image_handler::faces_ready, this, &Image_handler::faces_ready_slot);
    connect(this, &Image_handler::img_ready, this, &Image_handler::img_ready_slot);
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

void Image_handler::receive_hog_face_detector(const hog_face_detector_type& some_hog_face_detector)
{
    hog_face_detector = some_hog_face_detector;
    set_is_hog_enable(true);
}

void Image_handler::receive_cnn_face_detector(const cnn_face_detector_type& some_cnn_face_detector)
{
    cnn_face_detector = some_cnn_face_detector;
    set_is_cnn_enable(true);
}

void Image_handler::receive_shape_predictor(const dlib::shape_predictor& some_shape_predictor)
{
    shape_predictor = some_shape_predictor;
}

void Image_handler::start_thread(QThread* some_thread)
{
    set_is_busy_indicator_running(true);
    connect(some_thread, &QThread::finished, some_thread, &QObject::deleteLater);
    some_thread->start();
}

void Image_handler::hog()
{
    const auto worker_thread = QThread::create(std::bind(&Image_handler::hog_thread_function, this, ++worker_thread_id, imgs.back(), hog_face_detector));
    start_thread(worker_thread);
}

void Image_handler::cnn()
{
    const auto worker_thread = QThread::create(std::bind(&Image_handler::cnn_thread_function, this, ++worker_thread_id, imgs.back(), cnn_face_detector));
    start_thread(worker_thread);
}

void Image_handler::hog_and_cnn()
{
    const auto worker_thread = QThread::create(std::bind(&Image_handler::hog_and_cnn_thread_function, this, ++worker_thread_id, imgs.back(), hog_face_detector, cnn_face_detector));
    start_thread(worker_thread);
}

void Image_handler::pyr_up()
{
    const auto worker_thread = QThread::create(std::bind(&Image_handler::pyr_up_thread_function, this, ++worker_thread_id, imgs.back()));
    start_thread(worker_thread);
}

void Image_handler::pyr_down()
{
    const auto worker_thread = QThread::create(std::bind(&Image_handler::pyr_down_thread_function, this, ++worker_thread_id, imgs.back()));
    start_thread(worker_thread);
}

void Image_handler::resize(const int some_width, const int some_height)
{
    const auto worker_thread = QThread::create(std::bind(&Image_handler::resize_thread_function, this, ++worker_thread_id, imgs.back(), some_width, some_height));
    start_thread(worker_thread);
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

void Image_handler::hog_thread_function(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, hog_face_detector_type& some_hog_face_detector)
{
    auto local_img = std::move(some_img);
    auto local_hog_face_detector = std::move(some_hog_face_detector);

    const auto local_rects_around_faces = local_hog_face_detector.operator()(local_img);

    for(const auto& rect : local_rects_around_faces) {
        dlib::draw_rectangle(local_img, rect, dlib::rgb_pixel{255, 0, 0}, 2);
    }

    emit faces_ready(some_worker_thread_id, local_img, local_rects_around_faces);
    QThread::currentThread()->exit(0);
}

void Image_handler::cnn_thread_function(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, cnn_face_detector_type& some_cnn_face_detector)
{
    auto local_img = std::move(some_img);
    auto local_cnn_face_detector = std::move(some_cnn_face_detector);

    const auto local_mmod_rects_around_faces = local_cnn_face_detector(local_img);

    std::vector<dlib::rectangle> local_rects_around_faces;
    local_rects_around_faces.reserve(local_mmod_rects_around_faces.size());

    for(const auto& mmod_rect : local_mmod_rects_around_faces) {
        local_rects_around_faces.push_back(mmod_rect.rect);
    }

    for(const auto& rect : local_rects_around_faces) {
        dlib::draw_rectangle(local_img, rect, dlib::rgb_pixel{255, 0, 0}, 2);
    }

    emit faces_ready(some_worker_thread_id, local_img, local_rects_around_faces);
    QThread::currentThread()->exit(0);
}

void Image_handler::hog_and_cnn_thread_function(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, hog_face_detector_type& some_hog_face_detector, cnn_face_detector_type& some_cnn_face_detector)
{
    auto local_img = std::move(some_img);
    auto local_hog_face_detector = std::move(some_hog_face_detector);
    auto local_cnn_face_detector = std::move(some_cnn_face_detector);

    auto hog_rects_around_faces = local_hog_face_detector(local_img);

    auto cnn_mmod_rects_around_faces = local_cnn_face_detector(local_img);
    std::vector<dlib::rectangle> cnn_rects_around_faces;
    cnn_rects_around_faces.reserve(cnn_mmod_rects_around_faces.size());
    for(const auto& mmod_rect : cnn_mmod_rects_around_faces) {
        cnn_rects_around_faces.push_back(mmod_rect.rect);
    }

    std::vector<dlib::point> hog_points;
    hog_points.reserve(hog_rects_around_faces.size());
    for(std::size_t i = 0; i < hog_rects_around_faces.size(); ++i) {
        hog_points.push_back(dlib::center(hog_rects_around_faces[i]));
    }

    std::vector<dlib::rectangle> result_rects_around_faces;
    for(std::size_t i = 0; i < hog_rects_around_faces.size(); ++i) {
        for(std::size_t j = 0; j < cnn_rects_around_faces.size(); ++j) {
            if(cnn_rects_around_faces[j].contains(hog_points[i])) {
                result_rects_around_faces.push_back(hog_rects_around_faces[i]);
                hog_rects_around_faces[i] = dlib::rectangle{};
                cnn_rects_around_faces[j] = dlib::rectangle{};
                break;
            }
        }
    }

    for(std::size_t i = 0; i < hog_rects_around_faces.size(); ++i) {
        if(!hog_rects_around_faces[i].is_empty()) {
            result_rects_around_faces.push_back(hog_rects_around_faces[i]);
        }
    }

    for(std::size_t i = 0; i < cnn_rects_around_faces.size(); ++i) {
        if(!cnn_rects_around_faces[i].is_empty()) {
            result_rects_around_faces.push_back(cnn_rects_around_faces[i]);
        }
    }

    for(const auto& rect : result_rects_around_faces) {
        dlib::draw_rectangle(local_img, rect, dlib::rgb_pixel{255, 0, 0}, 2);
    }

    emit faces_ready(some_worker_thread_id, local_img, result_rects_around_faces);
    QThread::currentThread()->exit(0);
}

void Image_handler::pyr_up_thread_function(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img)
{
    auto local_img = std::move(some_img);
    dlib::pyramid_up(local_img);
    emit img_ready(some_worker_thread_id, local_img);
    QThread::currentThread()->exit(0);
}

void Image_handler::pyr_down_thread_function(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img)
{
    auto local_img = std::move(some_img);
    dlib::pyramid_down<2> pyr;
    pyr(local_img);
    emit img_ready(some_worker_thread_id, local_img);
    QThread::currentThread()->exit(0);
}

void Image_handler::resize_thread_function(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, const int some_width, const int some_height)
{
    auto local_img = std::move(some_img);

    dlib::matrix<dlib::rgb_pixel> resized_img(some_height, some_width);
    dlib::resize_image(local_img, resized_img);

    emit img_ready(some_worker_thread_id, resized_img);
    QThread::currentThread()->exit(0);
}

void Image_handler::faces_ready_slot(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img, const std::vector<dlib::rectangle>& some_rects_around_faces)
{
    if(worker_thread_id == some_worker_thread_id) {
        if(some_rects_around_faces.empty()) {
            qDebug() << "We did not find any faces.";
            set_is_busy_indicator_running(false);
            return;
        }
        qDebug() << "Update image.";
        imgs.push_back(some_img);
        find_faces_img_index = imgs.size() - 1;
        rects_around_faces = some_rects_around_faces;
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

void Image_handler::img_ready_slot(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img)
{
    if(worker_thread_id == some_worker_thread_id) {
        qDebug() << "Update image.";
        imgs.push_back(some_img);

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
