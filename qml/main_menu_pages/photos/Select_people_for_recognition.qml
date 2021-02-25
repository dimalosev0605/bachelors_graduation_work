import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../common"
import "../../delegates"

import Available_people_qml 1.0
import Selected_people_qml 1.0

Page {
    id: root

    property var full_screen_window_comp: Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")
    property var full_screen_window

    Keys.onEscapePressed: {
        stack_view.pop(StackView.Immediate)
    }

    Component {
        id: recognition_comp
        Recognition {}
    }

    Available_people {
        id: available_people
    }

    Selected_people {
        id: selected_people
    }

    Text {
        id: header
        height: 30
        width: parent.width
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        fontSizeMode: Text.Fit
        minimumPointSize: 1
        font.pointSize: 10
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        text: "Select people for recognition"
    }

    Back_btn {
        id: back_btn
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

    Button {
        id: next_btn
        anchors {
            bottom: parent.bottom
            bottomMargin: 5
            right: parent.right
            rightMargin: 5
        }
        height: 30
        width: 60
        enabled: selected_people_list_view.count > 0
        text: "Next"
        onClicked: {
            stack_view.push(recognition_comp, StackView.Immediate)
        }
    }

    Rectangle {
        id: available_people_frame
        anchors {
            top: header.bottom
            topMargin: 10
            left: parent.left
            leftMargin: 5
            bottom: back_btn.top
            bottomMargin: 10
        }
        width: parent.width / 2 - space_between_frames
        color: "red"
        TextField {
            id: search_available_people_input
            anchors {
                top: parent.top
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
            width: 150
            height: 30
            onTextChanged: {
                if(search_available_people_input.length === 0) {
                    available_people.cancel_search()
                    return
                }
                available_people.search(search_available_people_input.text)
            }
        }
        ListView {
            id: available_people_list_view
            anchors {
                top: search_available_people_input.bottom
                topMargin: 5
                bottom: parent.bottom
                bottomMargin: 5
            }
            width: parent.width
            clip: true
            currentIndex: -1
            model: available_people
            delegate: Select_individual {
                width: available_people_list_view.width
                height: 40

                number.width: available_people_list_view.headerItem.number_w
                avatar_wrapper.width: available_people_list_view.headerItem.avatar_w
                nickname.width: available_people_list_view.headerItem.nickname_w
                count_of_faces.width: available_people_list_view.headerItem.count_of_faces_w

                avatar.source: "file://" + model.avatar_path
                count_of_faces.text: model.count_of_faces
                nickname.text: model.individual_name

                parent_obj: root

                body_m_area.onClicked: {
                    selected_people.add_item(available_people.delete_item(index))
                }
            }
            header: Rectangle {
                id: available_people_list_view_header
                border.width: 1
                border.color: "#000000"
                height: 40
                width: available_people_list_view.width
                property real number_w: 40
                property real avatar_w: (parent.width - number_w) * 0.25
                property real nickname_w: (parent.width - number_w) * 0.5
                property real count_of_faces_w: (parent.width - number_w) * 0.25
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
                }
            }
        }
    }
    property real space_between_frames: 100
    Rectangle {
        id: btns_frame
        anchors {
            left: available_people_frame.right
            leftMargin: 2
            right: selected_people_frame.left
            rightMargin: anchors.leftMargin
            verticalCenter: available_people_frame.verticalCenter
        }
        height: 100
        color: "green"
        Button {
            id: pass_all_data_from_available_people_btn
            width: parent.width
            height: 30
            text: "All -->"
            onClicked: {
                selected_people.receive_model_data(available_people.pass_all_model_data())
            }
        }
        Button {
            anchors {
                top: pass_all_data_from_available_people_btn.bottom
                topMargin: 2
            }
            width: parent.width
            height: 30
            text: "<-- All"
            onClicked: {
                available_people.receive_model_data(selected_people.pass_all_model_data())
            }
        }
    }
    Rectangle {
        id: selected_people_frame
        anchors {
            top: header.bottom
            topMargin: available_people_frame.anchors.topMargin
            right: parent.right
            rightMargin: available_people_frame.anchors.leftMargin
            bottom: back_btn.top
            bottomMargin: available_people_frame.anchors.bottomMargin
        }
        width: available_people_frame.width
        color: "yellow"
        TextField {
            id: search_selected_people_input
            anchors {
                top: parent.top
                topMargin: search_available_people_input.anchors.topMargin
                horizontalCenter: parent.horizontalCenter
            }
            width: search_available_people_input.width
            height: search_available_people_input.height
            onTextChanged: {
                if(search_selected_people_input.length === 0) {
                    selected_people.cancel_search()
                    return
                }
                selected_people.search(search_selected_people_input.text)
            }
        }
        ListView {
            id: selected_people_list_view
            anchors {
                top: search_selected_people_input.bottom
                topMargin: available_people_list_view.anchors.topMargin
                bottom: parent.bottom
                bottomMargin: available_people_list_view.anchors.bottomMargin
            }
            width: parent.width
            clip: true
            currentIndex: -1
            model: selected_people
            delegate: Select_individual {
                width: selected_people_list_view.width
                height: 40

                number.width: selected_people_list_view.headerItem.number_w
                avatar_wrapper.width: selected_people_list_view.headerItem.avatar_w
                nickname.width: selected_people_list_view.headerItem.nickname_w
                count_of_faces.width: selected_people_list_view.headerItem.count_of_faces_w

                avatar.source: "file://" + model.avatar_path
                count_of_faces.text: model.count_of_faces
                nickname.text: model.individual_name

                parent_obj: root

                body_m_area.onClicked: {
                    available_people.add_item(selected_people.delete_item(index))
                }

            }
            header: available_people_list_view.header
        }
    }
}
