#ifndef BASE_PEOPLE_H
#define BASE_PEOPLE_H

#include <QObject>
#include <QDebug>
#include <QAbstractListModel>
#include <QDir>

#include "../file_system/dir_paths.h"

class Base_people: public QAbstractListModel
{
    Q_OBJECT
    QHash<int, QByteArray> roles;

private:
    QHash<int, QByteArray> roleNames() const override;

protected:
    QVector<std::tuple<QString, QString, int>> model_data; // individual name, avatar path, count of faces
    std::unique_ptr<QVector<std::tuple<QString, QString, int>>> copy_model_data = nullptr;
    Dir_paths dir_paths;

protected:
    void load_model_data();

public:
    enum class RolesNames {
        individual_name = Qt::UserRole,
        avatar_path,
        count_of_faces
    };
    explicit Base_people(QObject* parent = nullptr);
    virtual int rowCount(const QModelIndex& index = QModelIndex()) const override;
    virtual QVariant data(const QModelIndex& index, int role) const override;

public slots:
    void search(const QString& some_input);
    void cancel_search();
    void update();
    std::tuple<QString, QString, int> delete_item(const int some_index);
    void add_item(const std::tuple<QString, QString, int>& some_item);
};

#endif // BASE_PEOPLE_H
