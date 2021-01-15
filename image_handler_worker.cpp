#include "image_handler_worker.h"

Image_handler_worker::Image_handler_worker(QObject* parent)
    : QObject(parent),
      thread(new QThread)
{
    this->moveToThread(thread);
    connect(thread, &QThread::finished, this, &QObject::deleteLater);
    thread->start();
}

Image_handler_worker::~Image_handler_worker()
{
    thread->deleteLater();
}

void Image_handler_worker::hog(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, hog_face_detector_type& some_hog_face_detector)
{
    auto local_img = std::move(some_img);
    auto local_hog_face_detector = std::move(some_hog_face_detector);

    auto local_rects_around_faces = local_hog_face_detector.operator()(local_img);

    for(const auto& rect : local_rects_around_faces) {
        dlib::draw_rectangle(local_img, rect, dlib::rgb_pixel{255, 0, 0}, 2);
    }

    emit faces_ready(some_worker_thread_id, local_img, local_rects_around_faces);
    QThread::currentThread()->exit();
}

void Image_handler_worker::cnn(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, cnn_face_detector_type& some_cnn_face_detector)
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
    QThread::currentThread()->exit();
}

void Image_handler_worker::hog_and_cnn(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, hog_face_detector_type& some_hog_face_detector, cnn_face_detector_type& some_cnn_face_detector)
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
    QThread::currentThread()->exit();
}

void Image_handler_worker::pyr_up(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img)
{
    auto local_img = std::move(some_img);
    dlib::pyramid_up(local_img);
    emit img_ready(some_worker_thread_id, local_img);
    QThread::currentThread()->exit();
}

void Image_handler_worker::pyr_down(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img)
{
    auto local_img = std::move(some_img);
    dlib::pyramid_down<2> pyr;
    pyr(local_img);
    emit img_ready(some_worker_thread_id, local_img);
    QThread::currentThread()->exit();
}

void Image_handler_worker::resize(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img, const int some_width, const int some_height)
{
    auto local_img = std::move(some_img);

    dlib::matrix<dlib::rgb_pixel> resized_img(some_height, some_width);
    dlib::resize_image(local_img, resized_img);

    emit img_ready(some_worker_thread_id, resized_img);
    QThread::currentThread()->exit();
}

void Image_handler_worker::search_target_face(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, hog_face_detector_type& some_hog_face_detector, const dlib::shape_predictor& some_shape_predictor, const unsigned long face_chip_size, const double face_chip_padding)
{
    auto local_img = std::move(some_img);
    auto local_hog_face_detector = std::move(some_hog_face_detector);
    auto local_shape_predictor = std::move(some_shape_predictor);

    dlib::pyramid_up(local_img);

    const auto rects_around_faces = local_hog_face_detector.operator()(local_img);

    if(rects_around_faces.empty()) {
        emit message("We did not find any faces on the image.", some_worker_thread_id);
        QThread::currentThread()->exit();
        return;
    }

    std::vector<dlib::full_object_detection> face_shapes;
    face_shapes.reserve(rects_around_faces.size());

    for(std::size_t i = 0; i < rects_around_faces.size(); ++i) {
        const auto face_shape = local_shape_predictor.operator()(local_img, rects_around_faces[i]);
        face_shapes.push_back(face_shape);
    }

    std::vector<dlib::matrix<dlib::rgb_pixel>> processed_faces;
    processed_faces.reserve(rects_around_faces.size());

    for(const auto& face_shape : face_shapes) {
        dlib::matrix<dlib::rgb_pixel> processed_face;
        dlib::extract_image_chip(local_img, dlib::get_face_chip_details(face_shape, face_chip_size, face_chip_padding), processed_face);
        processed_faces.push_back(std::move(processed_face));
    }

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

    emit target_faces_ready(some_worker_thread_id, img, static_cast<int>(processed_faces.size()));
    QThread::currentThread()->exit();
}
