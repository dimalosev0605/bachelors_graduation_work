#ifndef SELECTED_IMGS_H
#define SELECTED_IMGS_H

#include <QAbstractListModel>
#include <QDebug>
#include <QUrl>
#include <QFile>
#include <QFileSystemWatcher>
#include <QDir>

class Selected_imgs: public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int curr_img_index READ get_curr_img_index WRITE set_curr_img_index NOTIFY curr_img_index_changed)
    int curr_img_index = -1;

    QHash<int, QByteArray> roles;
    QVector<QUrl> model_data;
    QUrl curr_img;
    QFileSystemWatcher file_system_watcher;

private:
    QHash<int, QByteArray> roleNames() const override;

private slots:
    void file_changed_slot(const QString& some_file);

public:
    enum class RolesNames {
        img_file_path = Qt::UserRole,
        img_file_name
    };

    explicit Selected_imgs(QObject* parent = nullptr);

    virtual int rowCount(const QModelIndex &index = QModelIndex()) const override;
    virtual QVariant data(const QModelIndex& index, int role) const override;

public slots:
    void accept_images(const QList<QUrl>& urls);
    void delete_image(const int index);
    QVector<QString> get_selected_imgs_paths() const;

    int get_curr_img_index() const;
    void set_curr_img_index(const int some_index);

signals:
    void image_changed(const QString& curr_img_path);
    void curr_img_index_changed();
};

#endif // SELECTED_IMGS_H
