#ifndef AUTO_IMAGE_HANDLER_H
#define AUTO_IMAGE_HANDLER_H

#include <QObject>
#include <QDebug>

#include "image_data.h"
#include "image_handler_initializer.h"
#include "image_handler_worker.h"

#include <dlib/image_io.h>
#include <opencv2/opencv.hpp>

class Auto_image_handler : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool is_ok_enable READ get_is_ok_enable WRITE set_is_ok_enable NOTIFY is_ok_enable_changed)
    bool is_ok_enable = false;

    Q_PROPERTY(bool is_busy_indicator_running READ get_is_busy_indicator_running WRITE set_is_busy_indicator_running NOTIFY is_busy_indicator_running_changed)
    bool is_busy_indicator_running = false;

    dlib::matrix<dlib::rgb_pixel> img_with_target_face;
    dlib::matrix<dlib::rgb_pixel> target_face;

    hog_face_detector_type hog_face_detector;
    cnn_face_detector_type cnn_face_detector;
    dlib::shape_predictor shape_predictor;

    const unsigned long face_chip_size = 150;
    const double face_chip_padding = 0.25;

    int worker_thread_id = 0;

private:
    void send_image_data_ready_signal();

private slots:
    void receive_hog_face_detector(hog_face_detector_type& some_hog_face_detector);
    void receive_cnn_face_detector(cnn_face_detector_type& some_cnn_face_detector);
    void receive_shape_predictor(dlib::shape_predictor& some_shape_predictor);

    void img_ready_slot(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img);

public:
    explicit Auto_image_handler(QObject *parent = nullptr);

    bool get_is_ok_enable() const;
    void set_is_ok_enable(const bool some_value);

    bool get_is_busy_indicator_running() const;
    void set_is_busy_indicator_running(const bool some_value);

public slots:
    void curr_image_changed(const QString& curr_img_path);
    void search_target_face();
    void receive_message(const QString& some_message, const int some_worker_thread_id);
    void cancel();

signals:
    void is_ok_enable_changed();
    void is_busy_indicator_running_changed();
    void start_search_target_face(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, hog_face_detector_type& some_hog_face_detector, cnn_face_detector_type& some_cnn_face_detector, const dlib::shape_predictor& some_shape_predictor, const unsigned long face_chip_size, const double face_chip_padding);
    void image_data_ready(const Image_data& some_img_data);
    void message(const QString& some_message);
};

#endif // AUTO_IMAGE_HANDLER_H
