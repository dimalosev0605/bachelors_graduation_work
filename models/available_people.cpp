#include "available_people.h"

Available_people::Available_people(QObject* parent)
    : Base_people(parent)
{
    load_model_data();
}

void Available_people::delete_individual(const int some_index)
{
    if(some_index < 0 || some_index >= model_data.size()) return;

    const auto individual_for_deletion = std::get<0>(model_data[some_index]).remove("<b>").remove("</b>");
    QDir dir(dir_paths.people() + '/' + individual_for_deletion);
    if(dir.removeRecursively()) {
        beginRemoveRows(QModelIndex(), some_index, some_index);

        model_data.removeAt(some_index);

        if(copy_model_data != nullptr) {
            for(int i = 0; i < copy_model_data->size(); ++i) {
                if(individual_for_deletion == std::get<0>(copy_model_data->operator[](i))) {
                    copy_model_data->removeAt(i);
                    break;
                }
            }
        }

        endRemoveRows();
    }
}

QString Available_people::get_individual_name(const int some_index) const
{
    if(some_index < 0 || some_index >= model_data.size()) return QString{};
    auto res = std::get<0>(model_data[some_index]);
    res = res.remove("<b>").remove("</b>");
    return res;
}

