#include "password_manager.h"

Password_manager::Password_manager(QObject *parent) : QObject(parent)
{
    QSettings settings("app_settings.ini", QSettings::IniFormat);
    is_set = settings.value("Password/is_set").toString().toInt() == 0 ? false : true;
    if(is_set) {
        saved_password = settings.value("Password/password").toString();
    }
    is_run_on_startup = settings.value("Run_on_startup/flag").toInt() == 0 ? false : true;
}

void Password_manager::set_password(const QString &some_password)
{
    const auto hashed_password = QCryptographicHash::hash(QByteArray(some_password.toStdString().c_str()), QCryptographicHash::Sha512);
    QSettings settings("app_settings.ini", QSettings::IniFormat);
    settings.setValue("Password/password", hashed_password);
    settings.setValue("Password/is_set", 1);
    is_set = true;
    saved_password = hashed_password;
}

bool Password_manager::disable_password_at_startup(const QString& some_password)
{
    QSettings settings("app_settings.ini", QSettings::IniFormat);
    const auto hashed_password = QCryptographicHash::hash(QByteArray(some_password.toStdString().c_str()), QCryptographicHash::Sha512);
    if(saved_password != hashed_password) {
        emit message(tr("Wrong password"));
        return false;
    }
    else {
        is_set = false;
        saved_password = "";
        settings.setValue("Password/password", "");
        settings.setValue("Password/is_set", 0);
        return true;
    }
}

bool Password_manager::is_password_set() const
{
    return is_set;
}

bool Password_manager::check_password(const QString& some_password)
{
    const auto hashed_password = QCryptographicHash::hash(QByteArray(some_password.toStdString().c_str()), QCryptographicHash::Sha512);
    if(saved_password != hashed_password) {
        return false;
    }
    else {
        return true;
    }
}

bool Password_manager::get_run_on_startup() const
{
    return is_run_on_startup;
}

void Password_manager::set_run_on_startup(bool some_value)
{
    is_run_on_startup = some_value;
    QSettings settings("app_settings.ini", QSettings::IniFormat);
    const int value = some_value ? 1 : 0;
    settings.setValue("Run_on_startup/flag", value);
}

