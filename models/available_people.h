#ifndef AVAILABLE_PEOPLE_H
#define AVAILABLE_PEOPLE_H

#include "base_people.h"

class Available_people: public Base_people
{
    Q_OBJECT

public:
    explicit Available_people(QObject* parent = nullptr);

public slots:
    void delete_individual(const int some_index);
    QString get_individual_name(const int some_index) const;
};

#endif // AVAILABLE_PEOPLE_H
