import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../common"
import "../../delegates"

import Auto_image_handler_qml 1.0

Page {
    Keys.onEscapePressed: {
        stack_view.pop(StackView.Immediate)
    }
    Keys.onLeftPressed: {
        if(!auto_image_handler.is_busy_indicator_running) {
            selected_imgs.set_curr_img_index(all_imgs_list_view.currentIndex - 1)
        }
    }
    Keys.onRightPressed: {
        if(!auto_image_handler.is_busy_indicator_running) {
            selected_imgs.set_curr_img_index(all_imgs_list_view.currentIndex + 1)
        }
    }

    property var full_screen_img_var: Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")

    Auto_image_handler {
        id: auto_image_handler
        onImage_data_ready: {
            Image_provider.accept_image_data(some_img_data)
            target_face_img.curr_image = Math.random().toString()
        }
        onMessage: {
            message_dialog.text = some_message
            message_dialog.open()
        }
    }
    Connections {
        target: selected_imgs
        function onImage_changed(curr_img_path) {
            auto_image_handler.curr_image_changed(curr_img_path)
            Image_provider.empty_image()
            target_face_img.curr_image = Math.random().toString()
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
    Text {
        id: title
        anchors {
            top: parent.top
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
        }
        width: parent.width
        height: 40
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        fontSizeMode: Text.Fit
        minimumPointSize: 1
        font.pointSize: 15
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        text: "Select one image"
    }
    Rectangle {
        id: all_imgs_frame
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 10
            right: parent.right
            rightMargin: anchors.leftMargin
        }
        color: "#00ff00"
        height: 140
        ListView {
            id: all_imgs_list_view
            anchors.fill: parent
            model: selected_imgs
            orientation: ListView.Horizontal
            clip: true
            currentIndex: selected_imgs.curr_img_index
            enabled: !auto_image_handler.is_busy_indicator_running
            delegate: Selected_img_only_img {
                height: all_imgs_frame.height
                width: height
                img_file_path: model.img_file_path
                view: all_imgs_list_view
                full_screen_img: full_screen_img_var
                selected_imgs_model: selected_imgs
            }
        }
    }
    Button {
        id: ok_btn
        anchors {
            top: all_imgs_frame.bottom
            topMargin: 20
            horizontalCenter: parent.horizontalCenter
        }
        width: 80
        height: 30
        text: "Ok"
        enabled: auto_image_handler.is_ok_enable
        onClicked: {
            auto_image_handler.search_target_face()
        }
    }
    Image {
        id: target_face_img
        anchors {
            top: ok_btn.bottom
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
        }
        width: 200
        height: 200
        property string curr_image
        cache: false
        fillMode: Image.PreserveAspectFit
        source: "image://Image_provider/" + curr_image
        MouseArea {
            anchors.centerIn: parent
            width: target_face_img.width
            height: target_face_img.height
            onClicked: {
                var win = full_screen_img_var.createObject(null, { img_source: target_face_img.source })
                win.show()
            }
        }
    }
    BusyIndicator {
        id: busy_indicator
        anchors.centerIn: parent
        width: parent.width * 0.4
        height: parent.height * 0.4
        visible: auto_image_handler.is_busy_indicator_running
    }
    Button {
        id: cancel_btn
        anchors {
            top: busy_indicator.bottom
            horizontalCenter: busy_indicator.horizontalCenter
        }
        width: 80
        height: 30
        visible: auto_image_handler.is_busy_indicator_running
        text: "Cancel"
        onClicked: {
            auto_image_handler.cancel()
        }
    }
}
