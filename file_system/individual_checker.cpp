#include "individual_checker.h"

Individual_checker::Individual_checker(QObject* parent)
    : QObject(parent)
{}

void Individual_checker::set_individual_dirs_paths()
{
    dir_path = dir_paths.people() + '/' + name;
    sources_path = dir_path + '/' + Dir_names::Individual::sources;
    extracted_faces_path = dir_path + '/' + Dir_names::Individual::extracted_faces;
}

bool Individual_checker::check_individual_existence(const QString& some_name) const
{
    QDir dir(dir_paths.people());
    if(dir.exists(some_name)) {
        emit message(QString("\"%1\" already exists.").arg(some_name));
        return true;
    }
    else {
        return false;
    }
}

void Individual_checker::set_individual_name(const QString& some_name)
{
    name = some_name;
    set_individual_dirs_paths();
}

bool Individual_checker::create_individual_dirs() const
{
    if(name.isEmpty()) return false;
    QDir dir(dir_paths.people());
    if(dir.mkdir(name)) {
        if(dir.mkdir(sources_path) && dir.mkdir(extracted_faces_path)) {
            emit message(QString("\"%1\" was created!").arg(name));
            return true;
        }
        else {
            dir.setPath(dir_path);
            dir.removeRecursively();
            emit message(QString("Unable to create necessary directories for \"%1\".").arg(name));
            return false;
        }
    }
    else {
        emit message(QString("Unable to create necessary directories for \"%1\".").arg(name));
        return false;
    }
}

bool Individual_checker::delete_individual_dirs() const
{
    if(name.isEmpty()) return false;
    QDir dir(dir_path);
    return dir.removeRecursively();
}
