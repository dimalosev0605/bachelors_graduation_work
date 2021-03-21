#ifndef INDIVIDUAL_FILE_MANAGER_H
#define INDIVIDUAL_FILE_MANAGER_H

#include <QDir>
#include <QDebug>
#include <QAbstractListModel>
#include <QImage>
#include <QDateTime>

#include "dlib/matrix.h"
#include "dlib/serialize.h"

#include "dir_paths.h"
#include "image_data.h"

class Individual_file_manager: public QAbstractListModel
{
    Q_OBJECT

    Dir_paths dir_paths;
    QString name;
    QString dir_path;
    QString sources_path;
    QString extracted_faces_path;
    QString face_descriptors_path;

    QHash<int, QByteArray> roles;
    QVector<std::tuple<QString, QString, QString>> model_data; // 1 string - src img. path, 2 string - extr. face img. path, 3 string - face descriptor path.

private:
    QHash<int, QByteArray> roleNames() const override;
    void set_individual_dirs_paths();

public:
    enum class RolesNames {
        src_img_path = Qt::UserRole,
        extr_face_img_path
    };
    explicit Individual_file_manager(QObject* parent = nullptr);
    virtual int rowCount(const QModelIndex &index = QModelIndex()) const override;
    virtual QVariant data(const QModelIndex& index, int role) const override;

public slots:
    void set_individual_name(const QString& some_name, const bool is_load_data = false);
    bool add_face(const Image_data& some_src_img_data, const Image_data& some_extr_face_img_data, const dlib::matrix<float, 0, 1>& some_face_descriptor);
    bool delete_face(const int index);
    void delete_all_faces();
    bool delete_individual();
    bool rename(const QString& some_name);
};

#endif // INDIVIDUAL_FILE_MANAGER_H
