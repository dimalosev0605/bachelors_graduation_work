import QtQuick 2.12
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import Selected_imgs_qml 1.0

Rectangle {
    height: 50
    radius: 2

    property alias img_file_name: img_preview_file_name.text
    property alias img_file_path: img_preview.source

//    property alias delegate_body_m_area: delegate_body_m_area
    property alias delete_btn_m_area: delete_btn_m_area

    property ListView view
    property Selected_imgs selected_imgs_model
    property var full_screen_img

    color: view.currentIndex === index ? "#cfcfcf" : (delegate_body_m_area.containsMouse || delete_btn_m_area.containsMouse)
           ? delegate_body_m_area.pressed ? "#999999" : "#d4d4d4" : "#ffffff"

    Image {
        id: img_preview
        anchors {
            left: parent.left
            leftMargin: 5
            verticalCenter: parent.verticalCenter
        }
        property int space_between_top_and_bottom: 10
        height: parent.height - space_between_top_and_bottom
        width: height
        asynchronous: true
        mipmap: true
        scale: img_preview_m_area.containsMouse ? 1.1 : 1.0
        fillMode: Image.PreserveAspectCrop
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: img_preview.width
                height: img_preview.height
                radius: 5
            }
        }
        MouseArea {
            id: img_preview_m_area
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                selected_imgs_model.set_curr_img_index(index)
                var win = full_screen_img.createObject(null, { img_source: img_preview.source, window_type: true, view: view, selected_imgs: selected_imgs_model})
                win.show()
            }
        }
    }
    Text {
        id: img_preview_file_name
        anchors {
            left: img_preview.right
            top: img_preview.top
        }
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        height: parent.height
        width: parent.width - img_preview.width - img_preview.anchors.leftMargin - delete_btn.width - delete_btn.anchors.rightMargin
        fontSizeMode: Text.Fit
        minimumPointSize: 1
        font.pointSize: 10
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
    }
    MouseArea {
        id: delegate_body_m_area
        anchors {
            left: img_preview.right
            right: parent.right
        }
        height: parent.height
        hoverEnabled: true
    }
    Image {
        id: delete_btn
        anchors {
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        height: parent.height * 0.5
        width: height * 0.85
        mipmap: true
        asynchronous: true
        scale: delete_btn_m_area.pressed ? 1.2 : 1.0
        fillMode: Image.PreserveAspectFit
        source: delete_btn_m_area.containsMouse ? "qrc:/qml/icons/red_cross.png" : "qrc:/qml/icons/black_cross.png"
        MouseArea {
            id: delete_btn_m_area
            anchors.fill: parent
            hoverEnabled: true
        }
    }
}
