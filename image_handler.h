#ifndef IMAGE_HANDLER_H
#define IMAGE_HANDLER_H

#include <QObject>
#include <QDebug>

#include "image_data.h"
#include "image_handler_initializer.h"

#include <dlib/image_io.h>
#include <opencv2/opencv.hpp>

class Image_handler : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool is_busy_indicator_running READ get_is_busy_indicator_running WRITE set_is_busy_indicator_running NOTIFY is_busy_indicator_running_changed)
    bool is_busy_indicator_running = false;

    Q_PROPERTY(bool is_hog_enable READ get_is_hog_enable WRITE set_is_hog_enable NOTIFY is_hog_enable_changed)
    bool is_hog_enable = false;

    Q_PROPERTY(bool is_cnn_enable READ get_is_cnn_enable WRITE set_is_cnn_enable NOTIFY is_cnn_enable_changed)
    bool is_cnn_enable = true;

    Q_PROPERTY(bool is_extract_face_enable READ get_is_extract_face_enable WRITE set_is_extract_face_enable NOTIFY is_extract_face_enable_changed)
    bool is_extract_face_enable = false;

    Q_PROPERTY(bool is_cancel_enabled READ get_is_cancel_enabled WRITE set_is_cancel_enabled NOTIFY is_cancel_enabled_changed)
    bool is_cancel_enabled = false;

    std::vector<dlib::matrix<dlib::rgb_pixel>> imgs;
    std::size_t hog_img_index = 0;
    std::size_t extract_face_img_index = 0;
    int worker_thread_id = 0;
    std::vector<dlib::rectangle> rects_around_faces;
    hog_face_detector_type hog_face_detector;
    dlib::shape_predictor shape_predictor;

private slots:
    void receive_hog_face_detector(const hog_face_detector_type& some_hog_face_detector);
    void receive_shape_predictor(const dlib::shape_predictor& some_shape_predictor);

    void hog_ready_slot(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img, const std::vector<dlib::rectangle>& some_rects_around_faces);

private:
    void hog_thread_function(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, hog_face_detector_type& some_hog_face_detector);
    void send_image_data_ready_signal();

public:
    explicit Image_handler(QObject *parent = nullptr);

    bool get_is_busy_indicator_running() const;
    void set_is_busy_indicator_running(const bool some_value);

    bool get_is_hog_enable() const;
    void set_is_hog_enable(const bool some_value);

    bool get_is_cnn_enable() const;
    void set_is_cnn_enable(const bool some_value);

    bool get_is_extract_face_enable() const;
    void set_is_extract_face_enable(const bool some_value);

    bool get_is_cancel_enabled() const;
    void set_is_cancel_enabled(const bool some_value);

public slots:
    void curr_image_changed(const QString& curr_img_path);
    void hog();
    void extract_face();

    void cancel_processing();
    void cancel_last_action();

signals:
    void is_busy_indicator_running_changed();
    void is_hog_enable_changed();
    void is_cnn_enable_changed();
    void is_extract_face_enable_changed();
    void is_cancel_enabled_changed();

    void image_data_ready(const Image_data& some_img_data);
    void hog_ready(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img, const std::vector<dlib::rectangle>& some_rects_around_faces);
};

#endif // IMAGE_HANDLER_H
