#ifndef INDIVIDUAL_CHECKER_H
#define INDIVIDUAL_CHECKER_H

#include <QObject>
#include <QDir>
#include <QDebug>

#include "dir_paths.h"

class Individual_checker : public QObject
{
    Q_OBJECT
    Dir_paths dir_paths;
    QString name;
    QString dir_path;
    QString sources_path;
    QString extracted_faces_path;

private:
    void set_individual_dirs_paths();

public:
    explicit Individual_checker(QObject *parent = nullptr);

public slots:
    bool check_individual_existence(const QString& some_name) const;
    void set_individual_name(const QString& some_name);
    bool create_individual_dirs() const;
    bool delete_individual_dirs() const;

signals:
    void message(const QString& message_str) const;
};

#endif // INDIVIDUAL_CHECKER_H
