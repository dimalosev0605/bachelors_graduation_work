import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.12

import "../../common"
import "../../delegates"

import Auto_image_handler_qml 1.0
import Individual_file_manager_qml 1.0

Page {
    id: root
    Material.theme: Style_control.is_dark_mode_on ? Material.Dark : Material.Light
    Universal.theme: Style_control.is_dark_mode_on ? Universal.Dark : Universal.Light

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

    property var full_screen_window_comp: Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")
    property var full_screen_window

    property var all_imgs_list_view: all_imgs_list_view
    property var selected_imgs_model: selected_imgs

    property int group_box_border_w: 1

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
            individual_file_manager.add_face(some_source_img_data, some_extracted_face_image_data, some_face_descriptor)
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
    Label {
        id: title
        anchors {
            top: parent.top
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
        }
        width: parent.width
        height: 30
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        fontSizeMode: Text.Fit
        minimumPointSize: 1
        font.pointSize: 15
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        text: {
            if(auto_image_handler.is_choose_face_enable) {
                qsTr("Click on the target face")
            } else if(auto_image_handler.is_handle_remaining_imgs_visible) {
                qsTr("Press \"Handle\" button")
            } else {
                qsTr("Select the image with target face and press \"Ok\" button")
            }
        }
    }
    Button {
        id: select_imgs_btn
        anchors {
            top: parent.top
            topMargin: title.anchors.topMargin
            right: all_imgs_frame.right
            rightMargin: 5
        }
        height: title.height
        onClicked: {
            file_dialog.open()
        }
        text: qsTr("Select")
    }
    GroupBox {
        id: all_imgs_frame
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        anchors {
            top: title.bottom
            topMargin: 20
            left: parent.left
            leftMargin: 10
            right: parent.right
            rightMargin: anchors.leftMargin
        }
        height: {
            if(root.height * 0.1 < 80) {
                80
            }
            else {
                root.height * 0.1
            }
        }
        ListView {
            id: all_imgs_list_view
            anchors {
                fill: parent
                margins: root.group_box_border_w
            }
            model: selected_imgs
            orientation: ListView.Horizontal
            clip: true
            currentIndex: selected_imgs.curr_img_index
            enabled: !auto_image_handler.is_busy_indicator_running
            delegate: Selected_img_only_img {
                height: all_imgs_frame.height - all_imgs_list_view_scroll_bar.height
                width: height
                img_file_path: model.img_file_path
                parent_obj: root
            }
            onCountChanged: {
                if(count === 0) {
                    Image_provider.empty_image()
                    target_face_img.curr_image = Math.random().toString()
                }
            }
            ScrollBar.horizontal: ScrollBar { id: all_imgs_list_view_scroll_bar }
        }
    }

    GroupBox {
        id: target_face_frame
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        anchors {
            top: all_imgs_frame.bottom
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: anchors.topMargin
        }
        width: parent.width * 0.6
        Image {
            id: target_face_img
            anchors {
                top: parent.top
                topMargin: root.group_box_border_w
                left: parent.left
                leftMargin: root.group_box_border_w
                right: parent.right
                rightMargin: root.group_box_border_w
            }
            height: parent.height - anchors.topMargin - anchors.bottomMargin - btns_row.anchors.topMargin - btns_row.height - btns_row.bottom_margin
            property string curr_image
            cache: false
            fillMode: Image.PreserveAspectFit
            enabled: !auto_image_handler.is_busy_indicator_running
            source: "image://Image_provider/" + curr_image
            MouseArea {
                anchors.centerIn: parent
                width: target_face_img.paintedWidth
                height: target_face_img.paintedHeight
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
                        full_screen_window = full_screen_window_comp.createObject(null, { img_source: target_face_img.source })
                        full_screen_window.show()
                    }
                }
            }
        }
        Row {
            id: btns_row
            anchors {
                top: target_face_img.bottom
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width * 0.5
            height: 35
            spacing: 5
            property int count_of_btns: 3
            property int bottom_margin: 5
            property real btn_w: (width - spacing * (count_of_btns - 1) ) / count_of_btns
            Button {
                id: ok_btn
                height: btns_row.height - btns_row.bottom_margin
                width: btns_row.btn_w
                text: qsTr("Ok")
                enabled: all_imgs_list_view.count !== 0 && auto_image_handler.is_ok_enable && !auto_image_handler.is_busy_indicator_running
                onClicked: {
                    auto_image_handler.search_target_face()
                }
            }
            Button {
                id: cancel_last_action_btn
                height: btns_row.height - btns_row.bottom_margin
                width: btns_row.btn_w
                text: qsTr("Cancel")
                enabled: auto_image_handler.is_cancel_visible && !auto_image_handler.is_busy_indicator_running
                onClicked: {
                    auto_image_handler.cancel_last_action()
                }
            }
            Button {
                id: handle_remain_imgs_btn
                height: btns_row.height - btns_row.bottom_margin
                text: qsTr("Handle")
                width: btns_row.btn_w
                enabled: auto_image_handler.is_handle_remaining_imgs_visible && !auto_image_handler.is_busy_indicator_running
                onClicked: {
                    auto_image_handler.handle_remaining_images(selected_imgs.get_selected_imgs_paths())
                }
            }
        }
        Label {
            id: progress_info
            anchors {
                bottom: parent.bottom
                bottomMargin: 1
                right: parent.right
                rightMargin: 3
            }
            width: btns_row.btn_w
            height: 30
            visible: auto_image_handler.is_busy_indicator_running
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            fontSizeMode: Text.Fit
            minimumPointSize: 1
            font.pointSize: 15
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            onVisibleChanged: {
                if(!visible) {
                    text = ""
                }
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
//        width: 80
        height: 30
        visible: auto_image_handler.is_busy_indicator_running
        text: qsTr("Cancel")
        onClicked: {
            auto_image_handler.cancel_processing()
        }
    }
}
