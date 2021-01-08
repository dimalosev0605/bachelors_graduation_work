import QtQuick 2.12
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import "../common"

Rectangle {
    radius: 2

    property alias src_img_path: src_img.source
    property alias extr_face_img_path: extr_face_img.source

    property var full_screen_img_var: Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")

    color: "transparent"

    Image {
        id: src_img
        anchors {
            right: parent.right
            rightMargin: 2
            top: parent.top
            topMargin: 2
            bottom: parent.bottom
            bottomMargin: 2
        }
        height: parent.height - anchors.topMargin - anchors.bottomMargin
        width: height
        asynchronous: true
        mipmap: true
        scale: src_img_m_area.containsMouse ? 1.1 : 1.0
        fillMode: Image.PreserveAspectCrop
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: src_img.width
                height: src_img.height
                radius: 5
            }
        }
        MouseArea {
            id: src_img_m_area
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                var win = full_screen_img_var.createObject(null, { img_source: src_img.source })
                win.show()
            }
        }
    }
    Image {
        id: extr_face_img
        anchors {
            left: parent.left
            leftMargin: src_img.anchors.rightMargin
            top: parent.top
            topMargin: src_img.anchors.topMargin
            bottom: parent.bottom
            bottomMargin: src_img.anchors.bottomMargin
        }
        height: parent.height - anchors.topMargin - anchors.bottomMargin
        width: height
        asynchronous: true
        mipmap: true
        scale: extr_face_img_m_area.containsMouse ? 1.1 : 1.0
        fillMode: Image.PreserveAspectCrop
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: extr_face_img.width
                height: extr_face_img.height
                radius: 5
            }
        }
        MouseArea {
            id: extr_face_img_m_area
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                var win = full_screen_img_var.createObject(null, { img_source: extr_face_img.source })
                win.show()
            }
        }
    }
}
