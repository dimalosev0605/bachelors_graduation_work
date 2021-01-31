#ifndef ALL_PEOPLE_H
#define ALL_PEOPLE_H

#include <QObject>
#include <QDebug>
#include <QAbstractListModel>
#include <QDir>

#include "../file_system/dir_paths.h"

class All_people: public QAbstractListModel
{
    Q_OBJECT

    QHash<int, QByteArray> roles;
    QVector<std::tuple<QString, QString, int>> model_data; // individual name, avatar path, count of faces
    std::unique_ptr<QVector<std::tuple<QString, QString, int>>> copy_model_data = nullptr;
    Dir_paths dir_paths;

private:
    QHash<int, QByteArray> roleNames() const override;
    void load_all_people();

public:
    enum class RolesNames {
        individual_name = Qt::UserRole,
        avatar_path,
        count_of_faces
    };
    explicit All_people(QObject* parent = nullptr);
    virtual int rowCount(const QModelIndex& index = QModelIndex()) const override;
    virtual QVariant data(const QModelIndex& index, int role) const override;

public slots:
    void delete_individual(const int some_index);
    void search(const QString& some_input);
    void cancel_search();
    void update();
    QString get_individual_name(const int some_index) const;
    std::tuple<QString, QString, int> delete_item(const int some_index);
    void add_item(const std::tuple<QString, QString, int>& some_item);
};

#endif // ALL_PEOPLE_H
