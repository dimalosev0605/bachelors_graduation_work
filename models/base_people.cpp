#include "base_people.h"

Base_people::Base_people(QObject* parent)
    : QAbstractListModel(parent)
{
    roles[static_cast<int>(RolesNames::individual_name)] = "individual_name";
    roles[static_cast<int>(RolesNames::avatar_path)] = "avatar_path";
    roles[static_cast<int>(RolesNames::count_of_faces)] = "count_of_faces";
}

QHash<int, QByteArray> Base_people::roleNames() const
{
    return roles;
}

void Base_people::load_model_data()
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
            model_data.push_back(std::tuple<QString, QString, int>(individual_name, avatar_path, count_of_faces));
        }
        else {
            qDebug() << "skip individual, no extracted faces.";
        }
    }
}

int Base_people::rowCount([[maybe_unused]]const QModelIndex& index) const
{
    return model_data.size();
}

QVariant Base_people::data(const QModelIndex& index, int role) const
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

void Base_people::search(const QString& some_input)
{
    if(some_input.isEmpty()) return;

    if(copy_model_data == nullptr) {
        copy_model_data = std::unique_ptr<QVector<std::tuple<QString, QString, int>>>(new QVector<std::tuple<QString, QString, int>>(model_data));
    }

    QVector<std::tuple<QString, QString, int>> res;
    for(int i = 0; i < copy_model_data->size(); ++i) {
        if(std::get<0>(copy_model_data->operator[](i)).contains(some_input)) {
            QString bold_str = std::get<0>(copy_model_data->operator[](i));
            bold_str = bold_str.replace(some_input, "<b>" + some_input + "</b>");
            res.push_back(std::make_tuple(bold_str, std::get<1>(copy_model_data->operator[](i)), std::get<2>(copy_model_data->operator[](i))));
        }
    }

    beginResetModel();
    model_data = std::move(res);
    endResetModel();
}

void Base_people::cancel_search()
{
    if(copy_model_data == nullptr) return;
    beginResetModel();
    model_data = *copy_model_data;
    endResetModel();
}

void Base_people::update()
{
    beginResetModel();
    copy_model_data = nullptr;
    model_data.clear();
    endResetModel();
}

std::tuple<QString, QString, int> Base_people::delete_item(const int some_index)
{
    if(some_index < 0 || some_index >= model_data.size()) return std::tuple<QString, QString, int>{};

    auto name = std::get<0>(model_data[some_index]);
    name = name.remove("<b>").remove("</b>");

    if(copy_model_data != nullptr) {
        for(int i = 0; i < copy_model_data->size(); ++i) {
            if(name == std::get<0>(copy_model_data->operator[](i))) {
                copy_model_data->removeAt(i);
                break;
            }
        }
    }

    auto res = model_data[some_index];
    std::get<0>(res) = std::get<0>(res).remove("<b>").remove("</b>");

    beginRemoveRows(QModelIndex(), some_index, some_index);
    model_data.removeAt(some_index);
    endRemoveRows();

    return res;
}

void Base_people::add_item(const std::tuple<QString, QString, int>& some_item)
{
    if(some_item == std::tuple<QString, QString, int>{}) return;
    beginInsertRows(QModelIndex(), model_data.size(), model_data.size());
    model_data.push_back(some_item);
    if(copy_model_data != nullptr) {
        copy_model_data->push_back(some_item);
    }
    endInsertRows();
}
