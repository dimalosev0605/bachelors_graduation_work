#include "individual_file_manager.h"


Individual_file_manager::Individual_file_manager(const QString& some_name)
    : name(some_name)
{
    set_individual_dirs_paths();
}

void Individual_file_manager::set_individual_name(const QString& some_name)
{
    name = some_name;
    set_individual_dirs_paths();
}

void Individual_file_manager::set_individual_dirs_paths()
{
    dir_path = dir_paths.people() + '/' + name;
    sources_path = dir_path + '/' + Dir_names::Individual::sources;
    extracted_faces_path = dir_path + '/' + Dir_names::Individual::extracted_faces;
}

QString Individual_file_manager::get_individual_name() const
{
    return name;
}

bool Individual_file_manager::check_individual_existence() const
{
    if(name.isEmpty()) return false;
    QDir dir(dir_paths.people());
    return dir.exists(name);
}

bool Individual_file_manager::check_individual_existence(const QString& some_name) const
{
    QDir dir(dir_paths.people());
    return dir.exists(some_name);
}

bool Individual_file_manager::create_individual_dirs() const
{
    if(name.isEmpty()) return false;
    QDir dir(dir_paths.people());
    if(dir.mkdir(name)) {
        if(dir.mkdir(sources_path) && dir.mkdir(extracted_faces_path)) {
            return true;
        }
        else {
            dir.setPath(dir_path);
            dir.removeRecursively();
            return false;
        }
    }
    else {
        return false;
    }
}

bool Individual_file_manager::delete_individual_dirs() const
{
    if(name.isEmpty()) return false;
    QDir dir(dir_path);
    return dir.removeRecursively();
}

