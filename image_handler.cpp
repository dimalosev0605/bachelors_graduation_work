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

bool Image_handler::get_is_busy_indicator_running() const
{
    return is_busy_indicator_running;
}

void Image_handler::set_is_busy_indicator_running(const bool some_value)
{
    is_busy_indicator_running = some_value;
    emit is_busy_indicator_running_changed();
}

void Image_handler::curr_image_changed(const QString& curr_img_path)
{
    dlib::load_image(img, curr_img_path.toStdString());
    original_img = img;

    const auto data = dlib::image_data(img);
    Image_data image_data(data, img.nc(), img.nr());

    emit image_data_ready(image_data);
}

void Image_handler::receive_hog_face_detector(const hog_face_detector_type& some_hog_face_detector)
{
    hog_face_detector = some_hog_face_detector;
}

void Image_handler::receive_shape_predictor(const dlib::shape_predictor& some_shape_predictor)
{
    shape_predictor = some_shape_predictor;
}

void Image_handler::hog()
{
    set_is_busy_indicator_running(true);
    ++worker_thread_id;

    auto worker_thread = QThread::create(std::bind(&Image_handler::hog_thread_function, this, worker_thread_id, img, hog_face_detector));
    connect(this, &Image_handler::hog_ready, this, &Image_handler::hog_ready_slot, Qt::UniqueConnection);
    connect(worker_thread, &QThread::finished, worker_thread, &QObject::deleteLater);

    worker_thread->start();
}

void Image_handler::hog_thread_function(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, hog_face_detector_type& some_hog_face_detector)
{
    auto local_img = std::move(some_img);
    auto local_hog_face_detector = std::move(some_hog_face_detector);

    const auto local_rects_around_faces = local_hog_face_detector.operator()(local_img);

    for(const auto& rect : local_rects_around_faces) {
        dlib::draw_rectangle(local_img, rect, dlib::rgb_pixel{255, 0, 0}, 2);
    }

    emit hog_ready(some_worker_thread_id, local_img, local_rects_around_faces);
    QThread::currentThread()->exit(0);
}

void Image_handler::hog_ready_slot(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img, const std::vector<dlib::rectangle>& some_rects_around_faces)
{
    if(worker_thread_id == some_worker_thread_id) {
        qDebug() << "Update image.";
        img = some_img;
        rects_around_faces = some_rects_around_faces;

        const auto data = dlib::image_data(img);
        Image_data image_data(data, img.nc(), img.nr());

        emit image_data_ready(image_data);
        set_is_busy_indicator_running(false);
    }
    else {
        qDebug() << "Ignore image.";
    }
}

void Image_handler::cancel()
{
    ++worker_thread_id;
    img = original_img;
    const auto data = dlib::image_data(img);
    Image_data image_data(data, img.nc(), img.nr());
    emit image_data_ready(image_data);
    set_is_busy_indicator_running(false);
}
