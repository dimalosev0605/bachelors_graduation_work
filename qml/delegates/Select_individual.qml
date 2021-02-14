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

    property alias body_m_area: body_m_area

    property var full_screen_avatar_var: Qt.createComponent("qrc:/qml/common/Full_screen_img.qml")

    MouseArea {
        id: body_m_area
        anchors.fill: parent
        hoverEnabled: true
    }

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
}
