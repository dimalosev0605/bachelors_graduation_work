import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.12


import "../../common"
import "../../delegates"

import Video_file_capture_qml 1.0

Page {
    id: root
    Material.theme: Style_control.is_dark_mode_on ? Material.Dark : Material.Light
    Universal.theme: Style_control.is_dark_mode_on ? Universal.Dark : Universal.Light

    property var full_screen_window_comp: Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")
    property var full_screen_window

    property int group_box_b_w: 1

    Keys.onEscapePressed: {
        if(!video_capture.get_is_running()) {
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

    Video_file_capture {
        id: video_capture
        onImg_ready: {
            Image_provider.accept_image(some_img)
            img.curr_image = Math.random().toString()
        }
        onSafe_destroy: {
            stack_view.pop(StackView.Immediate)
        }
        onEnable_start: {
            start_btn.flag = true
        }
        onVideo_info: {
            video_duration.video_duration_ = some_duration
            count_of_frames.count_of_frames_ = some_count_of_frames
            frame_width.frame_width_ = some_frame_width
            frame_height.frame_height_ = some_frame_height
            fps.fps_ = some_fps
        }
        onCurrent_progress: {
            cur_sec_pos.cur_sec_pos_ = some_sec_pos
            cur_frame_pos.cur_frame_pos_ = some_frame_pos
        }
        onWorker_thread_finished: {
            start_btn.flag = true
            Image_provider.stop_video_running()
            img.curr_image = Math.random().toString()

            video_duration.video_duration_ = 0
            count_of_frames.count_of_frames_ = 0
            frame_width.frame_width_ = 0
            frame_height.frame_height_ = 0
            fps.fps_ = 0
            cur_sec_pos.cur_sec_pos_ = 0
            cur_frame_pos.cur_frame_pos_ = 0
        }
    }

    Connections {
        id: file_dialog_connections
        target: file_dialog
        function onAccepted(fileUrl) {
            input_file_text_field.text = file_dialog.fileUrl.toString().replace("file://", "")
            input_file_text_field.create_output_file_path(input_file_text_field.text.toString())
            file_dialog.selectMultiple = true
            file_dialog.nameFilters = [ "Image files (*.jpg *.png *.jpeg)", "All files (*)" ]
            file_dialog.close()
        }
        function onRejected() {
            file_dialog.selectMultiple = true
            file_dialog.nameFilters = [ "Image files (*.jpg *.png *.jpeg)", "All files (*)" ]
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
            bottomMargin: 5
        }
        property int space_between_frames: 10
        width: (parent.width - anchors.leftMargin * 2 - space_between_frames) / 2
        Image {
            id: img
            anchors {
                top: parent.top
                topMargin: root.group_box_b_w
                bottom: parent.bottom
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
    }

    Column {
        id: info_column
        anchors {
            top: parent.top
            topMargin: img_frame.anchors.topMargin
            bottom: back_btn.top
            bottomMargin: img_frame.anchors.bottomMargin
            right: parent.right
            rightMargin: img_frame.anchors.leftMargin
        }
        width: img_frame.width
        spacing: 5
        GroupBox {
            id: file_names_frame
            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
            width: parent.width
            height: file_names_frame_title.height + input_file_text_field.height * 2 + input_file_text_field.anchors.topMargin * 3 // why 3 --> third for bottom margin.
            Label {
                id: file_names_frame_title
                anchors {
                    top: parent.top
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
                text: qsTr("Files")
            }
            TextField {
                id: input_file_text_field
                anchors {
                    top: file_names_frame_title.bottom
                    topMargin: 5
                    left: parent.left
                    leftMargin: 10
                }
                onTextChanged: {
                    create_output_file_path(input_file_text_field.text.toString())
                }
                function create_output_file_path(some_str) {
                    if(some_str === "") {
                        output_file_text_field.text = ""
                        return
                    }
                    var temp_str = some_str
                    var last_index = temp_str.lastIndexOf('/')
                    var sub_str_1 = temp_str.substring(0, last_index)
                    var sub_str_2 = temp_str.substring(last_index + 1)
                    var res = sub_str_1 + "/processed_" + sub_str_2
                    output_file_text_field.text = res
                }
                width: (parent.width - anchors.leftMargin - open_input_file_btn.width - open_input_file_btn.anchors.leftMargin * 2) * 0.7
                height: Style_control.get_style() === "Material" ? 70 : 35
                placeholderText: qsTr("Source file path")
            }
            Button {
                id: open_input_file_btn
                anchors {
                    left: input_file_text_field.right
                    leftMargin: 5
                    verticalCenter: input_file_text_field.verticalCenter
                }
                height: 30
                onClicked: {
                    file_dialog.nameFilters = "All files (*)"
                    file_dialog.selectMultiple = false
                    file_dialog.open()
                }
                text: qsTr("Open")
            }
            TextField {
                id: output_file_text_field
                anchors {
                    top: input_file_text_field.bottom
                    topMargin: input_file_text_field.anchors.topMargin
                    left: parent.left
                    leftMargin: input_file_text_field.anchors.leftMargin
                }
                readOnly: true
                width: input_file_text_field.width
                height: input_file_text_field.height
                placeholderText: qsTr("Destination file path")
            }
        }
        GroupBox {
            id: controls_frame
            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
            height: (info_column.height - file_names_frame.height - info_column.spacing * 2) / 2
            width: parent.width
            Label {
                id: controls_frame_title
                anchors {
                    top: parent.top
                }
                width: parent.width
                height: file_names_frame_title.height
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                fontSizeMode: Text.Fit
                minimumPointSize: 1
                font.pointSize: 15
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                text: qsTr("Control")
            }
            Slider {
                id: accuracy_slider
                anchors {
                    top: controls_frame_title.bottom
                    topMargin: 5
                    horizontalCenter: parent.horizontalCenter
                }
                width: parent.width / 2
                height: (parent.height - slider_value_text.height) * 0.2
                from: 0.0
                to: 1.0
                value: 0.55
                stepSize: 0.05
                onValueChanged: {
                    video_capture.set_threshold(value)
                }
            }
            Label {
                id: slider_value_text
                anchors {
                    top: accuracy_slider.bottom
                    horizontalCenter: parent.horizontalCenter
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
                id: controls_col
                anchors {
                    top: slider_value_text.bottom
                    topMargin: 5
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: 5
                height: controls_frame.height - controls_frame_title.height - accuracy_slider.height - accuracy_slider.anchors.topMargin - slider_value_text.height - anchors.topMargin
                Row {
                    id: check_boxes_row
                    spacing: 5
                    CheckBox {
                        id: is_hog
                        checked: false
                        text: qsTr("Search faces")
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
                        text: qsTr("Recognize")
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
                Row {
                    id: btns_row
                    spacing: check_boxes_row.spacing
                    Button {
                        id: start_btn
                        text: qsTr("Start")
                        width: is_hog.width
                        property bool flag: false
                        enabled: input_file_text_field.text !== "" && output_file_text_field.text !== "" && flag
                        height: {
                            var temp = (controls_col.height - controls_col.spacing - check_boxes_row.height)
                            temp > 30 ? 30 : temp
                        }
                        onClicked: {
                            Image_provider.start_video_running()
                            video_capture.start(input_file_text_field.text, output_file_text_field.text)
                            start_btn.flag = false
                        }
                    }
                    Button {
                        id: stop_btn
                        text: qsTr("Stop")
                        enabled: input_file_text_field.text !== "" && output_file_text_field.text !== "" && !start_btn.flag
                        width: start_btn.width
                        height: start_btn.height
                        onClicked: {
                            Image_provider.stop_video_running()
                            video_capture.stop()
                            img.curr_image = Math.random().toString()

                            video_duration.video_duration_ = 0
                            count_of_frames.count_of_frames_ = 0
                            frame_width.frame_width_ = 0
                            frame_height.frame_height_ = 0
                            fps.fps_ = 0
                            cur_sec_pos.cur_sec_pos_ = 0
                            cur_frame_pos.cur_frame_pos_ = 0
                        }
                    }
                }
            }
        }
        GroupBox {
            id: progress_frame
            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
            height: controls_frame.height
            width: parent.width
            Label {
                id: progress_frame_title
                anchors {
                    top: parent.top
                }
                width: parent.width
                height: file_names_frame_title.height
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                fontSizeMode: Text.Fit
                minimumPointSize: 1
                font.pointSize: 15
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                text: qsTr("Progress")
            }
            Column {
                id: progress_labels_col
                anchors {
                    top: progress_frame_title.bottom
                    topMargin: 5
                    bottom: parent.bottom
                    bottomMargin: anchors.topMargin
                    left: parent.left
                    leftMargin: 5
                    right: parent.right
                    rightMargin: anchors.leftMargin
                }
                property int count: 7
                property real item_h: (progress_labels_col.height - (progress_labels_col.count - 1) * spacing) / progress_labels_col.count
                spacing: 2
                Label {
                    id: video_duration
                    width: parent.width
                    height: progress_labels_col.item_h
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    fontSizeMode: Text.Fit
                    minimumPointSize: 1
                    font.pointSize: 15
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    property real video_duration_
                    text: qsTr("Video duration: ") + video_duration_.toFixed(1)
                }
                Label {
                    id: count_of_frames
                    width: parent.width
                    height: progress_labels_col.item_h
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    fontSizeMode: Text.Fit
                    minimumPointSize: 1
                    font.pointSize: 15
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    property int count_of_frames_
                    text: qsTr("Number of frames in the video file: ") + count_of_frames_
                }
                Label {
                    id: frame_width
                    width: parent.width
                    height: progress_labels_col.item_h
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    fontSizeMode: Text.Fit
                    minimumPointSize: 1
                    font.pointSize: 15
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    property int frame_width_
                    text: qsTr("Width of the frames in the video stream: ") + frame_width_
                }
                Label {
                    id: frame_height
                    width: parent.width
                    height: progress_labels_col.item_h
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    fontSizeMode: Text.Fit
                    minimumPointSize: 1
                    font.pointSize: 15
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    property int frame_height_
                    text: qsTr("Height of the frames in the video stream: ") + frame_height_
                }
                Label {
                    id: fps
                    width: parent.width
                    height: progress_labels_col.item_h
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    fontSizeMode: Text.Fit
                    minimumPointSize: 1
                    font.pointSize: 15
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    property int fps_
                    text: qsTr("Frame rate: ") + fps_
                }
                Label {
                    id: cur_sec_pos
                    width: parent.width
                    height: progress_labels_col.item_h
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    fontSizeMode: Text.Fit
                    minimumPointSize: 1
                    font.pointSize: 15
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    property real cur_sec_pos_
                    text: qsTr("Current position of the video file in seconds: ") + cur_sec_pos_.toFixed(1)
                }
                Label {
                    id: cur_frame_pos
                    width: parent.width
                    height: progress_labels_col.item_h
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    fontSizeMode: Text.Fit
                    minimumPointSize: 1
                    font.pointSize: 15
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    property int cur_frame_pos_
                    text: qsTr("Current frame of the video: ") + cur_frame_pos_
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
            if(!video_capture.get_is_running()) {
                stack_view.pop(StackView.Immediate)
                return
            }
            video_capture.exit()
        }
    }
}
