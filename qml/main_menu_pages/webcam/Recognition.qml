import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../common"
import "../../delegates"

import Video_capture_qml 1.0

Page {

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
    }

    CheckBox {
        id: is_running
        width: 50
        height: 50
        checked: false
        onCheckedChanged: {
            if(checked) {
                Image_provider.start_video_running()
                video_capture.start()
            }
            else {
                Image_provider.stop_video_running()
                video_capture.stop()
            }
        }
    }
    CheckBox {
        id: is_hog
        anchors {
            top: is_running.bottom
        }
        width: 50
        height: 50
        checked: false
        onCheckedChanged: {
            if(checked) {
                video_capture.set_is_hog(true)
            }
            else {
                video_capture.set_is_hog(false)
            }
        }
    }
    CheckBox {
        id: is_recognize
        anchors {
            top: is_hog.bottom
        }
        checked: false
        onCheckedChanged: {
            if(checked) {
                video_capture.set_is_recognize(true)
            }
            else {
                video_capture.set_is_recognize(false)
            }
        }
    }

    Slider {
        id: accuracy_slider
        anchors {
            top: is_recognize.bottom
        }
        from: 0.0
        to: 1.0
        value: 0.5
        stepSize: 0.05
        onValueChanged: {
            video_capture.set_threshold(value)
        }
    }

    Image {
        id: img
        anchors.centerIn: parent
        width: 500
        height: 500
        cache: false
        fillMode: Image.PreserveAspectFit
        property string curr_image
        source: "image://Image_provider/" + curr_image
    }

    Button {
        id: start_btn
        visible: false
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
        }
        width: 50
        height: 30
        text: "start"
        onClicked: {
            Image_provider.start_video_running()
            video_capture.start()
        }
    }
    Button {
        id: stop_btn
        visible: false
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: start_btn.top
        }
        width: 50
        height: 30
        text: "stop"
        onClicked: {
            Image_provider.stop_video_running()
            video_capture.stop()
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
