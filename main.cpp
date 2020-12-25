#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "file_system/default_dir_creator.h"
#include "file_system/individual_checker.h"

#include "models/selected_imgs.h"

#include "image_data.h"
#include "image_provider.h"
#include "image_handler.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    app.setOrganizationName("lol");
    app.setOrganizationDomain("kek");

    qmlRegisterType<Default_dir_creator>("Default_dir_creator_qml", 1, 0, "Default_dir_creator");
    qmlRegisterType<Individual_checker>("Individual_checker_qml", 1, 0, "Individual_checker");

    qmlRegisterType<Selected_imgs>("Selected_imgs_qml", 1, 0, "Selected_imgs");

    qmlRegisterType<Image_handler>("Image_handler_qml", 1, 0, "Image_handler");

    qRegisterMetaType<Image_data>("Image_data");

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
