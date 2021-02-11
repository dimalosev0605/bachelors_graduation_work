#ifndef JANITOR_H
#define JANITOR_H

#include <QObject>
#include <QDir>
#include <QDebug>

#include "dir_paths.h"

class Janitor : public QObject
{
    Q_OBJECT

public:
    explicit Janitor(QObject *parent = nullptr);

public slots:
    void clean();

signals:

};

#endif // JANITOR_H
