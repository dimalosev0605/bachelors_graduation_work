import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../common"
import "../../delegates"

import All_people_qml 1.0

Page {
    Keys.onEscapePressed: {
        stack_view.pop(StackView.Immediate)
    }
    All_people {
        id: all_people
    }
    TextField {
        id: search_input
        anchors {
            top: parent.top
            topMargin: 15
            horizontalCenter: parent.horizontalCenter
        }
        onTextChanged: {
//            all_people_list_view.currentIndex = -1
            if(search_input.text.length === 0) {
                all_people.cancel_search()
                return
            }
            all_people.search(search_input.text)
        }

        width: 150
        height: 30
    }
    ListView {
        id: all_people_list_view
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
        model: all_people
        delegate: Individual {
            width: all_people_list_view.width
            height: 40

            number.width: all_people_list_view.headerItem.number_w
            avatar_wrapper.width: all_people_list_view.headerItem.avatar_w
            nickname.width: all_people_list_view.headerItem.nickname_w
            count_of_faces.width: all_people_list_view.headerItem.count_of_faces_w
            delete_btn_wrapper.width: all_people_list_view.headerItem.delete_btn_w

            avatar.source: "file://" + model.avatar_path
            count_of_faces.text: model.count_of_faces
            nickname.text: model.individual_name

            delete_btn_m_area.onClicked: {
                all_people.delete_individual(index)
            }
        }
        header: Rectangle {
            id: all_people_list_view_header
            border.width: 1
            border.color: "#000000"
            height: 40
            width: all_people_list_view.width
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
                    width: all_people_list_view_header.number_w
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
                    width: all_people_list_view_header.avatar_w
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
                    width: all_people_list_view_header.nickname_w
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
                    width: all_people_list_view_header.count_of_faces_w
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
                    width: all_people_list_view_header.delete_btn_w
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
