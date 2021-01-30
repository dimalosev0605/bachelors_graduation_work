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

    Rectangle {
        id: all_people_frame
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
            id: search_all_people_input
            anchors {
                top: parent.top
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
            width: 150
            height: 30
        }
        ListView {
            id: all_people_list_view
            anchors {
                top: search_all_people_input.bottom
                topMargin: 5
                bottom: parent.bottom
                bottomMargin: 5
            }
            width: parent.width
            clip: true
            currentIndex: -1
            model: all_people
            delegate: Select_individual {
                width: all_people_list_view.width
                height: 40

                number.width: all_people_list_view.headerItem.number_w
                avatar_wrapper.width: all_people_list_view.headerItem.avatar_w
                nickname.width: all_people_list_view.headerItem.nickname_w
                count_of_faces.width: all_people_list_view.headerItem.count_of_faces_w
                check_box_wrapper.width: all_people_list_view.headerItem.check_box_w

                avatar.source: "file://" + model.avatar_path
                count_of_faces.text: model.count_of_faces
                nickname.text: model.individual_name

                check_box.checked: model.is_checked
                check_box.onClicked: {
                    all_people.set_is_checked(index, check_box.checked)
                }
            }
            header: Rectangle {
                id: all_people_list_view_header
                border.width: 1
                border.color: "#000000"
                height: 40
                width: all_people_list_view.width
                property real number_w: 40
                property real avatar_w: (parent.width - number_w - check_box_w) * 0.25
                property real nickname_w: (parent.width - number_w - check_box_w) * 0.5
                property real count_of_faces_w: (parent.width - number_w - check_box_w) * 0.25
                property real check_box_w: 40
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
                        id: check_box
                        height: parent.height
                        width: all_people_list_view_header.check_box_w
                        color: "blue"
                    }
                }
            }
        }
    }
    property real space_between_frames: 100
    Rectangle {
        id: btns_frame
        anchors {
            left: all_people_frame.right
            leftMargin: 2
            right: selected_people_frame.left
            rightMargin: anchors.leftMargin
            verticalCenter: all_people_frame.verticalCenter
        }
        height: 100
        color: "green"
        Button {
            id: select_btn
            width: parent.width
            height: 30
            text: all_people.is_checked_counter === 0 ? "Select all" : "Select " + all_people.is_checked_counter
            onClicked: {
            }
        }
    }
    Rectangle {
        id: selected_people_frame
        anchors {
            top: header.bottom
            topMargin: all_people_frame.anchors.topMargin
            right: parent.right
            rightMargin: all_people_frame.anchors.leftMargin
            bottom: back_btn.top
            bottomMargin: all_people_frame.anchors.bottomMargin
        }
        width: all_people_frame.width
        color: "blue"
        TextField {
            id: search_selected_people_input
            anchors {
                top: parent.top
                topMargin: search_all_people_input.anchors.topMargin
                horizontalCenter: parent.horizontalCenter
            }
            width: search_all_people_input.width
            height: search_all_people_input.height
        }
    }
}
