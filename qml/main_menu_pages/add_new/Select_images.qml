import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../common"
import "../../delegates"
import Selected_imgs_qml 1.0

Page {

    property var full_screen_img_var: Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")

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
    ListView {
        id: selected_imgs_list_view
        width: 400
        anchors {
            top: select_imgs_btn.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: 5
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
            delegate_body_m_area.onClicked: {
                selected_imgs_list_view.currentIndex = index
            }
        }
//        ScrollBar.vertical:
    }
}
