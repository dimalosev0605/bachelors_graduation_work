#ifndef LANGUAGE_SWITCHER_H
#define LANGUAGE_SWITCHER_H

#include <QObject>
#include <QTranslator>
#include <QDebug>
#include <QCoreApplication>
#include <QQmlApplicationEngine>
#include <QSettings>

class Language_switcher : public QObject
{
    Q_OBJECT

    QTranslator* translator;
    QQmlApplicationEngine& engine;
    QString language;

private:
    void install_translator(const QString& some_language, bool is_retranslate = false);

public:
    explicit Language_switcher(QQmlApplicationEngine& some_engine, QObject *parent = nullptr);

public slots:
    void change_language(const QString& some_language);
    QString get_language() const;

signals:

};

#endif // LANGUAGE_SWITCHER_H
