#include "selected_imgs.h"

Selected_imgs::Selected_imgs(QObject* parent)
    : QAbstractListModel(parent)
{
    roles[static_cast<int>(RolesNames::img_file_path)] = "img_file_path";
    roles[static_cast<int>(RolesNames::img_file_name)] = "img_file_name";
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
        }
    }

    if(!new_imgs.empty()) {
        model_data.reserve(model_data.size() + new_imgs.size());
        beginInsertRows(QModelIndex(), model_data.size(), model_data.size() + new_imgs.size() - 1);
        std::move(new_imgs.begin(), new_imgs.end(), std::back_inserter(model_data));
        endInsertRows();
    }
}

void Selected_imgs::delete_image(const int index)
{
    if(index < 0 || index >= model_data.size()) return;
    beginRemoveRows(QModelIndex(), index, index);
    model_data.removeAt(index);
    endRemoveRows();
}

void Selected_imgs::clear()
{
    if(!model_data.isEmpty()) {
        beginRemoveRows(QModelIndex(), 0, model_data.size() - 1);
        model_data.clear();
        endRemoveRows();
    }
}

QHash<int, QByteArray> Selected_imgs::roleNames() const
{
    return roles;
}
