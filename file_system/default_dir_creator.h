#ifndef DEFAULT_DIR_CREATOR_H
#define DEFAULT_DIR_CREATOR_H

#include <QCoreApplication>
#include <QDir>
#include <QDebug>

#include "dir_paths.h"

class Default_dir_creator
{
    Dir_paths dir_paths;

public:
    void create_default_dirs() const;
};

#endif // DEFAULT_DIR_CREATOR_H
