#ifndef VIDEO_FILE_CAPTURE_H
#define VIDEO_FILE_CAPTURE_H

#include <QObject>
#include <QDebug>
#include <QThread>
#include <QImage>

#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/core.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/highgui.hpp>
#include <dlib/image_io.h>
#include <opencv2/opencv.hpp>

#include <dlib/opencv.h>
#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/image_processing.h>

#include "image_handler_initializer.h"
#include "image_handler_worker.h"

class Video_file_capture : public QObject
{
    Q_OBJECT

    double threshold = 0.55;
    std::mutex threshold_mutex;

    bool is_running = false;
    std::mutex is_running_mutex;

    bool is_hog = false;
    std::mutex is_hog_mutex;

    bool is_recognize = false;
    std::mutex is_recognize_mutex;

    bool is_destroy = false;

    hog_face_detector_type hog_face_detector;
    bool is_hog_face_detector_initialized = false;

    cnn_face_detector_type cnn_face_detector;
    bool is_cnn_face_detector_initialized = false;

    dlib::shape_predictor shape_predictor;
    bool is_shape_predictor_initialized = false;

    face_recognition_dnn_type face_recognition_dnn;
    bool is_face_recognition_dnn_initialized = false;

    std::map<dlib::matrix<float, 0, 1>, std::string> known_people;
    bool is_known_people_initialized = false;

    const unsigned long face_chip_size = 150;
    const double face_chip_padding = 0.25;

    QString in_file_path;
    QString out_file_path;

private:
    void try_enable_start();

    void set_is_running(const bool some_value);

    double get_threshold();
    bool get_is_hog();
    bool get_is_recognize();

private slots:
    void receive_hog_face_detector(hog_face_detector_type& some_hog_face_detector);
    void receive_cnn_face_detector(cnn_face_detector_type& some_cnn_face_detector);
    void receive_shape_predictor(dlib::shape_predictor& some_shape_predictor);
    void receive_face_recognition_dnn(face_recognition_dnn_type& some_face_recognition_dnn);
    void selected_people_initialized_slot(std::map<dlib::matrix<float, 0, 1>, std::string>& some_people);

    void safe_destroy_slot();

public:
    explicit Video_file_capture(QObject *parent = nullptr);

public slots:
    void accept_selected_people(const QVector<QString>& some_selected_people);

    void start(const QString& some_in_file_path, const QString& some_out_file_path);
    void stop();
    void exit();

    void set_threshold(const double some_threshold);
    void set_is_hog(const bool some_value);
    void set_is_recognize(const bool some_value);

    bool get_is_running();

signals:
    void img_ready(const QImage& some_img);
    void start_selected_people_initializing(QVector<QString>& some_selected_people);
    void enable_start();
    void safe_destroy();

    void video_info(const int some_fps, const int some_frame_width, const int some_frame_height, const int some_count_of_frames, const double some_duration);
    void current_progress(const double some_sec_pos, const int some_frame_pos);
};

#endif // VIDEO_FILE_CAPTURE_H
