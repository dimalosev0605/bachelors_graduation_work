#ifndef IMAGE_HANDLER_INITIALIZER_H
#define IMAGE_HANDLER_INITIALIZER_H

#include <QObject>
#include <QDebug>
#include <QThread>

#include <dlib/image_io.h>
#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/image_processing.h>
#include <dlib/dnn.h>
#include <dlib/image_io.h>
#include <dlib/opencv.h>
#include <opencv2/imgproc.hpp>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>

using hog_face_detector_type = dlib::object_detector<dlib::scan_fhog_pyramid<dlib::pyramid_down<6>, dlib::default_fhog_feature_extractor>>;

class Image_handler_initializer: public QThread
{
    Q_OBJECT
    hog_face_detector_type hog_face_detector;
    dlib::shape_predictor shape_predictor;

    void run() override;

public:
    explicit Image_handler_initializer(QObject* parent = nullptr);
    ~Image_handler_initializer();

signals:
    void hog_face_detector_ready(const hog_face_detector_type& some_hog_face_detector);
    void shape_predictor_ready(const dlib::shape_predictor& some_shape_predictor);
};

#endif // IMAGE_HANDLER_INITIALIZER_H
