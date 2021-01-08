#ifndef IMAGE_DATA_H
#define IMAGE_DATA_H


class Image_data
{
    const void* data;
    long int nc;
    long int nr;
    static const int bytes_per_pixel = 3;

public:
    Image_data() = default;
    Image_data(const void* some_data, const long int some_nc, const long int some_nr);
    const void* get_data() const;
    long int get_nc() const;
    long int get_nr() const;
    int get_bytes_per_pixel() const;
};

#endif // IMAGE_DATA_H
