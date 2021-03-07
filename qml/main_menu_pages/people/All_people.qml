import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.12

import "../../common"
import "../../delegates"

import Available_people_qml 1.0

Page {
    id: root
    Material.theme: Style_control.is_dark_mode_on ? Material.Dark : Material.Light
    Universal.theme: Style_control.is_dark_mode_on ? Universal.Dark : Universal.Light

    property var full_screen_window_comp: Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")
    property var full_screen_window

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
            topMargin: 20
            horizontalCenter: parent.horizontalCenter
        }
        onTextChanged: {
            if(search_input.text.length === 0) {
                available_people.cancel_search()
                return
            }
            available_people.search(search_input.text)
        }
        placeholderText: qsTr("Search")
        width: 250
        height: Style_control.get_style() === "Material" ? 70 : 35
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
            width: available_people_list_view.width - available_people_list_view_scroll_bar.width
            height: 40

            number.width: available_people_list_view.headerItem.number_w
            avatar_wrapper.width: available_people_list_view.headerItem.avatar_w
            nickname.width: available_people_list_view.headerItem.nickname_w
            count_of_faces.width: available_people_list_view.headerItem.count_of_faces_w
            delete_btn_wrapper.width: available_people_list_view.headerItem.delete_btn_w

            avatar.source: "file://" + model.avatar_path
            count_of_faces.text: model.count_of_faces
            nickname.text: model.individual_name

            parent_obj: root

            body_m_area.onClicked: {
                var individual_name = available_people.get_individual_name(index)
                if(individual_name === "") return
                stack_view.push(edit_individual_comp, {"individual_name": individual_name}, StackView.Immediate)
            }

            delete_btn_m_area.onClicked: {
                available_people.delete_individual(index)
            }
        }
        ScrollBar.vertical: ScrollBar { id: available_people_list_view_scroll_bar }
        header: Item {
            id: available_people_list_view_header
            height: 40
            width: available_people_list_view.width - available_people_list_view_scroll_bar.width
            property real number_w: 40
            property real avatar_w: (available_people_list_view_header.width - number_w - delete_btn_w) * 0.25
            property real nickname_w: (available_people_list_view_header.width - number_w - delete_btn_w) * 0.5
            property real count_of_faces_w: (available_people_list_view_header.width - number_w - delete_btn_w) * 0.25
            property real delete_btn_w: 40
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
                Item {
                    id: delete_btn
                    height: parent.height
                    width: available_people_list_view_header.delete_btn_w
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
