#ifndef INDIVIDUAL_FILE_MANAGER_H
#define INDIVIDUAL_FILE_MANAGER_H

#include <QDir>

#include "dir_paths.h"

class Individual_file_manager
{
    Dir_paths dir_paths;
    QString name;
    QString dir_path;
    QString sources_path;
    QString extracted_faces_path;

private:
    void set_individual_dirs_paths();

public:
    explicit Individual_file_manager(const QString& some_individual_name = QString());

    void set_individual_name(const QString& some_name);
    QString get_individual_name() const;

    bool check_individual_existence() const;
    bool check_individual_existence(const QString& some_name) const;

    bool create_individual_dirs() const;
    bool delete_individual_dirs() const;

//    QString get_path_to_extracted_faces_dir() const;
//    QString get_path_to_sources_dir() const;
};

#endif // INDIVIDUAL_FILE_MANAGER_H
