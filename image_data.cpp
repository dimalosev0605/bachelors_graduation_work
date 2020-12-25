#include "image_data.h"

Image_data::Image_data(const void* some_data, const long int some_nc, const long int some_nr)
    : data(some_data),
      nc(some_nc),
      nr(some_nr)
{}

const void* Image_data::get_data() const
{
    return data;
}

long int Image_data::get_nc() const
{
    return nc;
}

long int Image_data::get_nr() const
{
    return nr;
}

int Image_data::get_bytes_per_pixel() const
{
    return bytes_per_pixel;
}
