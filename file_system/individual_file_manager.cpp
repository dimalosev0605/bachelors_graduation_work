#include "individual_file_manager.h"

Individual_file_manager::Individual_file_manager(QObject* parent)
    : QAbstractListModel(parent)
{
    roles[static_cast<int>(RolesNames::src_img_path)] = "src_img_path";
    roles[static_cast<int>(RolesNames::extr_face_img_path)] = "extr_face_img_path";
}

int Individual_file_manager::rowCount([[maybe_unused]]const QModelIndex& index) const
{
    return model_data.size();
}

QVariant Individual_file_manager::data(const QModelIndex& index, int role) const
{
    const int row = index.row();
    if(row < 0 || row >= model_data.size()) return QVariant{};

    switch (role) {
    case static_cast<int>(RolesNames::src_img_path): {
        return std::get<0>(model_data[row]);
    }

    case static_cast<int>(RolesNames::extr_face_img_path): {
        return std::get<1>(model_data[row]);
    }

    }

    return QVariant{};
}

void Individual_file_manager::set_individual_name(const QString& some_name, const bool is_load_data)
{
    name = some_name;
    set_individual_dirs_paths();
    if(is_load_data) {
        QDir sources_dir(sources_path);
        sources_dir.setFilter(QDir::Files | QDir::NoDot | QDir::NoDotDot);
        sources_dir.setSorting(QDir::Name);
        const auto sources = sources_dir.entryInfoList();

        QDir extracted_dir(extracted_faces_path);
        extracted_dir.setFilter(QDir::Files | QDir::NoDot | QDir::NoDotDot);
        extracted_dir.setSorting(QDir::Name);
        const auto extracted_faces = extracted_dir.entryInfoList();

        if(sources.size() != extracted_faces.size()) {
            qDebug() << "pizda";
            return;
        }
        QVector<std::tuple<QString, QString>> loaded_data;
        for(int i = 0; i < sources.size(); ++i) {
            const auto source_path = sources[i].filePath();
            const auto extracted_face_path = extracted_faces[i].filePath();
            loaded_data.push_back(std::tuple<QString, QString>(source_path, extracted_face_path));
        }
        beginResetModel();
        model_data = std::move(loaded_data);
        endResetModel();
    }
}

QHash<int, QByteArray> Individual_file_manager::roleNames() const
{
    return roles;
}

void Individual_file_manager::set_individual_dirs_paths()
{
    dir_path = dir_paths.people() + '/' + name;
    sources_path = dir_path + '/' + Dir_names::Individual::sources;
    extracted_faces_path = dir_path + '/' + Dir_names::Individual::extracted_faces;
}

bool Individual_file_manager::add_face(const Image_data& some_src_img_data, const Image_data& some_extr_face_img_data)
{
    const QImage src_img(static_cast<const uchar*>(some_src_img_data.get_data()),
                          static_cast<int>(some_src_img_data.get_nc()),
                          static_cast<int>(some_src_img_data.get_nr()),
                          some_src_img_data.get_bytes_per_pixel() * static_cast<int>(some_src_img_data.get_nc()),
                          QImage::Format_RGB888);

    const QImage extr_face_img(static_cast<const uchar*>(some_extr_face_img_data.get_data()),
                               static_cast<int>(some_extr_face_img_data.get_nc()),
                               static_cast<int>(some_extr_face_img_data.get_nr()),
                               some_extr_face_img_data.get_bytes_per_pixel() * static_cast<int>(some_extr_face_img_data.get_nc()),
                               QImage::Format_RGB888);

    QDir src_dir(sources_path);
    QString src_file_name = sources_path + '/' + Dir_names::Individual::Img_file_names::source + '_' + QString::number(src_dir.count()) + Dir_names::Individual::Img_file_names::img_extension;
    QString extr_face_file_name = extracted_faces_path + '/' + Dir_names::Individual::Img_file_names::extracted_face + '_' + QString::number(src_dir.count()) + Dir_names::Individual::Img_file_names::img_extension;

    if(src_img.save(src_file_name) && extr_face_img.save(extr_face_file_name)) {
        beginInsertRows(QModelIndex(), model_data.size(), model_data.size());
        model_data.push_back(std::tuple<QString, QString>(src_file_name, extr_face_file_name));
        endInsertRows();
        return true;
    }
    else {
        qDebug() << "Save error.";
        QFile file;
        file.remove(src_file_name);
        file.remove(extr_face_file_name);
        return false;
    }
}

void Individual_file_manager::delete_face(const int index)
{
    if(index < 0 || index > model_data.size()) return;

    QFile src_img_file;
    QFile extr_face_img_file;

    if(src_img_file.remove(std::get<0>(model_data[index])) && extr_face_img_file.remove(std::get<1>(model_data[index]))) {
        beginRemoveRows(QModelIndex(), index, index);
        model_data.removeAt(index);
        endRemoveRows();
    }
    else {
        qDebug() << "Deletion error.";
    }
}

void Individual_file_manager::delete_all_faces()
{
    QFile src_img_file;
    QFile extr_face_img_file;
    for(int i = 0; i < model_data.size(); ++i) {
        src_img_file.remove(std::get<0>(model_data[i]));
        extr_face_img_file.remove(std::get<1>(model_data[i]));
    }
    beginResetModel();
    model_data.clear();
    endResetModel();
}

bool Individual_file_manager::delete_individual()
{
    if(dir_path.isEmpty()) return false;
    QDir dir(dir_path);
    return dir.removeRecursively();
}
