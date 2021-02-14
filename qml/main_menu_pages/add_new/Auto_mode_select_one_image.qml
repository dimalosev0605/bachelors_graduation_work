import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../common"
import "../../delegates"

import Auto_image_handler_qml 1.0
import Individual_file_manager_qml 1.0

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
    Component {
        id: check_auto_retrieved_images_comp
        Check_auto_retrieved_images {}
    }

    Component.onDestruction: {
        Image_provider.empty_image()
    }

    Component.onCompleted: {
        selected_imgs.set_curr_img_index(0)
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
        onImage_ready: {
            individual_file_manager.add_face(some_source_img_data, some_extracted_face_image_data)
        }
        onAll_remaining_images_received: {
            stack_view.push(check_auto_retrieved_images_comp, StackView.Immediate)
        }
        onCurrent_progress: {
            progress_info.text = some_progress
        }
    }
    Individual_file_manager {
        id: individual_file_manager
        Component.onCompleted: {
            individual_file_manager.set_individual_name(individual_checker.get_individual_name(), true)
            individual_file_manager.delete_all_faces() // delete faces that were probably added in "hand mode".
        }
    }

    Connections {
        target: selected_imgs
        function onImage_changed(curr_img_path) {
            auto_image_handler.curr_image_changed(curr_img_path)
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
        text: "Select the image with target face and press \"Ok\" button"
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
            onCountChanged: {
                if(count === 0) {
                    Image_provider.empty_image()
                    target_face_img.curr_image = Math.random().toString()
                }
            }
        }
    }
    Button {
        id: select_img_btn
        anchors {
            bottom: all_imgs_frame.top
            bottomMargin: 3
            right: all_imgs_frame.right
        }
        height: 30
        width: 100
        onClicked: {
            file_dialog.open()
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
        enabled: all_imgs_list_view.count !== 0 && auto_image_handler.is_ok_enable && !auto_image_handler.is_busy_indicator_running
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
        enabled: !auto_image_handler.is_busy_indicator_running
        source: "image://Image_provider/" + curr_image
        MouseArea {
            anchors.centerIn: parent
            width: target_face_img.width
            height: target_face_img.height
            onClicked: {
                if(Image_provider.is_null()) {
                    file_dialog.open()
                    return
                }
                if(auto_image_handler.is_choose_face_enable) {
                    var p_to_s_width_k = target_face_img.paintedWidth / target_face_img.sourceSize.width
                    var p_to_s_height_k = target_face_img.paintedHeight / target_face_img.sourceSize.height

                    var s_to_p_width_k = target_face_img.sourceSize.width / target_face_img.paintedWidth
                    var s_to_p_height_k = target_face_img.sourceSize.height / target_face_img.paintedHeight

                    var p_m_x = mouseX
                    var p_m_y = mouseY

                    var s_m_x = 0
                    var s_m_y = 0

                    if(p_to_s_width_k > 1) {
                        s_m_x = p_m_x / p_to_s_width_k
                    }
                    else {
                        s_m_x = p_m_x * s_to_p_width_k
                    }

                    if(p_to_s_height_k > 1) {
                        s_m_y = p_m_y / p_to_s_height_k
                    }
                    else {
                        s_m_y = p_m_y * s_to_p_height_k
                    }

                    auto_image_handler.choose_face(s_m_x, s_m_y)
                }
                else {
                    var win = full_screen_img_var.createObject(null, { img_source: target_face_img.source })
                    win.show()
                }
            }
        }
    }
    Button {
        id: cancel_last_action_btn
        anchors {
            top: target_face_img.bottom
            topMargin: 5
            horizontalCenter: target_face_img.horizontalCenter
        }
        width: 80
        height: 30
        text: "cancel"
        visible: auto_image_handler.is_cancel_visible
        enabled: !auto_image_handler.is_busy_indicator_running
        onClicked: {
            auto_image_handler.cancel_last_action()
        }
    }
    Button {
        id: handle_remain_imgs_btn
        anchors {
            left: target_face_img.right
            leftMargin: 5
            verticalCenter: target_face_img.verticalCenter
        }
        width: 200
        height: 30
        text: "Handle remaining images."
        visible: auto_image_handler.is_handle_remaining_imgs_visible
        enabled: !auto_image_handler.is_busy_indicator_running
        onClicked: {
            auto_image_handler.handle_remaining_images(selected_imgs.get_selected_imgs_paths())
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
            auto_image_handler.cancel_processing()
        }
    }
    Text {
        id: progress_info
        anchors {
            top: cancel_btn.bottom
            topMargin: 2
        }
        width: cancel_btn.width
        height: cancel_btn.height
        visible: auto_image_handler.is_busy_indicator_running
        onVisibleChanged: {
            if(!visible) {
                text = ""
            }
        }
    }
}
