import QtQuick 2.12
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0


import "../common"

Rectangle {
    radius: 2
    color: "transparent"

    property alias avatar: avatar

    property alias number: number
    property alias avatar_wrapper: avatar_wrapper
    property alias nickname: nickname
    property alias count_of_faces: count_of_faces
    property alias delete_btn_wrapper: delete_btn_wrapper

    property alias delete_btn_m_area: delete_btn_m_area

    property var full_screen_avatar_var: Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")

    Text {
        id: number
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
        id: avatar_wrapper
        height: parent.height
        anchors {
            left: number.right
        }
        Image {
            id: avatar
            anchors {
                centerIn: parent
            }
            property int top_and_bot_margins: 4
            height: parent.height - top_and_bot_margins
            width: height
            asynchronous: true
            mipmap: true
            scale: avatar_m_area.containsMouse ? 1.1 : 1.0
            fillMode: Image.PreserveAspectCrop
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: avatar.width
                    height: avatar.height
                    radius: 5
                }
            }
            MouseArea {
                id: avatar_m_area
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    var win = full_screen_avatar_var.createObject(null, { img_source: avatar.source })
                    win.show()
                }
            }
        }
    }
    Text {
        id: nickname
        anchors {
            left: avatar_wrapper.right
        }
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        fontSizeMode: Text.Fit
        minimumPointSize: 1
        font.pointSize: 10
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
    }
    Text {
        id: count_of_faces
        anchors {
            left: nickname.right
        }
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        fontSizeMode: Text.Fit
        minimumPointSize: 1
        font.pointSize: 10
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
    }
    Item {
        id: delete_btn_wrapper
        height: parent.height
        anchors {
            left: count_of_faces.right
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
