import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.12

import "../../common"
import "../../delegates"
import Selected_imgs_qml 1.0

Page {
    id: root
    Material.theme: Style_control.is_dark_mode_on ? Material.Dark : Material.Light
    Universal.theme: Style_control.is_dark_mode_on ? Universal.Dark : Universal.Light

    property var full_screen_window_comp: Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")
    property var full_screen_window

    property var selected_imgs_list_view: selected_imgs_list_view
    property var selected_imgs_model: selected_imgs

    Component {
        id: process_images_comp
        Process_images {}
    }
    Component {
        id: auto_mode_comp
        Auto_mode_select_one_image {}
    }
    Keys.onEscapePressed: {
        stack_view.pop(StackView.Immediate)
    }
    Label {
        id: info_lbl
        anchors {
            top: parent.top
            topMargin: parent.height * 0.05
            horizontalCenter: parent.horizontalCenter
        }
        height: 40
        width: parent.width
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        fontSizeMode: Text.Fit
        minimumPointSize: 1
        font.pointSize: 15
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        text: qsTr("Select images and mode")
    }

    Button {
        id: select_imgs_btn
        anchors {
            top: info_lbl.bottom
            topMargin: 20
            horizontalCenter: parent.horizontalCenter
        }
        height: 40
        width: 200
        text: qsTr("Select images")
        onClicked: {
            file_dialog.open()
        }
    }
    Row {
        id: mode_row
        anchors {
            top: select_imgs_btn.bottom
            topMargin: 5
            horizontalCenter: select_imgs_btn.horizontalCenter
        }
        width: select_imgs_btn * 2
        height: 40
        spacing: 5
        RadioButton {
            id: auto_mode_rb
            text: qsTr("Auto")
        }
        RadioButton {
            id: hand_mode_rb
            text: qsTr("Hand mode")
            checked: true
        }
    }
    Connections {
        id: file_dialog_connections
        target: file_dialog
        function onAccepted(fileUrls) {
            selected_imgs.accept_images(file_dialog.fileUrls)
            file_dialog.close()
        }
        function onRejected() {
            file_dialog.close()
        }
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
        enabled: selected_imgs_list_view.count !== 0
        anchors {
            bottom: parent.bottom
            bottomMargin: back_btn.anchors.bottomMargin
            right: parent.right
            rightMargin: back_btn.anchors.leftMargin
        }
        text: qsTr("Next")
        height: back_btn.height
        onClicked: {
            if(selected_imgs_list_view.count > 0) {
                if(hand_mode_rb.checked) {
                    stack_view.push(process_images_comp, StackView.Immediate)
                }
                if(auto_mode_rb.checked) {
                    stack_view.push(auto_mode_comp, StackView.Immediate)
                }
            }
            else {
                console.log("You don't select any images!")
            }
        }
    }
    ListView {
        id: selected_imgs_list_view
        width: parent.width * 0.3 < 400 ? 400 : parent.width * 0.3
        anchors {
            top: mode_row.bottom
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
            bottom: back_btn.top
        }
        clip: true
        currentIndex: selected_imgs.curr_img_index
        model: Selected_imgs { id: selected_imgs }
        spacing: -1
        delegate: Selected_img {
            width: selected_imgs_list_view.width - selected_imgs_list_view_scroll_bar.implicitWidth
            img_file_name: model.img_file_name
            img_file_path: model.img_file_path
            parent_obj: root
            delete_btn_m_area.onClicked: {
                selected_imgs.delete_image(index)
            }
//            delegate_body_m_area.onClicked: {
//                selected_imgs_list_view.currentIndex = index
//            }
        }
        ScrollBar.vertical: ScrollBar { id: selected_imgs_list_view_scroll_bar }
    }
}
