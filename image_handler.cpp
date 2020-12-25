#include "image_handler.h"

Image_handler::Image_handler(QObject* parent)
    : QObject(parent)
{}

void Image_handler::curr_image_changed(const QString& curr_img_path)
{
    dlib::load_image(img, curr_img_path.toStdString());

    const auto data = dlib::image_data(img);
    Image_data image_data(data, img.nc(), img.nr());

    emit image_data_ready(image_data);
}
