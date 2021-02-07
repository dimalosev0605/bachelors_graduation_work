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

bool Recognition_image_handler::get_is_auto_recognize() const
{
    return is_auto_recognize;
}

void Recognition_image_handler::set_is_auto_recognize(const bool some_value)
{
    is_auto_recognize = some_value;

    modified_img_index = 0;
    if(!imgs.empty()) {
        set_is_busy_indicator_running(false);
        set_is_hog_enable(true);
        set_is_cnn_enable(true);
        if(is_auto_recognize) {
            set_is_recognize_enable(true);
        }
        else {
            set_is_recognize_enable(false);
        }

        dlib::matrix<dlib::rgb_pixel> img = imgs.front();

        imgs.clear();
        imgs.push_back(std::move(img));

        send_image_data_ready_signal();
    }

    emit is_auto_recognize_changed();
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
        if(is_auto_recognize) {
            set_is_recognize_enable(true);
        }
        else {
            set_is_recognize_enable(false);
        }
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

    connect(this, &Recognition_image_handler::start_hog, worker, &Image_handler_worker::hog_2);
    connect(worker, &Image_handler_worker::faces_ready_2, this, &Recognition_image_handler::faces_ready_slot);

    emit start_hog(++worker_thread_id, imgs.back(), hog_face_detector, shape_predictor, face_recognition_dnn, face_chip_size, face_chip_padding);
}

void Recognition_image_handler::cnn()
{
    set_is_busy_indicator_running(true);
    Image_handler_worker* worker = new Image_handler_worker;

    connect(this, &Recognition_image_handler::start_cnn, worker, &Image_handler_worker::cnn_2);
    connect(worker, &Image_handler_worker::faces_ready_2, this, &Recognition_image_handler::faces_ready_slot);

    emit start_cnn(++worker_thread_id, imgs.back(), cnn_face_detector, shape_predictor, face_recognition_dnn, face_chip_size, face_chip_padding);
}

void Recognition_image_handler::hog_and_cnn()
{
    set_is_busy_indicator_running(true);
    Image_handler_worker* worker = new Image_handler_worker;

    connect(this, &Recognition_image_handler::start_hog_and_cnn, worker, &Image_handler_worker::hog_and_cnn_2);
    connect(worker, &Image_handler_worker::faces_ready_2, this, &Recognition_image_handler::faces_ready_slot);

    emit start_hog_and_cnn(++worker_thread_id, imgs.back(), hog_face_detector, cnn_face_detector, shape_predictor, face_recognition_dnn, face_chip_size, face_chip_padding);
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

void Recognition_image_handler::faces_ready_slot(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, std::vector<dlib::matrix<float, 0, 1>>& some_face_descriptors, std::vector<dlib::rectangle>& some_rects_around_faces)
{
    if(worker_thread_id == some_worker_thread_id) {
        if(some_face_descriptors.empty()) {
            qDebug() << "We did not find any faces.";
            set_is_busy_indicator_running(false);
            return;
        }
        qDebug() << "Update image.";
        imgs.push_back(std::move(some_img));
        find_faces_img_index = imgs.size() - 1;
        face_descriptors = std::move(some_face_descriptors);
        rects_around_faces = std::move(some_rects_around_faces);
        send_image_data_ready_signal();
        set_is_hog_enable(false);
        set_is_cnn_enable(false);
        set_is_recognize_enable(true);
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

void Recognition_image_handler::auto_recognize_ready_slot(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img)
{
    if(worker_thread_id == some_worker_thread_id) {
        qDebug() << "Update image.";
        imgs.push_back(std::move(some_img));
        set_is_recognize_enable(false);
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

        if(curr_index == recognized_img_index) {
            recognized_img_index = 0;
            set_is_recognize_enable(true);
        }

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

void Recognition_image_handler::accept_selected_people(const QVector<QString>& some_selected_people)
{
    Image_handler_worker* worker = new Image_handler_worker;

    auto local_selected_people = some_selected_people;

    connect(this, &Recognition_image_handler::start_selected_people_initializing, worker, &Image_handler_worker::selected_people_initializing);
    connect(worker, &Image_handler_worker::selected_people_initialized, this, &Recognition_image_handler::selected_people_initialized_slot);

    emit start_selected_people_initializing(local_selected_people );
}

void Recognition_image_handler::selected_people_initialized_slot(std::map<dlib::matrix<float, 0, 1>, std::string>& some_people)
{
    known_people = some_people;
    qDebug() << "known_people.size() = " << known_people.size();
}

void Recognition_image_handler::set_threshold(const double some_threshold)
{
    threshold = some_threshold;
}

void Recognition_image_handler::recognize()
{
    dlib::matrix<dlib::rgb_pixel> dlib_img = imgs[find_faces_img_index];
    cv::Mat img = dlib::toMat(dlib_img);

    std::vector<bool> is_known(face_descriptors.size(), false);

    for(std::size_t i = 0; i < face_descriptors.size(); ++i) {

        float min_diff = 1000.0f;
        std::string min_diff_name;

        for(const auto& entry : known_people) {
            const auto diff = dlib::length(face_descriptors[i] - entry.first);
            if(diff < threshold) {
                if(diff < min_diff) {
                    min_diff = diff;
                    min_diff_name = entry.second;
                }
                is_known[i] = true;
            }
        }

        if(is_known[i]) {
            cv::rectangle(img, cv::Point(rects_around_faces[i].tl_corner().x(), rects_around_faces[i].tl_corner().y()),
                               cv::Point(rects_around_faces[i].br_corner().x(), rects_around_faces[i].br_corner().y()),
                               cv::Scalar(0, 255, 0), 2);
            cv::putText(img, min_diff_name, cv::Point(rects_around_faces[i].tl_corner().x(), rects_around_faces[i].tl_corner().y()), cv::FONT_HERSHEY_DUPLEX, 0.70, cv::Scalar(0, 255, 0), 2);
        }
    }

    for(std::size_t i = 0; i < is_known.size(); ++i) {
        if(!is_known[i]) {
            cv::putText(img, "unknown", cv::Point(rects_around_faces[i].tl_corner().x(), rects_around_faces[i].tl_corner().y()), cv::FONT_HERSHEY_DUPLEX, 0.70, cv::Scalar(255, 0, 0), 2);
        }
    }

    dlib::cv_image<dlib::rgb_pixel> res_dlib_img = img;
    dlib::matrix<dlib::rgb_pixel> res_img;
    dlib::assign_image(res_img, res_dlib_img);
    imgs.push_back(std::move(res_img));

    recognized_img_index = imgs.size() - 1;

    send_image_data_ready_signal();
}

void Recognition_image_handler::auto_recognize()
{
    set_is_busy_indicator_running(true);
    Image_handler_worker* worker = new Image_handler_worker;

    connect(this, &Recognition_image_handler::start_auto_recognize, worker, &Image_handler_worker::auto_recognize);
    connect(worker, &Image_handler_worker::auto_recognize_ready, this, &Recognition_image_handler::auto_recognize_ready_slot);

    emit start_auto_recognize(++worker_thread_id, imgs.back(), hog_face_detector, shape_predictor, face_recognition_dnn, face_chip_size, face_chip_padding, known_people, threshold);
}
