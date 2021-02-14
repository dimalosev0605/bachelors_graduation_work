#include "selected_people.h"

Selected_people::Selected_people(QObject* parent)
    : Base_people(parent)
{
}

QVector<QString> Selected_people::get_selected_names() const
{
    QVector<QString> res;
    for(int i = 0; i < model_data.size(); ++i) {
        res.push_back(std::get<0>(model_data[i]));
    }
    return res;
}
