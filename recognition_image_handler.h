#ifndef RECOGNITION_IMAGE_HANDLER_H
#define RECOGNITION_IMAGE_HANDLER_H

#include <QObject>
#include <QDebug>

#include "image_data.h"
#include "image_handler_initializer.h"
#include "image_handler_worker.h"

#include <dlib/image_io.h>
#include <opencv2/opencv.hpp>

class Recognition_image_handler : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool is_busy_indicator_running READ get_is_busy_indicator_running WRITE set_is_busy_indicator_running NOTIFY is_busy_indicator_running_changed)
    bool is_busy_indicator_running = false;

    Q_PROPERTY(bool is_hog_enable READ get_is_hog_enable WRITE set_is_hog_enable NOTIFY is_hog_enable_changed)
    bool is_hog_enable = false;

    Q_PROPERTY(bool is_cnn_enable READ get_is_cnn_enable WRITE set_is_cnn_enable NOTIFY is_cnn_enable_changed)
    bool is_cnn_enable = false;

    Q_PROPERTY(bool is_recognize_enable READ get_is_recognize_enable WRITE set_is_recognize_enable NOTIFY is_recognize_enable_changed)
    bool is_recognize_enable = false;

    Q_PROPERTY(bool is_cancel_enabled READ get_is_cancel_enabled WRITE set_is_cancel_enabled NOTIFY is_cancel_enabled_changed)
    bool is_cancel_enabled = false;

    std::vector<dlib::matrix<dlib::rgb_pixel>> imgs;
    std::vector<dlib::rectangle> rects_around_faces;

    std::size_t find_faces_img_index = 0;
    std::size_t modified_img_index = 0;

    hog_face_detector_type hog_face_detector;
    cnn_face_detector_type cnn_face_detector;
    dlib::shape_predictor shape_predictor;
    face_recognition_dnn_type face_recognition_dnn;

    const unsigned long face_chip_size = 150;
    const double face_chip_padding = 0.25;

    int worker_thread_id = 0;

private slots:
    void receive_hog_face_detector(hog_face_detector_type& some_hog_face_detector);
    void receive_cnn_face_detector(cnn_face_detector_type& some_cnn_face_detector);
    void receive_shape_predictor(dlib::shape_predictor& some_shape_predictor);
    void receive_face_recognition_dnn(face_recognition_dnn_type& some_face_recognition_dnn);

    void faces_ready_slot(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, std::vector<dlib::rectangle>& some_rects_around_faces);
    void img_ready_slot(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img);

private:
    void send_image_data_ready_signal();

public:
    explicit Recognition_image_handler(QObject *parent = nullptr);

    bool get_is_busy_indicator_running() const;
    void set_is_busy_indicator_running(const bool some_value);

    bool get_is_hog_enable() const;
    void set_is_hog_enable(const bool some_value);

    bool get_is_cnn_enable() const;
    void set_is_cnn_enable(const bool some_value);

    bool get_is_recognize_enable() const;
    void set_is_recognize_enable(const bool some_value);

    bool get_is_cancel_enabled() const;
    void set_is_cancel_enabled(const bool some_value);

public slots:
    void curr_image_changed(const QString& curr_img_path);

    void hog();
    void cnn();
    void hog_and_cnn();

    void pyr_up();
    void pyr_down();
    void resize(const int some_width, const int some_height);

    void cancel_processing();
    void cancel_last_action();

signals:
    void is_busy_indicator_running_changed();
    void is_hog_enable_changed();
    void is_cnn_enable_changed();
    void is_recognize_enable_changed();
    void is_cancel_enabled_changed();

    void start_hog(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, hog_face_detector_type& some_hog_face_detector);
    void start_cnn(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, cnn_face_detector_type& some_cnn_face_detector);
    void start_hog_and_cnn(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, hog_face_detector_type& some_hog_face_detector, cnn_face_detector_type& some_cnn_face_detector);

    void start_pyr_up(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img);
    void start_pyr_down(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img);
    void start_resize(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img, const int some_width, const int some_height);

    void image_data_ready(const Image_data& some_img_data);
};

#endif // RECOGNITION_IMAGE_HANDLER_H
