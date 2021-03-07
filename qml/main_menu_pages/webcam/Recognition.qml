import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.12

import "../../common"
import "../../delegates"

import Video_capture_qml 1.0

Page {
    id: root
    Material.theme: Style_control.is_dark_mode_on ? Material.Dark : Material.Light
    Universal.theme: Style_control.is_dark_mode_on ? Universal.Dark : Universal.Light

    property var full_screen_window_comp: Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")
    property var full_screen_window

    property int group_box_b_w: 1

    Keys.onEscapePressed: {
        if(!is_running.checked) {
            stack_view.pop(StackView.Immediate)
            return
        }
        video_capture.exit()
    }

    Component.onDestruction: {
        Image_provider.empty_image()
        Image_provider.start_video_running()
    }

    Component.onCompleted: {
        video_capture.accept_selected_people(selected_people.get_selected_names())
    }

    Video_capture {
        id: video_capture
        onImg_ready: {
            Image_provider.accept_image(some_img)
            img.curr_image = Math.random().toString()
        }
        onSafe_destroy: {
            stack_view.pop(StackView.Immediate)
        }
        onEnable_hog_searching: {
            is_hog.enabled = true
        }
        onEnable_face_recognition: {
            is_recognize.enabled = true
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
            bottomMargin: 5
        }
        property int space_between_frames: 10
        width: (parent.width - anchors.leftMargin * 2 - space_between_frames) / 2
        Image {
            id: img
            anchors {
                top: parent.top
                topMargin: root.group_box_b_w
                bottom: buttons_frame.top
                bottomMargin: root.group_box_b_w
                left: parent.left
                leftMargin: root.group_box_b_w
                right: parent.right
                rightMargin: root.group_box_b_w
            }
            cache: false
            fillMode: Image.PreserveAspectFit
            property string curr_image
            source: "image://Image_provider/" + curr_image
            signal update_full_screen_img(string source)
            onSourceChanged: {
                img.update_full_screen_img(img.source)
            }
            MouseArea {
                anchors.centerIn: parent
                width: img.paintedWidth
                height: img.paintedHeight
                onClicked: {
                    if(Image_provider.is_null()) {
                        return
                    }
                    full_screen_window = full_screen_window_comp.createObject(null, { img_source: img.source, source_image: img })
                    full_screen_window.show()
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
                bottom: parent.bottom
            }
            height: 90
            width: parent.width
            Slider {
                id: accuracy_slider
                width: parent.width / 2
                height: parent.height - slider_value_text.height
                from: 0.0
                to: 1.0
                value: 0.5
                stepSize: 0.05
                onValueChanged: {
                    video_capture.set_threshold(value)
                }
            }
            Label {
                id: slider_value_text
                anchors {
                    top: accuracy_slider.bottom
                }
                height: 30
                width: accuracy_slider.width
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                fontSizeMode: Text.Fit
                minimumPointSize: 1
                font.pointSize: 10
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                text: accuracy_slider.value.toFixed(2)
            }
            Column {
                id: check_boxes_col
                anchors {
                    left: accuracy_slider.right
                }
                height: parent.height
                width: accuracy_slider.width
                property int count_of_elems: 3
                property real check_box_h: height / count_of_elems
                CheckBox {
                    id: is_running
                    checked: false
                    height: check_boxes_col.check_box_h
                    text: qsTr("Running")
                    onCheckedChanged: {
                        if(checked) {
                            Image_provider.start_video_running()
                            video_capture.start()
                        }
                        else {
                            Image_provider.stop_video_running()
                            video_capture.stop()
                            is_hog.checked = false
                            is_recognize.checked = false
                        }
                    }
                }
                CheckBox {
                    id: is_hog
                    checked: false
                    height: check_boxes_col.check_box_h
                    text: qsTr("Search faces")
                    enabled: false
                    onCheckedChanged: {
                        if(checked) {
                            video_capture.set_is_hog(true)
                        }
                        else {
                            is_recognize.checked = false
                            video_capture.set_is_hog(false)
                        }
                    }
                }
                CheckBox {
                    id: is_recognize
                    checked: false
                    height: check_boxes_col.check_box_h
                    text: qsTr("Recognize")
                    enabled: false
                    onCheckedChanged: {
                        if(checked) {
                            is_hog.checked = true
                            video_capture.set_is_recognize(true)
                        }
                        else {
                            video_capture.set_is_recognize(false)
                        }
                    }
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
            ScrollBar.vertical: ScrollBar { id: selected_people_list_view_scroll_bar }
            header: Item {
                id: selected_people_list_view_header
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

    Back_btn {
        id: back_btn
        anchors {
            bottom: parent.bottom
            bottomMargin: 5
            left: parent.left
            leftMargin: 5
        }
        onClicked: {
            if(!is_running.checked) {
                stack_view.pop(StackView.Immediate)
                return
            }
            video_capture.exit()
        }
    }

}
