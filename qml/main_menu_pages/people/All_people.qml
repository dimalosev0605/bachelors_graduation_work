import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../common"
import "../../delegates"

import Available_people_qml 1.0

Page {
    Keys.onEscapePressed: {
        stack_view.pop(StackView.Immediate)
    }
    Available_people {
        id: available_people
    }
    Component {
        id: edit_individual_comp
        Edit_individual {}
    }

    TextField {
        id: search_input
        anchors {
            top: parent.top
            topMargin: 15
            horizontalCenter: parent.horizontalCenter
        }
        onTextChanged: {
            if(search_input.text.length === 0) {
                available_people.cancel_search()
                return
            }
            available_people.search(search_input.text)
        }

        width: 150
        height: 30
    }
    ListView {
        id: available_people_list_view
        anchors {
            top: search_input.bottom
            topMargin: 10
            bottom: parent.bottom
            bottomMargin: 10
            horizontalCenter: search_input.horizontalCenter
        }
        width: parent.width / 2
        clip: true
        currentIndex: -1
        model: available_people
        delegate: Individual {
            width: available_people_list_view.width
            height: 40

            number.width: available_people_list_view.headerItem.number_w
            avatar_wrapper.width: available_people_list_view.headerItem.avatar_w
            nickname.width: available_people_list_view.headerItem.nickname_w
            count_of_faces.width: available_people_list_view.headerItem.count_of_faces_w
            delete_btn_wrapper.width: available_people_list_view.headerItem.delete_btn_w

            avatar.source: "file://" + model.avatar_path
            count_of_faces.text: model.count_of_faces
            nickname.text: model.individual_name

            body_m_area.onClicked: {
                var individual_name = available_people.get_individual_name(index)
                if(individual_name === "") return
                stack_view.push(edit_individual_comp, {"individual_name": individual_name}, StackView.Immediate)
            }

            delete_btn_m_area.onClicked: {
                available_people.delete_individual(index)
            }
        }
        header: Rectangle {
            id: available_people_list_view_header
            border.width: 1
            border.color: "#000000"
            height: 40
            width: available_people_list_view.width
            property real number_w: 40
            property real avatar_w: (parent.width - number_w - delete_btn_w) * 0.25
            property real nickname_w: (parent.width - number_w - delete_btn_w) * 0.5
            property real count_of_faces_w: (parent.width - number_w - delete_btn_w) * 0.25
            property real delete_btn_w: 40
            Row {
                anchors.fill: parent
                Text {
                    id: number
                    height: parent.height
                    width: available_people_list_view_header.number_w
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    fontSizeMode: Text.Fit
                    minimumPointSize: 1
                    font.pointSize: 10
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    text: "Number"
                }
                Text {
                    id: avatar
                    height: parent.height
                    width: available_people_list_view_header.avatar_w
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    fontSizeMode: Text.Fit
                    minimumPointSize: 1
                    font.pointSize: 10
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    text: "Avatar"
                }
                Text {
                    id: nickname
                    width: available_people_list_view_header.nickname_w
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    fontSizeMode: Text.Fit
                    minimumPointSize: 1
                    font.pointSize: 10
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    text: "Nickname"
                }
                Text {
                    id: number_of_faces
                    width: available_people_list_view_header.count_of_faces_w
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    fontSizeMode: Text.Fit
                    minimumPointSize: 1
                    font.pointSize: 10
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    text: "Number of \nfaces"
                }
                Rectangle {
                    id: delete_btn
                    height: parent.height
                    width: available_people_list_view_header.delete_btn_w
                    color: "blue"
                }
            }
        }
    }

    Back_btn {
        anchors {
            bottom: parent.bottom
            bottomMargin: 5
            left: parent.left
            leftMargin: 5
        }
        onClicked: {
            stack_view.pop(StackView.Immediate)
        }
    }
}
