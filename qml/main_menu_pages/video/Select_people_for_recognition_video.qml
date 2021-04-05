import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.12

import "../../common"
import "../../delegates"

import Available_people_qml 1.0
import Selected_people_qml 1.0

Page {
    id: root
    Material.theme: Style_control.is_dark_mode_on ? Material.Dark : Material.Light
    Universal.theme: Style_control.is_dark_mode_on ? Universal.Dark : Universal.Light

    property var full_screen_window_comp: Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")
    property var full_screen_window

    property int group_box_b_w: 1

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

    Label {
        id: header
        anchors {
            top: parent.top
            topMargin: 10
        }
        height: 30
        width: parent.width
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        fontSizeMode: Text.Fit
        minimumPointSize: 1
        font.pointSize: 10
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        text: qsTr("Select people for recognition")
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
            bottomMargin: back_btn.anchors.bottomMargin
            right: parent.right
            rightMargin: back_btn.anchors.leftMargin
        }
        height: back_btn.height
        width: back_btn.width
        enabled: selected_people_list_view.count > 0
        text: qsTr("Next")
        onClicked: {
            stack_view.push(recognition_comp, StackView.Immediate)
        }
    }

    GroupBox {
        id: available_people_frame
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        anchors {
            top: header.bottom
            topMargin: 10
            left: parent.left
            leftMargin: 5
            bottom: back_btn.top
            bottomMargin: 10
        }
        width: parent.width / 2 - space_between_frames
        TextField {
            id: search_available_people_input
            anchors {
                top: parent.top
                topMargin: 2
                horizontalCenter: parent.horizontalCenter
            }
            width: 150
            height: Style_control.get_style() === "Material" ? 70 : 35
            placeholderText: qsTr("Search")
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
                left: parent.left
                leftMargin: root.group_box_b_w
                right: parent.right
                rightMargin: root.group_box_b_w
            }
            clip: true
            currentIndex: -1
            model: available_people
            delegate: Select_individual {
                width: available_people_list_view.width - available_people_list_view_scroll_bar.width
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
            ScrollBar.vertical: ScrollBar { id: available_people_list_view_scroll_bar }
            header: Item {
                id: available_people_list_view_header
                height: 40
                width: available_people_list_view.width - available_people_list_view_scroll_bar.width
                property real number_w: 40
                property real avatar_w: (parent.width - number_w) * 0.25
                property real nickname_w: (parent.width - number_w) * 0.5
                property real count_of_faces_w: (parent.width - number_w) * 0.25
                Row {
                    anchors.fill: parent
                    Label {
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
                        text: qsTr("Number")
                    }
                    Label {
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
                        text: qsTr("Preview")
                    }
                    Label {
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
                        text: qsTr("Nickname")
                    }
                    Label {
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
                        text: qsTr("Count of \nfaces")
                    }
                }
            }
        }
    }
    property real space_between_frames: 70
    GroupBox {
        id: btns_frame
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        anchors {
            left: available_people_frame.right
            leftMargin: 2
            right: selected_people_frame.left
            rightMargin: anchors.leftMargin
            verticalCenter: available_people_frame.verticalCenter
        }
        height: 70
        Column {
            id: btns_col
            spacing: 2
            anchors {
                fill: parent
                topMargin: root.group_box_b_w
                bottomMargin: root.group_box_b_w
                leftMargin: root.group_box_b_w
                rightMargin: root.group_box_b_w
            }
            property int btns_c: 2
            property real btns_h: (height - spacing * (btns_c - 1)) / btns_c
            Button {
                id: pass_all_data_from_available_people_btn
                width: btns_col.width
                height: btns_col.btns_h
                text: qsTr("All -->")
                onClicked: {
                    selected_people.receive_model_data(available_people.pass_all_model_data())
                }
            }
            Button {
                width: btns_col.width
                height: btns_col.btns_h
                text: qsTr("<-- All")
                onClicked: {
                    available_people.receive_model_data(selected_people.pass_all_model_data())
                }
            }
        }
    }
    GroupBox {
        id: selected_people_frame
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        anchors {
            top: header.bottom
            topMargin: available_people_frame.anchors.topMargin
            right: parent.right
            rightMargin: available_people_frame.anchors.leftMargin
            bottom: back_btn.top
            bottomMargin: available_people_frame.anchors.bottomMargin
        }
        width: available_people_frame.width
        TextField {
            id: search_selected_people_input
            anchors {
                top: parent.top
                topMargin: search_available_people_input.anchors.topMargin
                horizontalCenter: parent.horizontalCenter
            }
            width: search_available_people_input.width
            height: search_available_people_input.height
            placeholderText: search_available_people_input.placeholderText
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
                left: parent.left
                leftMargin: root.group_box_b_w
                right: parent.right
                rightMargin: root.group_box_b_w
            }
            width: parent.width
            clip: true
            currentIndex: -1
            model: selected_people
            ScrollBar.vertical: ScrollBar { id: selected_people_list_view_scroll_bar }
            delegate: Select_individual {
                width: selected_people_list_view.width - selected_people_list_view_scroll_bar.width
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
