#include "janitor.h"

Janitor::Janitor(QObject *parent) : QObject(parent)
{
    clean();
}

void Janitor::clean()
{
    Dir_paths dir_paths;
    QDir all_people_dir(dir_paths.people());
    all_people_dir.setFilter(QDir::Dirs | QDir::NoDot | QDir::NoDotDot);
    const auto all_people_dirs_list = all_people_dir.entryList();

    for(const auto& dir: all_people_dirs_list) {
        const QString individual_name = dir;

        QDir extracted_faces_individual_dir(dir_paths.people() + '/' + individual_name + '/' + Dir_names::Individual::extracted_faces);
        extracted_faces_individual_dir.setFilter(QDir::Files | QDir::NoDot | QDir::NoDotDot);

        QDir source_imgs_dir(dir_paths.people() + '/' + individual_name + '/' + Dir_names::Individual::sources);
        source_imgs_dir.setFilter(QDir::Files | QDir::NoDot  | QDir::NoDotDot);

        if(extracted_faces_individual_dir.isEmpty() || source_imgs_dir.isEmpty()) {
            all_people_dir.setPath(dir_paths.people() + '/' + individual_name);
            all_people_dir.removeRecursively();
            continue;
        }

        QSet<QString> extr_set;
        auto extr_list = extracted_faces_individual_dir.entryList();
        for(int i = 0; i < extr_list.size(); ++i) {
            QString temp = extr_list[i].remove(Dir_names::Individual::Img_file_names::extracted_face + '_');
            extr_set.insert(temp);
        }

        auto src_list = source_imgs_dir.entryList();
        QSet<QString> src_set;
        for(int i = 0; i < src_list.size(); ++i) {
            QString temp = src_list[i].remove(Dir_names::Individual::Img_file_names::source + '_');
            src_set.insert(temp);
        }

        if(extr_set != src_set) {
            auto set_1 = extr_set - src_set;
            auto set_2 = src_set - extr_set;

            QFile file;
            for(const auto& i : set_1) {
                QString file_name = dir_paths.people() + '/' + individual_name + '/' + Dir_names::Individual::extracted_faces + '/' + Dir_names::Individual::Img_file_names::extracted_face + '_' + i;
                file.remove(file_name);
            }
            for(const auto& i : set_2) {
                QString file_name = dir_paths.people() + '/' + individual_name + '/' + Dir_names::Individual::sources + '/' + Dir_names::Individual::Img_file_names::source + '_' + i;
                file.remove(file_name);
            }
        }
    }
}
