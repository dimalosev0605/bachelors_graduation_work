import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.12


import "../../common"
import "../../delegates"

import Selected_imgs_qml 1.0
import Recognition_image_handler_qml 1.0

Page {
    id: root
    Material.theme: Style_control.is_dark_mode_on ? Material.Dark : Material.Light
    Universal.theme: Style_control.is_dark_mode_on ? Universal.Dark : Universal.Light

    property var full_screen_window_comp: Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")
    property var full_screen_window

    property var all_imgs_list_view: all_imgs_list_view
    property var selected_imgs_model: selected_imgs

    property int group_box_b_w: 1

    Keys.onEscapePressed: {
        stack_view.pop(StackView.Immediate)
    }

    Component.onDestruction: {
        Image_provider.empty_image()
    }
    Component.onCompleted: {
        recognition_image_handler.accept_selected_people(selected_people.get_selected_names())
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

    Recognition_image_handler {
        id: recognition_image_handler
        onImage_data_ready: {
            Image_provider.accept_image_data(some_img_data)
            img.curr_image = Math.random().toString()
        }
    }

    Selected_imgs {
        id: selected_imgs
        onImage_changed: {
            recognition_image_handler.curr_image_changed(curr_img_path)
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
            bottomMargin: buttons_frame.height + buttons_frame.anchors.topMargin * 2 + accuracy_slider.height + accuracy_slider.anchors.topMargin + recognize_btn.height + recognize_btn.anchors.topMargin
        }
        property int space_between_frames: 10
        width: (parent.width - anchors.leftMargin * 2 - space_between_frames) / 2
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
                    full_screen_window = full_screen_window_comp.createObject(null, { img_source: img.source, view: all_imgs_list_view })
                    full_screen_window.show()
                }
            }
            BusyIndicator {
                id: busy_indicator
                anchors.centerIn: parent
                width: parent.width * 0.4
                height: parent.height * 0.4
                visible: recognition_image_handler.is_busy_indicator_running
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
                    recognition_image_handler.cancel_processing()
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
                enabled: !recognition_image_handler.is_busy_indicator_running
                delegate: Selected_img_only_img {
                    height: all_imgs_frame.height - all_imgs_list_view_scroll_bar.height
                    width: height
                    img_file_path: model.img_file_path
                    parent_obj: root
                }
                onCountChanged: {
                    if(count === 0) {
                        Image_provider.empty_image()
                        img.curr_image = Math.random().toString()
                    }
                }
                ScrollBar.horizontal: ScrollBar { id: all_imgs_list_view_scroll_bar }
            }
        }

        Button {
            id: prev_img_btn
            enabled: !recognition_image_handler.is_busy_indicator_running
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
            enabled: !recognition_image_handler.is_busy_indicator_running
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
    Slider {
        id: accuracy_slider
        anchors {
            horizontalCenter: img_frame.horizontalCenter
            top: img_frame.bottom
            topMargin: 5
        }
        from: 0.0
        to: 1.0
        value: 0.5
        stepSize: 0.05
        onValueChanged: {
            recognition_image_handler.set_threshold(value)
        }
    }
    Button {
        id: recognize_btn
        anchors {
            top: accuracy_slider.bottom
            topMargin: 5
            horizontalCenter: accuracy_slider.horizontalCenter
        }
        enabled: all_imgs_list_view.count !== 0 && recognition_image_handler.is_auto_recognize ? recognition_image_handler.is_recognize_enable && !recognition_image_handler.is_busy_indicator_running : recognition_image_handler.is_recognize_enable && !recognition_image_handler.is_busy_indicator_running && !recognition_image_handler.is_hog_enable && !recognition_image_handler.is_cnn_enable
        width: img_frame.width * 0.2
        height: 30
        text: qsTr("Recognize " + accuracy_slider.value.toFixed(2))
        onClicked: {
            if(recognition_image_handler.is_auto_recognize) {
                recognition_image_handler.auto_recognize()
            }
            else {
                recognition_image_handler.recognize()
            }
        }
    }
    Button {
        id: is_controls_visible_btn
        anchors {
            bottom: recognize_btn.bottom
            left: recognize_btn.right
            leftMargin: 2
        }
        width: height
        height: recognize_btn.height
        enabled: !recognition_image_handler.is_busy_indicator_running
        onClicked: {
            if(recognition_image_handler.is_auto_recognize) {
                recognition_image_handler.is_auto_recognize = false
            }
            else {
                recognition_image_handler.is_auto_recognize = true
            }
            // crutch
            if(all_imgs_list_view.count === 0) {
                Image_provider.empty_image()
                img.curr_image = Math.random().toString()
            }
        }
        display: AbstractButton.IconOnly
        icon.source: recognition_image_handler.is_auto_recognize ? "qrc:/qml/icons/down_arrow.png" : "qrc:/qml/icons/up_arrow.png"
    }

    GroupBox {
        id: buttons_frame
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        anchors {
            horizontalCenter: img_frame.horizontalCenter
            top: recognize_btn.bottom
            topMargin: 5
        }
        visible: !recognition_image_handler.is_auto_recognize
        width: img_frame.width * 0.8
        height: 100
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
                    enabled: all_imgs_list_view.count !== 0 && !recognition_image_handler.is_busy_indicator_running && recognition_image_handler.is_hog_enable
                    onClicked: {
                        recognition_image_handler.pyr_up()
                    }
                }
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: qsTr("pyr down")
                    enabled: all_imgs_list_view.count !== 0 && !recognition_image_handler.is_busy_indicator_running && recognition_image_handler.is_hog_enable
                    onClicked: {
                        recognition_image_handler.pyr_down()
                    }
                }
                Button {
                    id: resize_btn
                    height: parent.height
                    width: btns_col.btn_width
                    text: qsTr("resize")
                    enabled: all_imgs_list_view.count !== 0 && !recognition_image_handler.is_busy_indicator_running && recognition_image_handler.is_hog_enable
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
                    enabled: all_imgs_list_view.count !== 0 && !recognition_image_handler.is_busy_indicator_running && recognition_image_handler.is_hog_enable
                    onClicked: {
                        recognition_image_handler.hog()
                    }
                }
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: qsTr("CNN")
                    enabled: all_imgs_list_view.count !== 0 && !recognition_image_handler.is_busy_indicator_running && recognition_image_handler.is_cnn_enable
                    onClicked: {
                        recognition_image_handler.cnn()
                    }
                }
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: qsTr("HOG + CNN")
                    enabled: all_imgs_list_view.count !== 0 && !recognition_image_handler.is_busy_indicator_running && recognition_image_handler.is_hog_enable && recognition_image_handler.is_cnn_enable
                    onClicked: {
                        recognition_image_handler.hog_and_cnn()
                    }
                }
            }
            Button {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                height: parent.row_height
                width: btns_col.btn_width
                text: qsTr("Cancel")
                enabled: !recognition_image_handler.is_busy_indicator_running && recognition_image_handler.is_cancel_enabled
                onClicked: {
                    recognition_image_handler.cancel_last_action()
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
            top: parent.top
            topMargin: img_frame.anchors.topMargin
            bottom: back_btn.top
            bottomMargin: img_frame.anchors.bottomMargin
            right: parent.right
            rightMargin: img_frame.anchors.leftMargin
        }
        width: img_frame.width
        TextField {
            id: search_selected_people_input
            anchors {
                top: parent.top
                topMargin: 5
                horizontalCenter: parent.horizontalCenter
            }
            width: 150
            height: Style_control.get_style() === "Material" ? 70 : 35
            placeholderText: qsTr("Search")
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
                }
            }
            header: Item {
                id: selected_people_list_view_header
                height: 40
                width: selected_people_list_view.width - selected_people_list_view_scroll_bar.width
                property real number_w: 40
                property real avatar_w: (parent.width - number_w) * 0.25
                property real nickname_w: (parent.width - number_w) * 0.5
                property real count_of_faces_w: (parent.width - number_w) * 0.25
                Row {
                    anchors.fill: parent
                    Label {
                        id: number
                        height: parent.height
                        width: selected_people_list_view_header.number_w
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
                        width: selected_people_list_view_header.avatar_w
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
                        width: selected_people_list_view_header.nickname_w
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
                        width: selected_people_list_view_header.count_of_faces_w
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
}
