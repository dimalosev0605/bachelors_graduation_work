#include "selected_imgs.h"

Selected_imgs::Selected_imgs(QObject* parent)
    : QAbstractListModel(parent)
{
    roles[static_cast<int>(RolesNames::img_file_path)] = "img_file_path";
    roles[static_cast<int>(RolesNames::img_file_name)] = "img_file_name";

    connect(&file_system_watcher, &QFileSystemWatcher::fileChanged, this, &Selected_imgs::file_changed_slot);
}

int Selected_imgs::rowCount([[maybe_unused]]const QModelIndex& index) const
{
    return model_data.size();
}

QVariant Selected_imgs::data(const QModelIndex& index, int role) const
{
    const int row = index.row();
    if(row < 0 || row >= model_data.size()) return QVariant{};

    switch (role) {
    case static_cast<int>(RolesNames::img_file_path): {
        return model_data[row].url();
    }

    case static_cast<int>(RolesNames::img_file_name): {
        return model_data[row].fileName();
    }
    }

    return QVariant{};
}

void Selected_imgs::accept_images(const QList<QUrl>& urls)
{
    if(urls.isEmpty()) return;

    QVector<QUrl> new_imgs;
    for(const auto& i : urls) {
        if(!model_data.contains(i)) {
            new_imgs.push_back(i);
            file_system_watcher.addPath(i.path());
        }
    }

    if(!new_imgs.empty()) {
        model_data.reserve(model_data.size() + new_imgs.size());
        beginInsertRows(QModelIndex(), model_data.size(), model_data.size() + new_imgs.size() - 1);
        std::move(new_imgs.begin(), new_imgs.end(), std::back_inserter(model_data));
        endInsertRows();
    }
}

void Selected_imgs::file_changed_slot(const QString& some_file)
{
    const int index = model_data.indexOf("file://" + some_file);

    if(index != -1) {
        beginRemoveRows(QModelIndex(), index, index);
        model_data.removeAt(index);
        endRemoveRows();
    }
}

void Selected_imgs::delete_image(const int index)
{
    if(index < 0 || index >= model_data.size()) return;
    beginRemoveRows(QModelIndex(), index, index);
    file_system_watcher.removePath(model_data[index].path());
    model_data.removeAt(index);
    endRemoveRows();
    if(index == 0) {
        set_curr_img_index(0);
        return;
    }
    if(index <= curr_img_index) {
        set_curr_img_index(curr_img_index - 1);
    }
}

QHash<int, QByteArray> Selected_imgs::roleNames() const
{
    return roles;
}

int Selected_imgs::get_curr_img_index() const
{
    return curr_img_index;
}

void Selected_imgs::set_curr_img_index(const int some_index)
{
    if(some_index < 0 || some_index >= model_data.size()) return;
    curr_img_index = some_index;
    curr_img = model_data[curr_img_index];
    emit curr_img_index_changed();
    emit image_changed(curr_img.path());
}

QVector<QString> Selected_imgs::get_selected_imgs_paths() const
{
    QVector<QString> res;
    res.reserve(model_data.size());

    for(const auto& elem : model_data) {
        res.push_back(elem.path());
    }

    return res;
}

