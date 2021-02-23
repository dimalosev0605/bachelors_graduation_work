import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../common"
import "../../delegates"

import Video_capture_qml 1.0

Page {

    property var full_screen_img_var: Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")
    property var win

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

    Rectangle {
        id: img_frame
        anchors {
            top: parent.top
            topMargin: 10
            left: parent.left
            leftMargin: 5
            bottom: back_btn.top
            bottomMargin: 5
        }
        color: "#00ff00"
        property int space_between_frames: 10
        width: (parent.width - anchors.leftMargin * 2 - space_between_frames) / 2
        Image {
            id: img
            anchors {
                top: parent.top
                bottom: buttons_frame.top
                left: parent.left
                right: parent.right
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
                    win = full_screen_img_var.createObject(null, { img_source: img.source, source_image: img })
                    win.show()
                }
            }
        }
        Rectangle {
            id: buttons_frame
            anchors {
                bottom: parent.bottom
            }
            height: 90
            width: parent.width
            color: "red"
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
            Text {
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
                    text: "Running"
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
                    text: "Search faces"
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
                    text: "Recognize"
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
    Rectangle {
        id: selected_people_frame
        anchors {
            top: parent.top
            topMargin: img_frame.anchors.topMargin
            bottom: back_btn.top
            bottomMargin: img_frame.anchors.bottomMargin
            right: parent.right
            rightMargin: img_frame.anchors.leftMargin
        }
        width: img_frame.width
        color: "yellow"
        TextField {
            id: search_selected_people_input
            anchors {
                top: parent.top
                topMargin: 5
                horizontalCenter: parent.horizontalCenter
            }
            width: 150
            height: 30
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
            }
            width: parent.width
            clip: true
            currentIndex: -1
            model: selected_people
            delegate: Select_individual {
                width: selected_people_list_view.width
                height: 40

                number.width: selected_people_list_view.headerItem.number_w
                avatar_wrapper.width: selected_people_list_view.headerItem.avatar_w
                nickname.width: selected_people_list_view.headerItem.nickname_w
                count_of_faces.width: selected_people_list_view.headerItem.count_of_faces_w

                avatar.source: "file://" + model.avatar_path
                count_of_faces.text: model.count_of_faces
                nickname.text: model.individual_name

                body_m_area.onClicked: {
                }
            }
            header: Rectangle {
                id: selected_people_list_view_header
                border.width: 1
                border.color: "#000000"
                height: 40
                width: selected_people_list_view.width
                property real number_w: 40
                property real avatar_w: (parent.width - number_w) * 0.25
                property real nickname_w: (parent.width - number_w) * 0.5
                property real count_of_faces_w: (parent.width - number_w) * 0.25
                Row {
                    anchors.fill: parent
                    Text {
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
                        text: "Number"
                    }
                    Text {
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
                        text: "Avatar"
                    }
                    Text {
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
                        text: "Nickname"
                    }
                    Text {
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
                        text: "Number of \nfaces"
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
