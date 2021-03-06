#include "video_file_capture.h"

Video_file_capture::Video_file_capture(QObject *parent)
    : QObject(parent)
{
    Image_handler_initializer* image_handler_initializer = new Image_handler_initializer;
    connect(image_handler_initializer, &Image_handler_initializer::hog_face_detector_ready, this, &Video_file_capture::receive_hog_face_detector);
    connect(image_handler_initializer, &Image_handler_initializer::cnn_face_detector_ready, this, &Video_file_capture::receive_cnn_face_detector);
    connect(image_handler_initializer, &Image_handler_initializer::shape_predictor_ready, this, &Video_file_capture::receive_shape_predictor);
    connect(image_handler_initializer, &Image_handler_initializer::face_recognition_dnn_ready, this, &Video_file_capture::receive_face_recognition_dnn);
    connect(image_handler_initializer, &Image_handler_initializer::finished, image_handler_initializer, &Image_handler_initializer::deleteLater);
    image_handler_initializer->start();
}

void Video_file_capture::receive_hog_face_detector(hog_face_detector_type& some_hog_face_detector)
{
    hog_face_detector = std::move(some_hog_face_detector);
    is_hog_face_detector_initialized = true;
    try_enable_start();
}

void Video_file_capture::receive_cnn_face_detector(cnn_face_detector_type& some_cnn_face_detector)
{
    cnn_face_detector = std::move(some_cnn_face_detector);
    is_cnn_face_detector_initialized = true;
    try_enable_start();
}

void Video_file_capture::receive_shape_predictor(dlib::shape_predictor& some_shape_predictor)
{
    shape_predictor = std::move(some_shape_predictor);
    is_shape_predictor_initialized = true;
    try_enable_start();
}

void Video_file_capture::receive_face_recognition_dnn(face_recognition_dnn_type& some_face_recognition_dnn)
{
    face_recognition_dnn = std::move(some_face_recognition_dnn);
    is_face_recognition_dnn_initialized = true;
    try_enable_start();
}

void Video_file_capture::selected_people_initialized_slot(std::map<dlib::matrix<float, 0, 1>, std::string>& some_people)
{
    known_people = some_people;
    is_known_people_initialized = true;
    try_enable_start();
    qDebug() << "known_people.size() = " << known_people.size();
}

void Video_file_capture::safe_destroy_slot()
{
    if(is_destroy) {
        emit safe_destroy();
    }
}

void Video_file_capture::accept_selected_people(const QVector<QString>& some_selected_people)
{
    Image_handler_worker* worker = new Image_handler_worker;

    auto local_selected_people = some_selected_people;

    connect(this, &Video_file_capture::start_selected_people_initializing, worker, &Image_handler_worker::selected_people_initializing);
    connect(worker, &Image_handler_worker::selected_people_initialized, this, &Video_file_capture::selected_people_initialized_slot);

    emit start_selected_people_initializing(local_selected_people );
}

void Video_file_capture::set_is_running(const bool some_value)
{
    std::lock_guard<std::mutex> lock(is_running_mutex);
    is_running = some_value;
}

bool Video_file_capture::get_is_running()
{
    std::lock_guard<std::mutex> lock(is_running_mutex);
    return is_running;
}

double Video_file_capture::get_threshold()
{
    std::lock_guard<std::mutex> lock(threshold_mutex);
    return threshold;
}

bool Video_file_capture::get_is_hog()
{
    std::lock_guard<std::mutex> lock(is_hog_mutex);
    return is_hog;
}

bool Video_file_capture::get_is_recognize()
{
    std::lock_guard<std::mutex> lock(is_recognize_mutex);
    return is_recognize;
}

void Video_file_capture::start(const QString &some_in_file_path, const QString &some_out_file_path)
{
    if(get_is_running()) {
        return;
    }

    in_file_path = some_in_file_path;
    out_file_path = some_out_file_path;

    QThread* thread = QThread::create([this]()
    {
        cv::VideoCapture cap(in_file_path.toStdString());

        if (!cap.isOpened()) {
            qDebug() << "Unable to open file: " << in_file_path;
            return 1;
        }
        else {
            qDebug() << "file was opened";
        }

        const auto fps = static_cast<int>(cap.get(cv::CAP_PROP_FPS));
        const auto frame_width = static_cast<int>(cap.get(cv::CAP_PROP_FRAME_WIDTH));
        const auto frame_height = static_cast<int>(cap.get(cv::CAP_PROP_FRAME_HEIGHT));
        const auto fourcc = static_cast<int>(cap.get(cv::CAP_PROP_FOURCC));

        cv::VideoWriter video_writer;
        if(video_writer.open(out_file_path.toStdString(), fourcc, fps, cv::Size(frame_width, frame_height))) {
            qDebug() << "video_writer was opened";
            set_is_running(true);
        }
        else {
            qDebug() << "video_writer was not opened";
            return 1;
        }

        const auto count_of_frames = static_cast<int>(cap.get(cv::CAP_PROP_FRAME_COUNT));
        const double video_duration = count_of_frames / static_cast<double>(fps);

        emit video_info(fps, frame_width, frame_height, count_of_frames, video_duration);

        cv::Mat cv_frame;
        dlib::cv_image<dlib::rgb_pixel> dlib_frame;
        std::vector<dlib::rectangle> rects_around_faces;
        std::vector<dlib::full_object_detection> face_shapes;
        std::vector<dlib::matrix<dlib::rgb_pixel>> processed_faces;
        dlib::matrix<dlib::rgb_pixel> processed_face;
        std::vector<dlib::matrix<float, 0, 1>> face_descriptors;
        std::vector<bool> is_known;
        QImage res_q_img;

        for(;;)
        {
            if(!get_is_running()) {
                break;
            }

            if(!cap.read(cv_frame)) {
                set_is_running(false);
                qDebug() << "can not read image";
                break;
            }
            cv::cvtColor(cv_frame, cv_frame, cv::COLOR_BGR2RGB);

            dlib_frame = cv_frame;
            if(get_is_hog()) {
                rects_around_faces = hog_face_detector(dlib_frame);
                if(!get_is_recognize()) {
                    for(const auto& rect : rects_around_faces) {
                        dlib::draw_rectangle(dlib_frame, rect, dlib::rgb_pixel(255, 0, 0), 2);
                    }
                }
            }

            if(get_is_recognize()) {
                face_shapes.clear();
                processed_faces.clear();
                face_descriptors.clear();

                for(const auto& rect : rects_around_faces) {
                    face_shapes.emplace_back(shape_predictor.operator()(dlib_frame, rect));
                }
                for(const auto& face_shape : face_shapes) {
                    dlib::extract_image_chip(dlib_frame, dlib::get_face_chip_details(face_shape, face_chip_size, face_chip_padding), processed_face);
                    processed_faces.push_back(std::move(processed_face));
                }
                face_descriptors = face_recognition_dnn.operator()(processed_faces);
                for(const auto& rect : rects_around_faces) {
                    dlib::draw_rectangle(dlib_frame, rect, dlib::rgb_pixel(255, 0, 0), 2);
                }
                is_known = std::vector<bool>(face_descriptors.size(), false);

                for(std::size_t i = 0; i < face_descriptors.size(); ++i) {

                    float min_diff = 1000.0f;
                    std::string min_diff_name;

                    for(const auto& entry : known_people) {
                        const auto diff = dlib::length(face_descriptors[i] - entry.first);
                        if(diff < get_threshold()) {
                            if(diff < min_diff) {
                                min_diff = diff;
                                min_diff_name = entry.second;
                            }
                            is_known[i] = true;
                        }
                    }

                    if(is_known[i]) {
                        cv::rectangle(cv_frame, cv::Point(rects_around_faces[i].tl_corner().x(), rects_around_faces[i].tl_corner().y()),
                                           cv::Point(rects_around_faces[i].br_corner().x(), rects_around_faces[i].br_corner().y()),
                                           cv::Scalar(0, 255, 0), 2);
                        cv::putText(cv_frame, min_diff_name, cv::Point(rects_around_faces[i].tl_corner().x(), rects_around_faces[i].tl_corner().y()), cv::FONT_HERSHEY_DUPLEX, 0.70, cv::Scalar(0, 255, 0), 2);
                    }
                }

                for(std::size_t i = 0; i < is_known.size(); ++i) {
                    if(!is_known[i]) {
                        cv::putText(cv_frame, "unknown", cv::Point(rects_around_faces[i].tl_corner().x(), rects_around_faces[i].tl_corner().y()), cv::FONT_HERSHEY_DUPLEX, 0.70, cv::Scalar(255, 0, 0), 2);
                    }
                }
            }

            const auto frame_data = dlib::image_data(dlib_frame);
            const QImage q_img(static_cast<const uchar*>(frame_data),
                               static_cast<int>(dlib_frame.nc()),
                               static_cast<int>(dlib_frame.nr()),
                               3 * static_cast<int>(dlib_frame.nc()),
                               QImage::Format_RGB888);
            res_q_img = q_img.copy();

            cv::cvtColor(cv_frame, cv_frame, cv::COLOR_RGB2BGR);
            video_writer.write(cv_frame);

            const double cur_sec_pos = static_cast<int>(cap.get(cv::CAP_PROP_POS_MSEC)) / static_cast<double>(1000);
            const auto cur_frame_pos = static_cast<int>(cap.get(cv::CAP_PROP_POS_FRAMES));

            {
                std::lock_guard<std::mutex> lock(is_running_mutex);
                emit img_ready(res_q_img);
                emit current_progress(cur_sec_pos, cur_frame_pos);
            }

        }

        video_writer.release();
        cap.release();

        QThread::currentThread()->exit(0);
        return 0;
    });

    connect(thread, &QThread::finished, thread, &QObject::deleteLater);
    connect(thread, &QThread::finished, this, &Video_file_capture::worker_thread_finished);
    connect(thread, &QThread::finished, this, &Video_file_capture::safe_destroy_slot);
    thread->start();
}

void Video_file_capture::stop()
{
    set_is_running(false);
}

void Video_file_capture::exit()
{
    is_destroy = true;
    set_is_running(false);
}

void Video_file_capture::set_threshold(const double some_threshold)
{
    std::lock_guard<std::mutex> lock(threshold_mutex);
    threshold = some_threshold;
}

void Video_file_capture::set_is_hog(const bool some_value)
{
    std::lock_guard<std::mutex> lock(is_hog_mutex);
    is_hog = some_value;
}

void Video_file_capture::set_is_recognize(const bool some_value)
{
    std::lock_guard<std::mutex> lock(is_recognize_mutex);
    is_recognize = some_value;
}

void Video_file_capture::try_enable_start()
{
    if(is_hog_face_detector_initialized && is_cnn_face_detector_initialized && is_shape_predictor_initialized && is_face_recognition_dnn_initialized && is_known_people_initialized) {
        emit enable_start();
    }
}



