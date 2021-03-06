import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.12

import "../../common"
import "../../delegates"

Page {
    id: root
    Material.theme: Style_control.is_dark_mode_on ? Material.Dark : Material.Light
    Universal.theme: Style_control.is_dark_mode_on ? Universal.Dark : Universal.Light

    property var full_screen_window_comp: Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")
    property var full_screen_window

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
        height: back_btn.height
        text: qsTr("Finish")
        enabled: extracted_faces_list_view.count > 0
        onClicked: {
            nickname_input_page.is_delete_individual_dirs = false
            stack_view.pop(null, StackView.Immediate)
        }
    }

    Label {
        id: title_lbl
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
        text: qsTr("Check extracted faces and press \"Finish\" button")
    }
    ListView {
        id: extracted_faces_list_view
        anchors {
            top: title_lbl.bottom
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
