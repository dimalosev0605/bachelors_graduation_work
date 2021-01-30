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
    Q_PROPERTY(int is_checked_counter READ get_is_checked_counter WRITE set_is_checked_counter NOTIFY is_checked_counter_changed)
    int is_checked_counter = 0;

    QHash<int, QByteArray> roles;
    QVector<std::tuple<QString, QString, int, bool>> model_data; // individual name, avatar path, count of faces, is checked
    std::unique_ptr<QVector<std::tuple<QString, QString, int, bool>>> copy_model_data = nullptr;
    Dir_paths dir_paths;

private:
    QHash<int, QByteArray> roleNames() const override;
    void load_all_people();

public:
    enum class RolesNames {
        individual_name = Qt::UserRole,
        avatar_path,
        count_of_faces,
        is_checked
    };
    explicit All_people(QObject* parent = nullptr);
    virtual int rowCount(const QModelIndex& index = QModelIndex()) const override;
    virtual QVariant data(const QModelIndex& index, int role) const override;

    int get_is_checked_counter() const;
    void set_is_checked_counter(const int some_value);

public slots:
    void delete_individual(const int some_index);
    void search(const QString& some_input);
    void cancel_search();
    void update();
    QString get_individual_name(const int some_index) const;
    void set_is_checked(const int some_index, const bool some_value);

signals:
    void is_checked_counter_changed();
};

#endif // ALL_PEOPLE_H
