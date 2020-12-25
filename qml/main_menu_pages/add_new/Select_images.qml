import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../common"
import "../../delegates"
import Selected_imgs_qml 1.0

Page {

    property var full_screen_img_var: Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")

    Component {
        id: process_images_comp
        Process_images {}
    }
    Keys.onEscapePressed: {
        stack_view.pop(StackView.Immediate)
    }
    Button {
        id: select_imgs_btn
        anchors {
            top: parent.top
            topMargin: parent.height * 0.2
            horizontalCenter: parent.horizontalCenter
        }
        height: 35
        width: 200
        text: "Select images"
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
        RadioButton {
            text: "auto"
        }
        RadioButton {
            text: "hand mode"
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
        visible: selected_imgs_list_view.count !== 0
        anchors {
            bottom: parent.bottom
            bottomMargin: 5
            right: parent.right
            rightMargin: 5
        }
        text: "Next"
        width: 60
        height: 30
        onClicked: {
            if(selected_imgs_list_view.count > 0) {
                stack_view.push(process_images_comp, StackView.Immediate)
                selected_imgs.set_curr_img_index(0)
            }
            else {
                console.log("You don'y selecte any images!")
            }
        }
    }
    ListView {
        id: selected_imgs_list_view
        width: 400
        anchors {
            top: mode_row.bottom
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
            bottom: back_btn.top
        }
        clip: true
        currentIndex: -1
        model: Selected_imgs { id: selected_imgs }
        delegate: Selected_img {
            width: selected_imgs_list_view.width
            img_file_name: model.img_file_name
            img_file_path: model.img_file_path
            view: selected_imgs_list_view
            full_screen_img: full_screen_img_var
            delete_btn_m_area.onClicked: {
                selected_imgs.delete_image(index)
            }
//            delegate_body_m_area.onClicked: {
//                selected_imgs_list_view.currentIndex = index
//            }
        }
//        ScrollBar.vertical:
    }
}
