#ifndef SELECTED_PEOPLE_H
#define SELECTED_PEOPLE_H

#include "base_people.h"

class Selected_people: public Base_people
{
    Q_OBJECT

public:
    explicit Selected_people(QObject* parent = nullptr);

public slots:
    QVector<QString> get_selected_names() const;
};

#endif // SELECTED_PEOPLE_H
