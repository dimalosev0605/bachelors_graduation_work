import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.12

import "../../common"
import "../../delegates"

import Selected_imgs_qml 1.0
import Image_handler_qml 1.0
import Individual_file_manager_qml 1.0

Page {
    id: root
    Material.theme: Style_control.is_dark_mode_on ? Material.Dark : Material.Light
    Universal.theme: Style_control.is_dark_mode_on ? Universal.Dark : Universal.Light
    property string individual_name

    Component.onCompleted: {
        console.log("individual_name = ", individual_name)
    }
    Component.onDestruction: {
        if(extracted_faces_list_view.count === 0) {
            console.log("zero faces -> delete individual.")
            individual_file_manager.delete_individual()
        }
        available_people.update()
        search_input.clear()
        Image_provider.empty_image()
    }

    Keys.onEscapePressed: {
        stack_view.pop(StackView.Immediate)
    }

    property var full_screen_window_comp: Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")
    property var full_screen_window

    property var all_imgs_list_view: all_imgs_list_view
    property var selected_imgs_model: selected_imgs

    property int group_box_b_w: 1

    Selected_imgs {
        id: selected_imgs
        onImage_changed: {
            image_handler.curr_image_changed(curr_img_path)
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
            individual_file_manager.set_individual_name(individual_name, true)
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
    GroupBox {
        id: img_frame
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        anchors {
            top: parent.top
            topMargin: 10
            left: parent.left
            leftMargin: 5
            bottom: back_btn.top
            bottomMargin: buttons_frame.height + buttons_frame.anchors.topMargin * 2
        }
        property int space_between_img_and_extr_faces: 10
        width: (parent.width - anchors.leftMargin * 2 - space_between_img_and_extr_faces) / 2
        Label {
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
            text: img.sourceSize.width + " X " + img.sourceSize.height
        }
        Button {
            id: select_imgs_btn
            anchors {
                top: parent.top
                topMargin: root.group_box_b_w
                right: parent.right
                rightMargin: root.group_box_b_w
            }
            height: img_info.height
            text: qsTr("Select")
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
                    if(Image_provider.is_null()) {
                        file_dialog.open()
                        return
                    }
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
                        full_screen_window = full_screen_window_comp.createObject(null, { img_source: img.source, view: all_imgs_list_view })
                        full_screen_window.show()
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
                text: qsTr("Cancel")
                onClicked: {
                    image_handler.cancel_processing()
                }
            }
        }
        Item {
            id: all_imgs_frame
            anchors {
                bottom: parent.bottom
                bottomMargin: root.group_box_b_w
                left: parent.left
                leftMargin: root.group_box_b_w
                right: parent.right
                rightMargin: root.group_box_b_w
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
                anchors.fill: parent
                model: selected_imgs
                orientation: ListView.Horizontal
                clip: true
                currentIndex: selected_imgs.curr_img_index
                enabled: !image_handler.is_busy_indicator_running
                delegate: Selected_img_only_img {
                    height: all_imgs_frame.height - all_imgs_list_view_scroll_bar.height
                    width: height
                    img_file_path: model.img_file_path
                    parent_obj: root
                }
                ScrollBar.horizontal: ScrollBar { id: all_imgs_list_view_scroll_bar }
            }
        }

        Button {
            id: prev_img_btn
            enabled: !image_handler.is_busy_indicator_running
            anchors {
                left: parent.left
                leftMargin: root.group_box_b_w
                top: img.top
                bottom: all_imgs_frame.top
                bottomMargin: img.anchors.bottomMargin
                right: img.left
            }
            onClicked: {
                selected_imgs.set_curr_img_index(selected_imgs.curr_img_index - 1)
            }
            display: AbstractButton.IconOnly
            icon.source: "qrc:/qml/icons/left_arrow.png"
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
                rightMargin: root.group_box_b_w
            }
            onClicked: {
                selected_imgs.set_curr_img_index(selected_imgs.curr_img_index + 1)
            }
            display: AbstractButton.IconOnly
            icon.source: "qrc:/qml/icons/right_arrow.png"
        }
    }
    GroupBox {
        id: extr_faces_frame
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        anchors {
            top: parent.top
            topMargin: img_frame.anchors.topMargin
            right: parent.right
            rightMargin: img_frame.anchors.leftMargin
            bottom: img_frame.anchors.bottom
            bottomMargin: img_frame.anchors.bottomMargin
        }
        width: img_frame.width
        Label {
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
            text: qsTr("Extracted faces for: ") + individual_name
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

                parent_obj: root

                delete_btn_m_area.onClicked: {
                    individual_file_manager.delete_face(index)
                }
            }
            header: Item {
                id: extracted_faces_table_header
                height: 40
                width: extracted_faces_list_view.width
                property int number_w: 30
                property int delete_btn_w: 50
                property real img_w: (extracted_faces_table_header.width - extracted_faces_table_header.number_w - extracted_faces_table_header.delete_btn_w) / 2
                Row {
                    anchors.fill: parent
                    Item {
                        id: image_number
                        height: parent.height
                        width: extracted_faces_table_header.number_w
                    }
                    Label {
                        width: extracted_faces_table_header.img_w
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        fontSizeMode: Text.Fit
                        minimumPointSize: 1
                        font.pointSize: 10
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                        text: qsTr("Source image")
                    }
                    Label {
                        width: extracted_faces_table_header.img_w
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        fontSizeMode: Text.Fit
                        minimumPointSize: 1
                        font.pointSize: 10
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                        text: qsTr("Extracted face")
                    }
                    Item {
                        id: delete_btn
                        height: parent.height
                        width: extracted_faces_table_header.delete_btn_w
                    }
                }
            }
        }
    }

    GroupBox {
        id: buttons_frame
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        anchors {
            horizontalCenter: img_frame.horizontalCenter
            top: img_frame.bottom
            topMargin: 5
        }
        width: img_frame.width * 0.8
        height: 150
        Column {
            id: btns_col
            anchors {
                fill: parent
                topMargin: root.group_box_b_w
                bottomMargin: root.group_box_b_w
                leftMargin: root.group_box_b_w
                rightMargin: root.group_box_b_w
            }
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
                    text: qsTr("pyr up")
                    enabled: all_imgs_list_view.count !== 0 && !image_handler.is_busy_indicator_running && image_handler.is_hog_enable
                    onClicked: {
                        image_handler.pyr_up()
                    }
                }
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: qsTr("pyr down")
                    enabled: all_imgs_list_view.count !== 0 && !image_handler.is_busy_indicator_running && image_handler.is_hog_enable
                    onClicked: {
                        image_handler.pyr_down()
                    }
                }
                Button {
                    id: resize_btn
                    height: parent.height
                    width: btns_col.btn_width
                    text: qsTr("resize")
                    enabled: all_imgs_list_view.count !== 0 && !image_handler.is_busy_indicator_running && image_handler.is_hog_enable
                    onClicked: {
                        new_size_popup.open()
                    }
                    Popup {
                        id: new_size_popup
                        visible: false
                        Column {
                            TextField {
                                id: width_input
                                property int max_width: 3840
                                placeholderText: qsTr("max ") + max_width
                                text: img.sourceSize.width
                                validator: IntValidator{bottom: 1; top: width_input.max_width;}
                            }
                            TextField {
                                id: height_input
                                property int max_height: 2160
                                placeholderText: qsTr("max ") + max_height
                                text: img.sourceSize.height
                                wrapMode: TextInput.WrapAnywhere
                                validator: IntValidator{bottom: 1; top: height_input.max_height;}
                            }
                            Button {
                                text: qsTr("Ok")
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
                    text: qsTr("HOG")
                    enabled: all_imgs_list_view.count !== 0 && !image_handler.is_busy_indicator_running && image_handler.is_hog_enable
                    onClicked: {
                        image_handler.hog()
                    }
                }
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: qsTr("CNN")
                    enabled: all_imgs_list_view.count !== 0 && !image_handler.is_busy_indicator_running && image_handler.is_cnn_enable
                    onClicked: {
                        image_handler.cnn()
                    }
                }
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: qsTr("HOG + CNN")
                    enabled: all_imgs_list_view.count !== 0 && !image_handler.is_busy_indicator_running && image_handler.is_hog_enable && image_handler.is_cnn_enable
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
                    text: qsTr("Extract face(s)")
                    enabled: !image_handler.is_busy_indicator_running && image_handler.is_extract_faces_enable
                    onClicked: {
                        image_handler.extract_face()
                    }
                }
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: qsTr("Cancel")
                    enabled: !image_handler.is_busy_indicator_running && image_handler.is_cancel_enabled
                    onClicked: {
                        image_handler.cancel_last_action()
                    }
                }
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: qsTr("Add")
                    enabled: !image_handler.is_busy_indicator_running && image_handler.is_add_face_enable
                    onClicked: {
                        if(individual_file_manager.add_face(image_handler.get_src_img(), image_handler.get_extr_face_img(), image_handler.get_face_descriptor())) {
                            selected_imgs.set_curr_img_index(all_imgs_list_view.currentIndex)
                        }
                    }
                }
            }
        }
    }
    Item {
        id: individual_name_input_wrapper
        anchors {
            top: extr_faces_frame.bottom
            topMargin: buttons_frame.anchors.topMargin
            horizontalCenter: extr_faces_frame.horizontalCenter
        }
        height: Style_control.get_style() === "Material" ? 60 : 30
        width: extr_faces_frame.width * 0.5
        TextField {
            id: individual_name_input
            width: (parent.width - change_individual_name_btn.anchors.leftMargin) * 0.7
            height: parent.height
            text: individual_name
        }
        Button {
            id: change_individual_name_btn
            anchors {
                left: individual_name_input.right
                leftMargin: 5
                verticalCenter: individual_name_input.verticalCenter
            }
            height: Style_control.get_style() === "Material" ? parent.height * 0.5 : parent.height
//            width: (parent.width - anchors.leftMargin) * 0.3
            text: qsTr("Rename")
            onClicked: {
                if(individual_name_input.text === "") {
                    message_dialog.text = "Empty name"
                    message_dialog.open()
                    return
                }
                if(individual_file_manager.rename(individual_name_input.text)) {
                    message_dialog.text = "Success"
                    message_dialog.open()
                }
                else {
                    message_dialog.text = "Not Success"
                    message_dialog.open()
                }
            }
        }
    }
    Button {
        id: finish_btn
        anchors {
            horizontalCenter: extr_faces_frame.horizontalCenter
            top: individual_name_input_wrapper.bottom
            topMargin: 10
        }
        width: 200
        height: 40
        text: extracted_faces_list_view.count === 0 ? qsTr("Delete") : qsTr("Finish")
        enabled: !image_handler.is_busy_indicator_running
        onClicked: {
            stack_view.pop(StackView.Immediate)
        }
    }
}
