import QtQuick 2.12
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import "../common"

Rectangle {
    radius: 2

    property alias src_img: src_img
    property alias extr_face_img: extr_face_img

    property alias delete_btn_m_area: delete_btn_m_area

    property alias img_number: img_number
    property alias src_img_wrapper: src_img_wrapper
    property alias extr_face_img_wrapper: extr_face_img_wrapper
    property alias delete_btn_wrapper: delete_btn_wrapper

    property var parent_obj

    color: "transparent"
    Text {
        id: img_number
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        fontSizeMode: Text.Fit
        minimumPointSize: 1
        font.pointSize: 10
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        text: index + 1
    }
    Item {
        id: src_img_wrapper
        height: parent.height
        anchors {
            left: img_number.right
        }
        Image {
            id: src_img
            anchors {
                centerIn: parent
            }
            property int top_and_bot_margins: 4
            height: parent.height - top_and_bot_margins
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
                    parent_obj.full_screen_window = parent_obj.full_screen_window_comp.createObject(null, { img_source: src_img.source })
                    parent_obj.full_screen_window.show()
                }
            }
        }
    }
    Item {
        id: extr_face_img_wrapper
        height: parent.height
        anchors {
            left:  src_img_wrapper.right
        }
        Image {
            id: extr_face_img
            anchors {
                centerIn: parent
            }
            height: parent.height - src_img.top_and_bot_margins
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
                    parent_obj.full_screen_window = parent_obj.full_screen_window_comp.createObject(null, { img_source: extr_face_img.source })
                    parent_obj.full_screen_window.show()
                }
            }
        }
    }
    Item {
        id: delete_btn_wrapper
        height: parent.height
        anchors {
            left: extr_face_img_wrapper.right
        }
        Image {
            id: delete_btn
            anchors {
                centerIn: parent
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

}
