#ifndef DEFAULT_DIR_CREATOR_H
#define DEFAULT_DIR_CREATOR_H

#include <QCoreApplication>
#include <QDir>
#include <QObject>
#include <QDebug>
#include <QTimer>

#include "dir_paths.h"

class Default_dir_creator: public QObject
{
    Q_OBJECT
    Dir_paths dir_paths;

private slots:
    void close_app();

public:
    explicit Default_dir_creator(QObject* parent = nullptr);

public slots:
    void create_default_dirs() const;

signals:
    void message(const QString& message_str) const;
};

#endif // DEFAULT_DIR_CREATOR_H
