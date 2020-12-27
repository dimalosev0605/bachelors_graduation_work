#ifndef IMAGE_HANDLER_H
#define IMAGE_HANDLER_H

#include <QObject>
#include <QDebug>

#include "image_data.h"
#include "image_handler_initializer.h"

#include <dlib/image_io.h>

class Image_handler : public QObject
{
    Q_OBJECT
    dlib::matrix<dlib::rgb_pixel> img;

    hog_face_detector_type hog_face_detector;
    dlib::shape_predictor shape_predictor;

private slots:
    void receive_hog_face_detector(const hog_face_detector_type& some_hog_face_detector);
    void receive_shape_predictor(const dlib::shape_predictor& some_shape_predictor);

public:
    explicit Image_handler(QObject *parent = nullptr);

public slots:
    void curr_image_changed(const QString& curr_img_path);

signals:
    void image_data_ready(const Image_data& some_img_data);
};

#endif // IMAGE_HANDLER_H
