#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "file_system/default_dir_creator.h"
#include "file_system/individual_checker.h"
#include "file_system/individual_file_manager.h"

#include "models/selected_imgs.h"
#include "models/available_people.h"
#include "models/selected_people.h"

#include "image_data.h"
#include "image_provider.h"
#include "image_handler.h"
#include "auto_image_handler.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    app.setOrganizationName("lol");
    app.setOrganizationDomain("kek");

    qmlRegisterType<Default_dir_creator>("Default_dir_creator_qml", 1, 0, "Default_dir_creator");
    qmlRegisterType<Individual_checker>("Individual_checker_qml", 1, 0, "Individual_checker");
    qmlRegisterType<Individual_file_manager>("Individual_file_manager_qml", 1, 0, "Individual_file_manager");

    qmlRegisterType<Selected_imgs>("Selected_imgs_qml", 1, 0, "Selected_imgs");
    qmlRegisterType<Available_people>("Available_people_qml", 1, 0, "Available_people");
    qmlRegisterType<Selected_people>("Selected_people_qml", 1, 0, "Selected_people");


    qmlRegisterType<Image_handler>("Image_handler_qml", 1, 0, "Image_handler");
    qmlRegisterType<Auto_image_handler>("Auto_image_handler_qml", 1, 0, "Auto_image_handler");

    qRegisterMetaType<Image_data>("Image_data");

    qRegisterMetaType<dlib::shape_predictor>("dlib::shape_predictor");
    qRegisterMetaType<dlib::shape_predictor>("dlib::shape_predictor&");

    qRegisterMetaType<hog_face_detector_type>("hog_face_detector_type");
    qRegisterMetaType<hog_face_detector_type>("hog_face_detector_type&");

    qRegisterMetaType<cnn_face_detector_type>("cnn_face_detector_type");
    qRegisterMetaType<cnn_face_detector_type>("cnn_face_detector_type&");

    qRegisterMetaType<face_recognition_dnn_type>("face_recognition_dnn_type");
    qRegisterMetaType<face_recognition_dnn_type>("face_recognition_dnn_type&");

    qRegisterMetaType<dlib::matrix<dlib::rgb_pixel>>("dlib::matrix<dlib::rgb_pixel>");
    qRegisterMetaType<dlib::matrix<dlib::rgb_pixel>>("dlib::matrix<dlib::rgb_pixel>&");

    qRegisterMetaType<std::vector<dlib::rectangle>>("std::vector<dlib::rectangle>");
    qRegisterMetaType<std::vector<dlib::rectangle>>("std::vector<dlib::rectangle>&");

    qRegisterMetaType<std::vector<std::tuple<dlib::matrix<dlib::rgb_pixel>, dlib::matrix<dlib::rgb_pixel>>>>("std::vector<std::tuple<dlib::matrix<dlib::rgb_pixel>, dlib::matrix<dlib::rgb_pixel>>>");
    qRegisterMetaType<std::vector<std::tuple<dlib::matrix<dlib::rgb_pixel>, dlib::matrix<dlib::rgb_pixel>>>>("std::vector<std::tuple<dlib::matrix<dlib::rgb_pixel>, dlib::matrix<dlib::rgb_pixel>>>&");

    qRegisterMetaType<std::tuple<QString, QString, int>>("std::tuple<QString, QString, int>");
    qRegisterMetaType<std::tuple<QString, QString, int>>("std::tuple<QString, QString, int>&");

    qRegisterMetaType<QVector<std::tuple<QString, QString, int>>>("QVector<std::tuple<QString, QString, int>>");
    qRegisterMetaType<QVector<std::tuple<QString, QString, int>>>("QVector<std::tuple<QString, QString, int>>&");

    Image_provider* image_provider = new Image_provider;
    engine.rootContext()->setContextProperty("Image_provider", image_provider);
    engine.addImageProvider("Image_provider", image_provider);

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
