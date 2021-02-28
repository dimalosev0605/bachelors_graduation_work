#include "style_control.h"

Style_control::Style_control(QGuiApplication& some_app, QObject *parent)
    : QObject(parent),
      app(some_app)
{
    QSettings settings("app_settings.ini", QSettings::IniFormat);
    style = settings.value("Controls/Style").toString();
    qDebug() << "style = " << style;
    QQuickStyle::setStyle(style);

    if(style == material_style) {
        theme = static_cast<Theme>(settings.value(material_style + "/" + "Theme").toInt());
        is_dark_mode_on = (theme == Theme::Dark) ? true : false;
    }
    if(style == universal_style) {
        theme = static_cast<Theme>(settings.value(universal_style + "/" + "Theme").toInt());
        is_dark_mode_on = (theme == Theme::Dark) ? true : false;
    }
}

void Style_control::change_style(const QString& some_style)
{
    {
        QSettings settings("app_settings.ini", QSettings::IniFormat);
        settings.setValue("Controls/Style", some_style);
    }
    qDebug() << "app.arguments():" << app.arguments();
    QProcess::startDetached(app.arguments()[0], app.arguments());
    app.quit();
}

QString Style_control::get_style() const
{
    return style;
}

bool Style_control::get_is_dark_mode_on() const
{
    return is_dark_mode_on;
}

void Style_control::set_is_dark_mode_on(const bool some_value)
{
    QSettings settings("app_settings.ini", QSettings::IniFormat);
    is_dark_mode_on = some_value;
    theme = is_dark_mode_on ? Theme::Dark : Theme::Light;
    settings.setValue(style + "/" + "Theme", static_cast<int>(theme));
    emit is_dark_mode_on_changed();
}
