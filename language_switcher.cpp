#include "language_switcher.h"

Language_switcher::Language_switcher(QQmlApplicationEngine &some_engine, QObject *parent)
    : QObject(parent),
      engine(some_engine)
{
    translator = new QTranslator(this);
    QSettings settings("app_settings.ini", QSettings::IniFormat);
    language = settings.value("Language/Language").toString();
    qDebug() << "language = " << language;

    install_translator(language);
}

void Language_switcher::change_language(const QString &some_language)
{
    install_translator(some_language, true);
}

QString Language_switcher::get_language() const
{
    return language;
}

void Language_switcher::install_translator(const QString& some_language, bool is_retranslate)
{
    QString qm_file;
    if(some_language == "English") {
        qm_file = "app_en.qm";
    } else if(some_language == "Russian") {
        qm_file = "app_ru.qm";
    }
    else {
        qm_file = "app_fr.qm";
    }

    if(translator->load(qm_file)) {
        if(QCoreApplication::installTranslator(translator)) {
            if(is_retranslate) {
                engine.retranslate();
                language = some_language;
                QSettings settings("app_settings.ini", QSettings::IniFormat);
                settings.setValue("Language/Language", language);
            }
        }
        else {
            qDebug() << " translator was not installed.";
        }
    }
    else {
        qDebug() << qm_file << " was not loaded.";
    }
}

