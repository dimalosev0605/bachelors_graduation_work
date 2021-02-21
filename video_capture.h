#ifndef VIDEO_CAPTURE_H
#define VIDEO_CAPTURE_H

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

class Video_capture : public QObject
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
    cnn_face_detector_type cnn_face_detector;
    dlib::shape_predictor shape_predictor;
    face_recognition_dnn_type face_recognition_dnn;

    std::map<dlib::matrix<float, 0, 1>, std::string> known_people;

    const unsigned long face_chip_size = 150;
    const double face_chip_padding = 0.25;

private:
    double get_threshold();
    bool get_is_running();
    bool get_is_hog();
    bool get_is_recognize();

private slots:
    void receive_hog_face_detector(hog_face_detector_type& some_hog_face_detector);
    void receive_cnn_face_detector(cnn_face_detector_type& some_cnn_face_detector);
    void receive_shape_predictor(dlib::shape_predictor& some_shape_predictor);
    void receive_face_recognition_dnn(face_recognition_dnn_type& some_face_recognition_dnn);

    void safe_destroy_slot();

    void selected_people_initialized_slot(std::map<dlib::matrix<float, 0, 1>, std::string>& some_people);

public:
    explicit Video_capture(QObject *parent = nullptr);


public slots:
    void start();
    void stop();
    void exit();

    void set_threshold(const double some_threshold);
    void set_is_running(const bool some_value);
    void set_is_hog(const bool some_value);
    void set_is_recognize(const bool some_value);

    void accept_selected_people(const QVector<QString>& some_selected_people);

signals:
    void img_ready(const QImage& some_img);
    void safe_destroy();

    void start_selected_people_initializing(QVector<QString>& some_selected_people);
};

#endif // VIDEO_CAPTURE_H
