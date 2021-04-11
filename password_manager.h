#ifndef PASSWORD_MANAGER_H
#define PASSWORD_MANAGER_H

#include <QObject>
#include <QDebug>
#include <QSettings>
#include <QCryptographicHash>
#include <QUuid>

class Password_manager : public QObject
{
    Q_OBJECT
    bool is_set;
    QString saved_password;

public:
    explicit Password_manager(QObject *parent = nullptr);

public slots:
    void set_password(const QString& some_password);
    bool disable_password_at_startup(const QString& some_password);
    bool is_password_set() const;
    bool check_password(const QString& some_password);

signals:
    void message(const QString& some_message);
};

#endif // PASSWORD_MANAGER_H
