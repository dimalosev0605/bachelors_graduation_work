#ifndef DIR_NAMES_H
#define DIR_NAMES_H

#include <QString>

namespace Dir_names {
    static const QString app_data = "app_data";
    static const QString people = "people";
    namespace Individual {
        static const QString sources = "sources";
        static const QString extracted_faces = "extracted_faces";
        namespace Img_file_names {
        static const QString source = "source";
        static const QString extracted_face = "extracted_face";
        static const QString img_extension = ".jpg";
        }
    }
}

#endif // DIR_NAMES_H
