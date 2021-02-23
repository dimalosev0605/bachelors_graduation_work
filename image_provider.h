#ifndef IMAGE_PROVIDER_H
#define IMAGE_PROVIDER_H

#include <QQuickImageProvider>
#include <QDebug>

#include "image_data.h"

class Image_provider : public QObject, public QQuickImageProvider
{
    Q_OBJECT
    QImage img;
    bool is_show_images = true;

public:
    explicit Image_provider(QObject *parent = nullptr);
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;

public slots:
    void accept_image_data(const Image_data& some_img_data);
    void accept_image(const QImage& some_img);
    void empty_image();
    bool is_null() const;
    void stop_video_running();
    void start_video_running();
};

#endif // IMAGE_PROVIDER_H
