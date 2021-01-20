import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../common"
import "../../delegates"

Page {
    Keys.onEscapePressed: {
        individual_file_manager.delete_all_faces()
        stack_view.pop(StackView.Immediate)
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
            individual_file_manager.delete_all_faces()
            stack_view.pop(StackView.Immediate)
        }
    }
    Button {
        id: finish_btn
        anchors {
            right: parent.right
            rightMargin: 5
            bottom: parent.bottom
            bottomMargin: 5
        }
        width: 140
        height: 30
        text: "Finish"
        enabled: extracted_faces_list_view.count > 0
        onClicked: {
            stack_view.pop(null, StackView.Immediate)
        }
    }

    ListView {
        id: extracted_faces_list_view
        anchors {
            top: parent.top
            topMargin: 30
            bottom: parent.bottom
            bottomMargin: 30
            horizontalCenter: parent.horizontalCenter
        }
        width: parent.width / 2
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
