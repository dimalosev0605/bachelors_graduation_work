#ifndef IMAGE_HANDLER_WORKER_H
#define IMAGE_HANDLER_WORKER_H

#include <QObject>
#include <QDebug>
#include <QThread>

#include "image_handler_initializer.h"

class Image_handler_worker : public QObject
{
    Q_OBJECT

public:
    explicit Image_handler_worker(QObject *parent = nullptr);
    ~Image_handler_worker();

public slots:
    void hog(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img, const hog_face_detector_type& some_hog_face_detector);
    void cnn(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img, const cnn_face_detector_type& some_cnn_face_detector);
    void hog_and_cnn(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img, const hog_face_detector_type& some_hog_face_detector, const cnn_face_detector_type& some_cnn_face_detector);

    void pyr_up(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img);
    void pyr_down(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img);
    void resize(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img, const int some_width, const int some_height);

signals:
    void faces_ready(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img, const std::vector<dlib::rectangle>& some_rects_around_faces);
    void img_ready(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img);
};

#endif // IMAGE_HANDLER_WORKER_H
