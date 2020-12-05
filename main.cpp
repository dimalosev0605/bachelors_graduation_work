#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "file_system/default_dir_creator.h"
#include "file_system/individual_checker.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    app.setOrganizationName("lol");
    app.setOrganizationDomain("kek");

    qmlRegisterType<Default_dir_creator>("Default_dir_creator_qml", 1, 0, "Default_dir_creator");
    qmlRegisterType<Individual_checker>("Individual_checker_qml", 1, 0, "Individual_checker");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
