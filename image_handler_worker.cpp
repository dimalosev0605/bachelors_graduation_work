#include "image_handler_worker.h"

Image_handler_worker::Image_handler_worker(QObject* parent)
    : QObject(parent),
      thread(new QThread)
{
    QSettings app_settings("app_settings.ini", QSettings::Format::IniFormat);
    face_recognition_threshold = app_settings.value("face_recognition_threshold").toFloat();

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

void Image_handler_worker::search_target_face(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, hog_face_detector_type& some_hog_face_detector, dlib::shape_predictor& some_shape_predictor, const unsigned long face_chip_size, const double face_chip_padding)
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

void Image_handler_worker::handle_remaining_images(const int some_worker_thread_id, hog_face_detector_type& some_hog_face_detector, dlib::shape_predictor& some_shape_predictor, face_recognition_dnn_type& some_face_recognition_dnn, dlib::matrix<dlib::rgb_pixel>& some_target_face_img , const QVector<QString>& some_selected_imgs_paths, const unsigned long face_chip_size, const double face_chip_padding)
{
    auto local_target_face_img = std::move(some_target_face_img);
    auto local_hog_face_detector = std::move(some_hog_face_detector);
    auto local_shape_predictor = std::move(some_shape_predictor);
    auto local_face_recognition_dnn = some_face_recognition_dnn;

    dlib::matrix<float, 0, 1> target_face_descriptor = local_face_recognition_dnn.operator()(local_target_face_img);

    std::vector<dlib::matrix<dlib::rgb_pixel>> selected_imgs;
    selected_imgs.reserve(some_selected_imgs_paths.size());

    for(int i = 0; i < some_selected_imgs_paths.size(); ++i) {
        dlib::matrix<dlib::rgb_pixel> img;
        dlib::load_image(img, some_selected_imgs_paths[i].toStdString());
        selected_imgs.push_back(std::move(img));
    }

    std::vector<std::tuple<dlib::matrix<dlib::rgb_pixel>, dlib::matrix<dlib::rgb_pixel>>> res; // 1 - original image, 2 - extracted face.

    for(std::size_t i = 0; i < selected_imgs.size(); ++i) {
        emit message(QString("Processing image %1 of %2").arg(i + 1).arg(selected_imgs.size()), some_worker_thread_id);

        auto rects_around_faces = local_hog_face_detector.operator()(selected_imgs[i]);
        if(rects_around_faces.empty()) continue;

        std::vector<dlib::matrix<dlib::rgb_pixel>> processed_faces;
        for(const auto& rect : rects_around_faces) {
            const auto face_shape = local_shape_predictor.operator()(selected_imgs[i], rect);
            dlib::matrix<dlib::rgb_pixel> processed_face;
            dlib::extract_image_chip(selected_imgs[i], dlib::get_face_chip_details(face_shape, face_chip_size, face_chip_padding), processed_face);
            processed_faces.push_back(std::move(processed_face));
        }

        std::vector<dlib::matrix<float, 0, 1>> face_descriptors = local_face_recognition_dnn.operator()(processed_faces);

        for(std::size_t j = 0; j < face_descriptors.size(); ++j) {
            if(dlib::length(face_descriptors[j] - target_face_descriptor) < face_recognition_threshold) {
                res.push_back(std::tuple<dlib::matrix<dlib::rgb_pixel>, dlib::matrix<dlib::rgb_pixel>>(selected_imgs[i], processed_faces[j]));
            }
        }
    }

    emit remaining_images_ready(some_worker_thread_id, res);
    QThread::currentThread()->exit();
}

void Image_handler_worker::selected_people_initializing(QVector<QString>& some_selected_people)
{
    const auto local_selected_people = std::move(some_selected_people);

    std::map<dlib::matrix<float, 0, 1>, std::string> known_people;
    std::vector<dlib::matrix<float, 0, 1>> face_descriptors;
    std::vector<std::string> names;

    Dir_paths dir_paths;
    for(int i = 0; i < local_selected_people.size(); ++i) {
        const QString face_descriptos_path = dir_paths.people() + '/' + local_selected_people[i] + '/' + Dir_names::Individual::face_descriptors;
        qDebug() << local_selected_people[i] << "; " << face_descriptos_path;

        dlib::directory face_descriptos_dir(face_descriptos_path.toStdString());
        auto files = face_descriptos_dir.get_files();
        for(const auto& file: files) {
            dlib::matrix<float, 0, 1> face_descriptor;
            dlib::deserialize(file.full_name()) >> face_descriptor;
            face_descriptors.push_back(std::move(face_descriptor));
            names.push_back(local_selected_people[i].toStdString());
            qDebug() << "Loaded: "
                     << QString(file.full_name().c_str())
                     << local_selected_people[i];
        }
    }

    if(face_descriptors.size() != names.size()) {
        qDebug() << "Error.";
        return;
    }

    for(std::size_t i = 0; i < names.size(); ++i) {
        known_people[face_descriptors[i]] = names[i];
    }

    qDebug() << "known_people filling finised.";

    emit selected_people_initialized(known_people);
    QThread::currentThread()->exit();

    /*
    const auto local_selected_people = std::move(some_selected_people);

    face_recognition_dnn_type face_recognition_dnn;
    dlib::deserialize("dlib_face_recognition_resnet_model_v1.dat") >> face_recognition_dnn;

    std::map<dlib::matrix<float, 0, 1>, std::string> known_people;

    std::vector<dlib::matrix<dlib::rgb_pixel>> imgs;
    std::vector<std::string> names;

    Dir_paths dir_paths;
    for(int i = 0; i < local_selected_people.size(); ++i) {
        const QString extracted_faces_path = dir_paths.people() + '/' + local_selected_people[i] + '/' + Dir_names::Individual::extracted_faces;
        qDebug() << local_selected_people[i] << "; " << extracted_faces_path;

        dlib::directory extr_faces_dir(extracted_faces_path.toStdString());

        auto files = extr_faces_dir.get_files();
        for(const auto& file: files) {
            dlib::matrix<dlib::rgb_pixel> img;
            dlib::load_image(img, file.full_name());
            imgs.push_back(std::move(img));
            names.push_back(local_selected_people[i].toStdString());
            qDebug() << "Loaded: "
                     << QString(file.full_name().c_str())
                     << local_selected_people[i];
        }
    }

    if(imgs.size() != names.size()) {
        qDebug() << "Error.";
        return;
    }

    std::vector<dlib::matrix<float, 0, 1>> face_descriptors;
    face_descriptors = face_recognition_dnn(imgs);

    for(std::size_t i = 0; i < names.size(); ++i) {
        known_people[face_descriptors[i]] = names[i];
    }

    qDebug() << "known_people filling finised.";

    emit selected_people_initialized(known_people);
    QThread::currentThread()->exit();
    */
}

void Image_handler_worker::hog_2(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, hog_face_detector_type& some_hog_face_detector, dlib::shape_predictor& some_shape_predictor, face_recognition_dnn_type& some_face_recognition_dnn, const unsigned long face_chip_size, const double face_chip_padding)
{
    auto local_img = std::move(some_img);
    auto local_hog_face_detector = std::move(some_hog_face_detector);
    auto local_shape_predictor = std::move(some_shape_predictor);
    auto local_face_rec_dnn = std::move(some_face_recognition_dnn);

    auto local_rects_around_faces = local_hog_face_detector.operator()(local_img);

    std::vector<dlib::full_object_detection> face_shapes;
    face_shapes.reserve(local_rects_around_faces.size());

    for(const auto& rect : local_rects_around_faces) {
        const auto face_shape = local_shape_predictor.operator()(local_img, rect);
        face_shapes.push_back(face_shape);
    }

    std::vector<dlib::matrix<dlib::rgb_pixel>> processed_faces;
    processed_faces.reserve(local_rects_around_faces.size());

    for(const auto& face_shape : face_shapes) {
        dlib::matrix<dlib::rgb_pixel> processed_face;
        dlib::extract_image_chip(local_img, dlib::get_face_chip_details(face_shape, face_chip_size, face_chip_padding), processed_face);
        processed_faces.push_back(std::move(processed_face));
    }

    std::vector<dlib::matrix<float, 0, 1>> face_descriptors = local_face_rec_dnn.operator()(processed_faces);

    for(const auto& rect : local_rects_around_faces) {
        dlib::draw_rectangle(local_img, rect, dlib::rgb_pixel{255, 0, 0}, 2);
    }

    emit faces_ready_2(some_worker_thread_id, local_img, face_descriptors, local_rects_around_faces);
    QThread::currentThread()->exit();
}

void Image_handler_worker::cnn_2(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, cnn_face_detector_type& some_cnn_face_detector, dlib::shape_predictor& some_shape_predictor, face_recognition_dnn_type& some_face_recognition_dnn, const unsigned long face_chip_size, const double face_chip_padding)
{
    auto local_img = std::move(some_img);
    auto local_cnn_face_detector = std::move(some_cnn_face_detector);
    auto local_shape_predictor = std::move(some_shape_predictor);
    auto local_face_rec_dnn = std::move(some_face_recognition_dnn);

    const auto local_mmod_rects_around_faces = local_cnn_face_detector(local_img);

    std::vector<dlib::rectangle> local_rects_around_faces;
    local_rects_around_faces.reserve(local_mmod_rects_around_faces.size());

    for(const auto& mmod_rect : local_mmod_rects_around_faces) {
        local_rects_around_faces.push_back(mmod_rect.rect);
    }

    std::vector<dlib::full_object_detection> face_shapes;
    face_shapes.reserve(local_rects_around_faces.size());

    for(const auto& rect : local_rects_around_faces) {
        const auto face_shape = local_shape_predictor.operator()(local_img, rect);
        face_shapes.push_back(face_shape);
    }

    std::vector<dlib::matrix<dlib::rgb_pixel>> processed_faces;
    processed_faces.reserve(local_rects_around_faces.size());

    for(const auto& face_shape : face_shapes) {
        dlib::matrix<dlib::rgb_pixel> processed_face;
        dlib::extract_image_chip(local_img, dlib::get_face_chip_details(face_shape, face_chip_size, face_chip_padding), processed_face);
        processed_faces.push_back(std::move(processed_face));
    }

    std::vector<dlib::matrix<float, 0, 1>> face_descriptors = local_face_rec_dnn.operator()(processed_faces);

    for(const auto& rect : local_rects_around_faces) {
        dlib::draw_rectangle(local_img, rect, dlib::rgb_pixel{255, 0, 0}, 2);
    }

    emit faces_ready_2(some_worker_thread_id, local_img, face_descriptors, local_rects_around_faces);
    QThread::currentThread()->exit();
}

void Image_handler_worker::hog_and_cnn_2(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, hog_face_detector_type& some_hog_face_detector, cnn_face_detector_type& some_cnn_face_detector, dlib::shape_predictor& some_shape_predictor, face_recognition_dnn_type& some_face_recognition_dnn, const unsigned long face_chip_size, const double face_chip_padding)
{
    auto local_img = std::move(some_img);
    auto local_hog_face_detector = std::move(some_hog_face_detector);
    auto local_cnn_face_detector = std::move(some_cnn_face_detector);
    auto local_shape_predictor = std::move(some_shape_predictor);
    auto local_face_rec_dnn = std::move(some_face_recognition_dnn);

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

    std::vector<dlib::full_object_detection> face_shapes;
    face_shapes.reserve(result_rects_around_faces.size());

    for(const auto& rect : result_rects_around_faces) {
        const auto face_shape = local_shape_predictor.operator()(local_img, rect);
        face_shapes.push_back(face_shape);
    }

    std::vector<dlib::matrix<dlib::rgb_pixel>> processed_faces;
    processed_faces.reserve(result_rects_around_faces.size());

    for(const auto& face_shape : face_shapes) {
        dlib::matrix<dlib::rgb_pixel> processed_face;
        dlib::extract_image_chip(local_img, dlib::get_face_chip_details(face_shape, face_chip_size, face_chip_padding), processed_face);
        processed_faces.push_back(std::move(processed_face));
    }

    std::vector<dlib::matrix<float, 0, 1>> face_descriptors = local_face_rec_dnn.operator()(processed_faces);

    for(const auto& rect : result_rects_around_faces) {
        dlib::draw_rectangle(local_img, rect, dlib::rgb_pixel{255, 0, 0}, 2);
    }

    emit faces_ready_2(some_worker_thread_id, local_img, face_descriptors, result_rects_around_faces);
    QThread::currentThread()->exit();
}

void Image_handler_worker::auto_recognize(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, hog_face_detector_type& some_hog_face_detector, dlib::shape_predictor& some_shape_predictor, face_recognition_dnn_type& some_face_recognition_dnn, const unsigned long face_chip_size, const double face_chip_padding, std::map<dlib::matrix<float, 0, 1>, std::string>& some_known_people, const double some_threshold)
{
    auto local_img = std::move(some_img);
    auto local_hog_face_detector = std::move(some_hog_face_detector);
    auto local_shape_predictor = std::move(some_shape_predictor);
    auto local_face_rec_dnn = std::move(some_face_recognition_dnn);
    auto local_known_people = std::move(some_known_people);

    auto local_rects_around_faces = local_hog_face_detector.operator()(local_img);

    std::vector<dlib::full_object_detection> face_shapes;
    face_shapes.reserve(local_rects_around_faces.size());

    for(const auto& rect : local_rects_around_faces) {
        const auto face_shape = local_shape_predictor.operator()(local_img, rect);
        face_shapes.push_back(face_shape);
    }

    std::vector<dlib::matrix<dlib::rgb_pixel>> processed_faces;
    processed_faces.reserve(local_rects_around_faces.size());

    for(const auto& face_shape : face_shapes) {
        dlib::matrix<dlib::rgb_pixel> processed_face;
        dlib::extract_image_chip(local_img, dlib::get_face_chip_details(face_shape, face_chip_size, face_chip_padding), processed_face);
        processed_faces.push_back(std::move(processed_face));
    }

    for(const auto& rect : local_rects_around_faces) {
        dlib::draw_rectangle(local_img, rect, dlib::rgb_pixel{255, 0, 0}, 2);
    }

    std::vector<dlib::matrix<float, 0, 1>> face_descriptors = local_face_rec_dnn.operator()(processed_faces);

    dlib::matrix<dlib::rgb_pixel> dlib_img = local_img;
    cv::Mat img = dlib::toMat(dlib_img);

    std::vector<bool> is_known(face_descriptors.size(), false);

    for(std::size_t i = 0; i < face_descriptors.size(); ++i) {

        float min_diff = 1000.0f;
        std::string min_diff_name;

        for(const auto& entry : local_known_people) {
            const auto diff = dlib::length(face_descriptors[i] - entry.first);
            if(diff < some_threshold) {
                if(diff < min_diff) {
                    min_diff = diff;
                    min_diff_name = entry.second;
                }
                is_known[i] = true;
            }
        }

        if(is_known[i]) {
            cv::rectangle(img, cv::Point(local_rects_around_faces[i].tl_corner().x(), local_rects_around_faces[i].tl_corner().y()),
                               cv::Point(local_rects_around_faces[i].br_corner().x(), local_rects_around_faces[i].br_corner().y()),
                               cv::Scalar(0, 255, 0), 2);
            cv::putText(img, min_diff_name, cv::Point(local_rects_around_faces[i].tl_corner().x(), local_rects_around_faces[i].tl_corner().y()), cv::FONT_HERSHEY_DUPLEX, 0.70, cv::Scalar(0, 255, 0), 2);
        }
    }

    for(std::size_t i = 0; i < is_known.size(); ++i) {
        if(!is_known[i]) {
            cv::putText(img, "unknown", cv::Point(local_rects_around_faces[i].tl_corner().x(), local_rects_around_faces[i].tl_corner().y()), cv::FONT_HERSHEY_DUPLEX, 0.70, cv::Scalar(255, 0, 0), 2);
        }
    }

    dlib::cv_image<dlib::rgb_pixel> res_dlib_img = img;
    dlib::matrix<dlib::rgb_pixel> res_img;
    dlib::assign_image(res_img, res_dlib_img);

    emit auto_recognize_ready(some_worker_thread_id, res_img);
    QThread::currentThread()->exit();
}
