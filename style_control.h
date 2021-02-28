#ifndef STYLE_CONTROL_H
#define STYLE_CONTROL_H

#include <QObject>
#include <QtQuickControls2/QQuickStyle>
#include <QSettings>
#include <QDebug>
#include <QProcess>
#include <QGuiApplication>

class Style_control : public QObject
{
    Q_OBJECT
    QGuiApplication& app;

    QString style;

    QString default_style = "Default";
    QString material_style = "Material";
    QString universal_style = "Universal";

    enum class Theme {
        Light = 0,
        Dark = 1
    };
    Q_PROPERTY(bool is_dark_mode_on READ get_is_dark_mode_on WRITE set_is_dark_mode_on NOTIFY is_dark_mode_on_changed)
    Theme theme;
    bool is_dark_mode_on;

public:
    explicit Style_control(QGuiApplication& app, QObject *parent = nullptr);

    bool get_is_dark_mode_on() const;
    void set_is_dark_mode_on(const bool some_value);

public slots:
    void change_style(const QString& some_style);
    QString get_style() const;

signals:
    void is_dark_mode_on_changed();

};

#endif // STYLE_CONTROL_H
