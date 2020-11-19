#ifndef DIR_PATHS_H
#define DIR_PATHS_H

#include <QCoreApplication>

#include "dir_names.h"

class Dir_paths {
    const QString m_app = QCoreApplication::applicationDirPath();
    const QString m_app_data = m_app + '/' + Dir_names::app_data;
    const QString m_people = m_app_data + '/' + Dir_names::people;

public:
    QString app() const;
    QString app_data() const;
    QString people() const;
};


#endif // DIR_PATHS_H
