import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../common"
import "../../delegates"

import Selected_imgs_qml 1.0
import Image_handler_qml 1.0

Page {
    Keys.onEscapePressed: {
        stack_view.pop(StackView.Immediate)
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
            width: parent.width
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            fontSizeMode: Text.Fit
            minimumPointSize: 1
            font.pointSize: 10
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            text: "img source and resolution"
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
                anchors.fill: parent
                onClicked: {
                    var win = full_screen_img_var.createObject(null, { img_source: img.source, view: all_imgs_list_view })
                    win.show()
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
            text: "Extracted faces for: blabla"
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
                    text: "HOG"
                }
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: "CNN"
                }
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: "HOG + CNN"
                }
            }
            Row {
                width: parent.width
                height: parent.row_height
                spacing: parent.space_between_btns_in_row
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: "pyr up"
                }
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: "pyr down"
                }
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: "resize"
                }
            }
            Row {
                width: parent.width
                height: parent.row_height
                spacing: parent.space_between_btns_in_row
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: "extract face"
                }
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: "cancel"
                }
                Button {
                    height: parent.height
                    width: btns_col.btn_width
                    text: "add"
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
    }
}
