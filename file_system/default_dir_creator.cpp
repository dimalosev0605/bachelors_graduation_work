#include "default_dir_creator.h"

Default_dir_creator::Default_dir_creator(QObject *parent)
    : QObject(parent)
{}

void Default_dir_creator::create_default_dirs() const
{
    QDir dir(dir_paths.app());

    if(!dir.exists(dir_paths.app_data())) {
        if(dir.mkdir(dir_paths.app_data())) {
            if(!dir.mkdir(dir_paths.people())) {
                emit message("Unable to create necessary directories for application.");
                QTimer::singleShot(2000, this, &Default_dir_creator::close_app);
            }
        }
        else {
            emit message("Unable to create necessary directories for application.");
            QTimer::singleShot(2000, this, &Default_dir_creator::close_app);
        }
    }
}

void Default_dir_creator::close_app()
{
    std::exit(1);
}
