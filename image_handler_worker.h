#ifndef IMAGE_HANDLER_WORKER_H
#define IMAGE_HANDLER_WORKER_H

#include <QObject>
#include <QDebug>
#include <QThread>
#include <QSettings>

#include "image_handler_initializer.h"
#include "file_system/dir_paths.h"

class Image_handler_worker : public QObject
{
    Q_OBJECT
    QThread* thread;
    float face_recognition_threshold = 0.6;

public:
    explicit Image_handler_worker(QObject* parent = nullptr);
    ~Image_handler_worker();

public slots:
    void hog(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, hog_face_detector_type& some_hog_face_detector);
    void cnn(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, cnn_face_detector_type& some_cnn_face_detector);
    void hog_and_cnn(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, hog_face_detector_type& some_hog_face_detector, cnn_face_detector_type& some_cnn_face_detector);

    void pyr_up(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img);
    void pyr_down(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img);
    void resize(const int some_worker_thread_id, const dlib::matrix<dlib::rgb_pixel>& some_img, const int some_width, const int some_height);

    // slots for auto_image_handler
    void search_target_face(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, hog_face_detector_type& some_hog_face_detector, dlib::shape_predictor& some_shape_predictor, const unsigned long face_chip_size, const double face_chip_padding);
    void handle_remaining_images(const int some_worker_thread_id, hog_face_detector_type& some_hog_face_detector, dlib::shape_predictor& some_shape_predictor, face_recognition_dnn_type& some_face_recognition_dnn, dlib::matrix<dlib::rgb_pixel>& some_target_face_img , const QVector<QString>& some_selected_imgs_paths, const unsigned long face_chip_size, const double face_chip_padding);

    // slots for recognition_image_handler
    void selected_people_initializing(QVector<QString>& some_selected_people);
    void hog_2(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, hog_face_detector_type& some_hog_face_detector, dlib::shape_predictor& some_shape_predictor, face_recognition_dnn_type& some_face_recognition_dnn, const unsigned long face_chip_size, const double face_chip_padding);
    void cnn_2(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, cnn_face_detector_type& some_cnn_face_detector, dlib::shape_predictor& some_shape_predictor, face_recognition_dnn_type& some_face_recognition_dnn,  const unsigned long face_chip_size, const double face_chip_padding);
    void hog_and_cnn_2(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, hog_face_detector_type& some_hog_face_detector, cnn_face_detector_type& some_cnn_face_detector, dlib::shape_predictor& some_shape_predictor, face_recognition_dnn_type& some_face_recognition_dnn, const unsigned long face_chip_size, const double face_chip_padding);
    void auto_recognize(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, hog_face_detector_type& some_hog_face_detector, dlib::shape_predictor& some_shape_predictor, face_recognition_dnn_type& some_face_recognition_dnn, const unsigned long face_chip_size, const double face_chip_padding, std::map<dlib::matrix<float, 0, 1>, std::string>& some_known_people, const double some_threshold);

signals:
    void faces_ready(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, std::vector<dlib::rectangle>& some_rects_around_faces);
    void img_ready(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img);
    void message(const QString& some_message, const int some_worker_thread_id);
    void target_faces_ready(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, const int number_of_faces);
    void remaining_images_ready(const int some_worker_thread_id, std::vector<std::tuple<dlib::matrix<dlib::rgb_pixel>, dlib::matrix<dlib::rgb_pixel>, dlib::matrix<float, 0, 1>>>& some_imgs);
    void selected_people_initialized(std::map<dlib::matrix<float, 0, 1>, std::string>& some_selected_people);

    // signals for recognition_image_handler
    void faces_ready_2(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img, std::vector<dlib::matrix<float, 0, 1>>& some_face_descriptors, std::vector<dlib::rectangle>& some_rects_around_faces);
    void auto_recognize_ready(const int some_worker_thread_id, dlib::matrix<dlib::rgb_pixel>& some_img);
};

#endif // IMAGE_HANDLER_WORKER_H
