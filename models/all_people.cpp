#include "all_people.h"

All_people::All_people(QObject* parent)
    : QAbstractListModel(parent)
{
    roles[static_cast<int>(RolesNames::individual_name)] = "individual_name";
    roles[static_cast<int>(RolesNames::avatar_path)] = "avatar_path";
    roles[static_cast<int>(RolesNames::count_of_faces)] = "count_of_faces";
    load_all_people();
}

QHash<int, QByteArray> All_people::roleNames() const
{
    return roles;
}


int All_people::rowCount([[maybe_unused]]const QModelIndex& index) const
{
    return model_data.size();
}

QVariant All_people::data(const QModelIndex& index, int role) const
{
    const int row = index.row();
    if(row < 0 || row >= model_data.size()) return QVariant{};

    switch (role) {
    case static_cast<int>(RolesNames::individual_name): {
        return std::get<0>(model_data[row]);
    }

    case static_cast<int>(RolesNames::avatar_path): {
        return std::get<1>(model_data[row]);
    }

    case static_cast<int>(RolesNames::count_of_faces): {
        return std::get<2>(model_data[row]);
    }

    }

    return QVariant{};
}

void All_people::load_all_people()
{
    QDir all_people_dir(dir_paths.people());
    all_people_dir.setFilter(QDir::Dirs | QDir::NoDot | QDir::NoDotDot);
    const auto all_people_dirs_list = all_people_dir.entryList();

    for(const auto& dir: all_people_dirs_list) {
        const QString individual_name = dir;

        QDir extracted_faces_individual_dir(dir_paths.people() + '/' + individual_name + '/' + Dir_names::Individual::extracted_faces);
        extracted_faces_individual_dir.setFilter(QDir::Files | QDir::NoDot | QDir::NoDotDot);

        const auto count_of_faces = extracted_faces_individual_dir.count();

        const auto extracted_faces_images_list = extracted_faces_individual_dir.entryInfoList();
        if(!extracted_faces_images_list.empty()) {
            const QString avatar_path = extracted_faces_images_list.first().filePath();
//            qDebug() << individual_name << " - " << avatar_path << " - " << count_of_faces;
            model_data.push_back(std::tuple<QString, QString, int>(individual_name, avatar_path, count_of_faces));
        }
        else {
            qDebug() << "skip individual, no extracted faces.";
        }
    }
}

void All_people::delete_individual(const int some_index)
{
    if(some_index < 0 || some_index >= model_data.size()) return;
    QDir dir(dir_paths.people() + '/' + std::get<0>(model_data[some_index]));
    if(dir.removeRecursively()) {
        beginRemoveRows(QModelIndex(), some_index, some_index);
        model_data.removeAt(some_index);
        endRemoveRows();
    }
}



