#ifndef IMAGE_HANDLER_INITIALIZER_H
#define IMAGE_HANDLER_INITIALIZER_H

#include <QObject>
#include <QDebug>
#include <QThread>

#include <type_traits>

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

template <long num_filters, typename SUBNET> using con5d = dlib::con<num_filters,5,5,2,2,SUBNET>;
template <long num_filters, typename SUBNET> using con5  = dlib::con<num_filters,5,5,1,1,SUBNET>;

template <typename SUBNET> using downsampler  = dlib::relu<dlib::affine<con5d<32, dlib::relu<dlib::affine<con5d<32, dlib::relu<dlib::affine<con5d<16,SUBNET>>>>>>>>>;
template <typename SUBNET> using rcon5  = dlib::relu<dlib::affine<con5<45,SUBNET>>>;

using cnn_face_detector_type = dlib::loss_mmod<dlib::con<1,9,9,1,1,rcon5<rcon5<rcon5<downsampler<dlib::input_rgb_image_pyramid<dlib::pyramid_down<6>>>>>>>>;

template <template <int,template<typename>class,int,typename> class block, int N, template<typename>class BN, typename SUBNET>
using residual = dlib::add_prev1<block<N,BN,1,dlib::tag1<SUBNET>>>;

template <template <int,template<typename>class,int,typename> class block, int N, template<typename>class BN, typename SUBNET>
using residual_down = dlib::add_prev2<dlib::avg_pool<2,2,2,2,dlib::skip1<dlib::tag2<block<N,BN,2,dlib::tag1<SUBNET>>>>>>;

template <int N, template <typename> class BN, int stride, typename SUBNET>
using block  = BN<dlib::con<N,3,3,1,1,dlib::relu<BN<dlib::con<N,3,3,stride,stride,SUBNET>>>>>;

template <int N, typename SUBNET> using ares      = dlib::relu<residual<block,N,dlib::affine,SUBNET>>;
template <int N, typename SUBNET> using ares_down = dlib::relu<residual_down<block,N,dlib::affine,SUBNET>>;

template <typename SUBNET> using alevel0 = ares_down<256,SUBNET>;
template <typename SUBNET> using alevel1 = ares<256,ares<256,ares_down<256,SUBNET>>>;
template <typename SUBNET> using alevel2 = ares<128,ares<128,ares_down<128,SUBNET>>>;
template <typename SUBNET> using alevel3 = ares<64,ares<64,ares<64,ares_down<64,SUBNET>>>>;
template <typename SUBNET> using alevel4 = ares<32,ares<32,ares<32,SUBNET>>>;

using face_recognition_dnn_type = dlib::loss_metric<dlib::fc_no_bias<128,dlib::avg_pool_everything<
                            alevel0<
                            alevel1<
                            alevel2<
                            alevel3<
                            alevel4<
                            dlib::max_pool<3,3,2,2,dlib::relu<dlib::affine<dlib::con<32,7,7,2,2,
                            dlib::input_rgb_image_sized<150>
                            >>>>>>>>>>>>;

enum class Initialization_flags {
    All                     = ~0,       // all bits equal 1
    Hog_face_detector       = 1 << 0,   // 1
    Cnn_face_detector       = 1 << 1,   // 2
    Shape_predictor         = 1 << 2,   // 4
    Face_recognition_dnn    = 1 << 3    // 8
};

Initialization_flags operator | (Initialization_flags lhs, Initialization_flags rhs);
Initialization_flags operator & (Initialization_flags lhs, Initialization_flags rhs);

class Image_handler_initializer: public QThread
{
    Q_OBJECT

    hog_face_detector_type hog_face_detector;
    cnn_face_detector_type cnn_face_detector;
    dlib::shape_predictor shape_predictor;
    face_recognition_dnn_type face_recognition_dnn;

    Initialization_flags initialization_flags;

private:
    void run() override;

public:
    explicit Image_handler_initializer(Initialization_flags some_initialization_flags = Initialization_flags::All, QObject* parent = nullptr);
    ~Image_handler_initializer() override;

signals:
    void hog_face_detector_ready(hog_face_detector_type& some_hog_face_detector);
    void cnn_face_detector_ready(cnn_face_detector_type& some_cnn_face_detector);
    void shape_predictor_ready(dlib::shape_predictor& some_shape_predictor);
    void face_recognition_dnn_ready(face_recognition_dnn_type& some_face_recognition_dnn);
};

#endif // IMAGE_HANDLER_INITIALIZER_H
