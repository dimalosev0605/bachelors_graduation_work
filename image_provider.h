#ifndef IMAGE_PROVIDER_H
#define IMAGE_PROVIDER_H

#include <QQuickImageProvider>
#include <QDebug>

#include "image_data.h"

class Image_provider : public QObject, public QQuickImageProvider
{
    Q_OBJECT
    QImage img;

public:
    explicit Image_provider(QObject *parent = nullptr);
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;

public slots:
    void accept_image_data(const Image_data& some_img_data);
};

#endif // IMAGE_PROVIDER_H
