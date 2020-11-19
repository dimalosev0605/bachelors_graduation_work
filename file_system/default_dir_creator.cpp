#include "default_dir_creator.h"

void Default_dir_creator::create_default_dirs() const
{
    QDir dir(dir_paths.app());

    if(!dir.exists(dir_paths.app_data())) {
        if(dir.mkdir(dir_paths.app_data())) {
            if(!dir.mkdir(dir_paths.people())) {
                std::exit(-1);
            }
        }
        else {
            std::exit(-1);
        }
    }
}
