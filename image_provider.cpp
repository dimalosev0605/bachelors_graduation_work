#include "image_provider.h"

Image_provider::Image_provider(QObject* parent)
    : QObject(parent),
      QQuickImageProvider(QQmlImageProviderBase::Image)
{}

QImage Image_provider::requestImage([[maybe_unused]]const QString &id, [[maybe_unused]]QSize *size, [[maybe_unused]]const QSize &requestedSize)
{
    if(!is_show_images || img.isNull()) {
        return QImage(":/qml/icons/black_cross.png");
    }
    return img;
}

void Image_provider::accept_image_data(const Image_data& some_img_data)
{
    const QImage local_q_img(static_cast<const uchar*>(some_img_data.get_data()),
                             static_cast<int>(some_img_data.get_nc()),
                             static_cast<int>(some_img_data.get_nr()),
                             some_img_data.get_bytes_per_pixel() * static_cast<int>(some_img_data.get_nc()),
                             QImage::Format_RGB888);

    img = local_q_img.copy();
}

void Image_provider::accept_image(const QImage& some_img)
{
    img = some_img;
    if(!is_show_images) {
        empty_image();
    }
}

void Image_provider::empty_image()
{
    img = QImage{};
}

bool Image_provider::is_null() const
{
    return img.isNull();
}

void Image_provider::stop_video_running()
{
    is_show_images = false;
    empty_image();
}

void Image_provider::start_video_running()
{
    is_show_images = true;
}

