import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../common"
import "../../delegates"

import Selected_imgs_qml 1.0
import Image_handler_qml 1.0
import Individual_file_manager_qml 1.0

Page {
    Keys.onEscapePressed: {
        stack_view.pop(StackView.Immediate)
    }

    Component.onDestruction: {
        Image_provider.empty_image()
    }

    property var full_screen_img_var: Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")

    Connections {
        target: selected_imgs
        function onImage_changed(curr_img_path) {
            image_handler.curr_image_changed(curr_img_path)
        }
    }

    Image_handler {
        id: image_handler
        onImage_data_ready: {
            Image_provider.accept_image_data(some_img_data)
            img.curr_image = Math.random().toString()
        }
    }

    Individual_file_manager {
        id: individual_file_manager
        Component.onCompleted: {
            individual_file_manager.set_individual_name(individual_checker.get_individual_name(), true)
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
    Rectangle {
        id: img_frame
        anchors {
            top: parent.top
            topMargin: 10
            left: parent.left
            leftMargin: 5
            bottom: back_btn.top
            bottomMargin: buttons_frame.height + buttons_frame.anchors.topMargin * 2
        }
        color: "#00ff00"
        property int space_between_img_and_extr_faces: 10
        width: (parent.width - anchors.leftMargin * 2 - space_between_img_and_extr_faces) / 2
        Text {
            id: img_info
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            height: 30
            width: parent.width - select_imgs_btn.width
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            fontSizeMode: Text.Fit
            minimumPointSize: 1
            font.pointSize: 10
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            text: "Original: " + img.sourceSize.width + " X " + img.sourceSize.height + " --- " +
                  "Painted: " + img.paintedWidth + " X " + img.paintedHeight
        }
        Button {
            id: select_imgs_btn
            anchors {
                right: parent.right
            }
            height: img_info.height
            width: height * 2
            text: "Select"
            onClicked: {
                file_dialog.open()
            }
        }
        Image {
            id: img
            anchors {
                top: img_info.bottom
                topMargin: 5
                bottom: all_imgs_frame.top
                bottomMargin: anchors.topMargin
                left: parent.left
                leftMargin: 50
                right: parent.right
                rightMargin: anchors.leftMargin
            }
            property string curr_image
            cache: false
            fillMode: Image.PreserveAspectFit
            source: "image://Image_provider/" + curr_image
            MouseArea {
                anchors.centerIn: parent
                width: img.paintedWidth
                height: img.paintedHeight
                onClicked: {
                    if(image_handler.is_choose_face_enable) {
                        var p_to_s_width_k = img.paintedWidth / img.sourceSize.width
                        var p_to_s_height_k = img.paintedHeight / img.sourceSize.height

                        var s_to_p_width_k = img.sourceSize.width / img.paintedWidth
                        var s_to_p_height_k = img.sourceSize.height / img.paintedHeight

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

                        image_handler.choose_face(s_m_x, s_m_y)
                    }
                    else {
                        var win = full_screen_img_var.createObject(null, { img_source: img.source, view: all_imgs_list_view })
                        win.show()
                    }
                }
            }
            BusyIndicator {
                id: busy_indicator
                anchors.centerIn: parent
                width: parent.width * 0.4
                height: parent.height * 0.4
                visible: image_handler.is_busy_indicator_running
            }
            Button {
                anchors {
                    top: busy_indicator.bottom
                    horizontalCenter: busy_indicator.horizontalCenter
                    topMargin: 3
                }
                width: busy_indicator.width
                height: 30
                visible: busy_indicator.visible
                text: "Cancel"
                onClicked: {
                    image_handler.cancel_processing()
                }
            }
        }
        Rectangle {
            id: all_imgs_frame
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            height: 60
            color: "red"
            ListView {
                id: all_imgs_list_view
                anchors.fill: parent
                model: selected_imgs
                orientation: ListView.Horizontal
                clip: true
                currentIndex: selected_imgs.curr_img_index
                enabled: !image_handler.is_busy_indicator_running
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
            id: prev_img_btn
            enabled: !image_handler.is_busy_indicator_running
            anchors {
                left: parent.left
                top: img.top
                bottom: all_imgs_frame.top
                bottomMargin: img.anchors.bottomMargin
                right: img.left
            }
            onClicked: {
                selected_imgs.set_curr_img_index(selected_imgs.curr_img_index - 1)
            }
        }
        Button {
            id: next_img_btn
            enabled: !image_handler.is_busy_indicator_running
            anchors {
                left: img.right
                top: img.top
                bottom: all_imgs_frame.top
                bottomMargin: img.anchors.bottomMargin
                right: parent.right
            }
            onClicked: {
                selected_imgs.set_curr_img_index(selected_imgs.curr_img_index + 1)
            }
        }
    }
    Rectangle {
        id: extr_faces_frame
        anchors {
            top: parent.top
            topMargin: img_frame.anchors.topMargin
            right: parent.right
            rightMargin: img_frame.anchors.leftMargin
            bottom: img_frame.anchors.bottom
            bottomMargin: img_frame.anchors.bottomMargin
        }
        color: "#00ff00"
        width: img_frame.width
        Text {
            id: table_title
            anchors {
                top: parent.top
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
            text: "Extracted faces for: " + individual_checker.get_individual_name()
        }
        ListView {
            id: extracted_faces_list_view
            anchors {
                top: table_title.bottom
                topMargin: 5
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            model: individual_file_manager
            clip: true
            currentIndex: -1
            delegate: Source_and_extr_imgs {
                height: 40
                width: extracted_faces_list_view.width

                img_number.width: extracted_faces_list_view.headerItem.number_w
                src_img_wrapper.width: extracted_faces_list_view.headerItem.img_w
                extr_face_img_wrapper.width: extracted_faces_list_view.headerItem.img_w
                delete_btn_wrapper.width: extracted_faces_list_view.headerItem.delete_btn_w

                src_img.source: "file://" + model.src_img_path
                extr_face_img.source: "file://" + model.extr_face_img_path

                delete_btn_m_area.onClicked: {
                    individual_file_manager.delete_face(index)
                }
            }
            header: Rectangle {
                id: extracted_faces_table_header
                height: 40
                width: extracted_faces_list_view.width
                color: "transparent"
                border.width: 1
                border.color: "#000000"
                property int number_w: 30
                property int delete_btn_w: 50
                property real img_w: (extracted_faces_table_header.width - extracted_faces_table_header.number_w - extracted_faces_table_header.delete_btn_w) / 2
                Row {
                    anchors.fill: parent
                    Rectangle {
                        id: image_number
                        height: parent.height
                        width: extracted_faces_table_header.number_w
                        color: "transparent"
                    }
                    Text {
                        width: extracted_faces_table_header.img_w
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        fontSizeMode: Text.Fit
                        minimumPointSize: 1
                        font.pointSize: 10
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                        text: "Source image"
                    }
                    Text {
                        width: extracted_faces_table_header.img_w
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        fontSizeMode: Text.Fit
                        minimumPointSize: 1
                        font.pointSize: 10
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                        text: "Extracted face"
                    }
                    Rectangle {
                        id: delete_btn
                        height: parent.height
                        width: extracted_faces_table_header.delete_btn_w
                        color: "transparent"
                    }
                }
            }
        }
    }

    Rectangle {
        id: buttons_frame
        anchors {
            horizontalCenter: img_frame.horizontalCenter
            top: img_frame.bottom
            topMargin: 5
        }
        width: img_frame.width * 0.8
        height: 150
        color: "#ff0000"
        Column {
            id: btns_col
            anchors.fill: parent
            spacing: 3
            property int count_of_btns_in_row: 3
            property int count_of_rows: 3
            property real row_height: (height - spacing * (count_of_rows - 1)) / count_of_rows
            property real btn_width: (width - space_between_btns_in_row * (count_of_btns_in_row - 1)) / count_of_btns_in_row
            property real space_between_btns_in_row: 3
            Row {
                width: parent.width
                height: parent.row_height
                spacing: parent.space_between_btns_in_row
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: "pyr up"
                    enabled: !image_handler.is_busy_indicator_running && image_handler.is_hog_enable
                    onClicked: {
                        image_handler.pyr_up()
                    }
                }
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: "pyr down"
                    enabled: !image_handler.is_busy_indicator_running && image_handler.is_hog_enable
                    onClicked: {
                        image_handler.pyr_down()
                    }
                }
                Button {
                    id: resize_btn
                    height: parent.height
                    width: btns_col.btn_width
                    text: "resize"
                    enabled: !image_handler.is_busy_indicator_running && image_handler.is_hog_enable
                    onClicked: {
                        new_size_popup.open()
                    }
                    Popup {
                        id: new_size_popup
                        visible: false
                        property int item_h: 35
                        property int space: 2
                        width: resize_btn.width
                        height: item_h * 3 + 2 * space + col.anchors.margins * 2
                        background: Rectangle {
                            id: background
                            anchors.fill: parent
                            border.color: "#000000"
                            color: "blue"
                            border.width: 1
                        }
                        contentItem: Column {
                            id: col
                            anchors.fill: parent
                            anchors.margins: new_size_popup.space
                            spacing: new_size_popup.space
                            TextField {
                                id: width_input
                                height: new_size_popup.item_h
                                width: parent.width
                                property int max_width: 3840
                                placeholderText: "max " + max_width
                                text: img.sourceSize.width
                                validator: IntValidator{bottom: 1; top: width_input.max_width;}
                            }
                            TextField {
                                id: height_input
                                height: new_size_popup.item_h
                                width: parent.width
                                property int max_height: 2160
                                placeholderText: "max " + max_height
                                text: img.sourceSize.height
                                wrapMode: TextInput.WrapAnywhere
                                validator: IntValidator{bottom: 1; top: height_input.max_height;}
                            }
                            Button {
                                height: new_size_popup.item_h
                                width: parent.width
                                text: "Ok"
                                onClicked: {
                                    if(width_input.acceptableInput && height_input.acceptableInput) {
                                        image_handler.resize(width_input.text, height_input.text)
                                        new_size_popup.close()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Row {
                width: parent.width
                height: parent.row_height
                spacing: parent.space_between_btns_in_row
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: "HOG"
                    enabled: !image_handler.is_busy_indicator_running && image_handler.is_hog_enable
                    onClicked: {
                        image_handler.hog()
                    }
                }
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: "CNN"
                    enabled: !image_handler.is_busy_indicator_running && image_handler.is_cnn_enable
                    onClicked: {
                        image_handler.cnn()
                    }
                }
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: "HOG + CNN"
                    enabled: !image_handler.is_busy_indicator_running && image_handler.is_hog_enable && image_handler.is_cnn_enable
                    onClicked: {
                        image_handler.hog_and_cnn()
                    }
                }
            }
            Row {
                width: parent.width
                height: parent.row_height
                spacing: parent.space_between_btns_in_row
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: "extract face(s)"
                    enabled: !image_handler.is_busy_indicator_running && image_handler.is_extract_faces_enable
                    onClicked: {
                        image_handler.extract_face()
                    }
                }
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: "cancel"
                    enabled: !image_handler.is_busy_indicator_running && image_handler.is_cancel_enabled
                    onClicked: {
                        image_handler.cancel_last_action()
                    }
                }
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: "add"
                    enabled: !image_handler.is_busy_indicator_running && image_handler.is_add_face_enable
                    onClicked: {
                        if(individual_file_manager.add_face(image_handler.get_src_img(), image_handler.get_extr_face_img())) {
                            selected_imgs.set_curr_img_index(selected_imgs_list_view.currentIndex)
                        }
                    }
                }
            }
        }
    }

    Button {
        id: finish_btn
        anchors {
            horizontalCenter: extr_faces_frame.horizontalCenter
            top: extr_faces_frame.bottom
            topMargin: 10
        }
        width: 200
        height: 50
        text: "Finish"
        enabled: !image_handler.is_busy_indicator_running && extracted_faces_list_view.count > 0
        onClicked: {
            nickname_input_page.is_delete_individual_dirs = false
            stack_view.pop(null, StackView.Immediate)
        }
    }
}
