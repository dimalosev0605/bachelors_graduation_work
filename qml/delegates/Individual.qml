import QtQuick 2.12
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.12


import "../common"

Rectangle {
    Material.theme: Style_control.is_dark_mode_on ? Material.Dark : Material.Light
    Universal.theme: Style_control.is_dark_mode_on ? Universal.Dark : Universal.Light

    property alias avatar: avatar

    property alias number: number
    property alias avatar_wrapper: avatar_wrapper
    property alias nickname: nickname
    property alias count_of_faces: count_of_faces
    property alias delete_btn_wrapper: delete_btn_wrapper

    property alias delete_btn_m_area: delete_btn_m_area
    property alias body_m_area: body_m_area

    property var parent_obj

    color: {
        if(Style_control.get_style() === "Material") {
            body_m_area.containsMouse ? body_m_area.pressed ?
            Material.foreground : Qt.lighter(Material.background, Style_control.is_dark_mode_on ? 1.5 : 0.5) : Material.background
        }
        else if(Style_control.get_style() === "Universal") {
            body_m_area.containsMouse ? body_m_area.pressed ?
            Universal.foreground : Qt.lighter(Universal.background, Style_control.is_dark_mode_on ? 1.5 : 0.5) : Universal.background
        }
        else {
            body_m_area.containsMouse ? body_m_area.pressed ? "#999999" : "#d4d4d4" : "#ffffff"
        }
    }

    MouseArea {
        id: body_m_area
        anchors.fill: parent
        hoverEnabled: true
    }

    Label {
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
        color: {
            if(Style_control.get_style() === "Material") {
                body_m_area.containsMouse ? body_m_area.pressed ?
                Material.background : Qt.lighter(Material.foreground, Style_control.is_dark_mode_on ? 0.5 : 1.5) : Material.foreground
            }
            else if(Style_control.get_style() === "Universal") {
                body_m_area.containsMouse ? body_m_area.pressed ?
                Universal.background : Qt.lighter(Universal.foreground, Style_control.is_dark_mode_on ? 0.5 : 1.5) : Universal.foreground
            }
            else {
                "#000000"
            }
        }
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
                    parent_obj.full_screen_window = parent_obj.full_screen_window_comp.createObject(null, { img_source: avatar.source })
                    parent_obj.full_screen_window.show()
                }
            }
        }
    }
    Label {
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
        color: {
            if(Style_control.get_style() === "Material") {
                body_m_area.containsMouse ? body_m_area.pressed ?
                Material.background : Qt.lighter(Material.foreground, Style_control.is_dark_mode_on ? 0.5 : 1.5) : Material.foreground
            }
            else if(Style_control.get_style() === "Universal") {
                body_m_area.containsMouse ? body_m_area.pressed ?
                Universal.background : Qt.lighter(Universal.foreground, Style_control.is_dark_mode_on ? 0.5 : 1.5) : Universal.foreground
            }
            else {
                "#000000"
            }
        }
    }
    Label {
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
        color: {
            if(Style_control.get_style() === "Material") {
                body_m_area.containsMouse ? body_m_area.pressed ?
                Material.background : Qt.lighter(Material.foreground, Style_control.is_dark_mode_on ? 0.5 : 1.5) : Material.foreground
            }
            else if(Style_control.get_style() === "Universal") {
                body_m_area.containsMouse ? body_m_area.pressed ?
                Universal.background : Qt.lighter(Universal.foreground, Style_control.is_dark_mode_on ? 0.5 : 1.5) : Universal.foreground
            }
            else {
                "#000000"
            }
        }
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
            source: {
                if(delete_btn_m_area.containsMouse) {
                    "qrc:/qml/icons/red_cross.png"
                }
                else {
                    if(Style_control.get_style() === "Universal") {
                        Style_control.is_dark_mode_on ? body_m_area.pressed ? "qrc:/qml/icons/black_cross.png" : "qrc:/qml/icons/white_cross.png" : body_m_area.pressed ? "qrc:/qml/icons/white_cross.png" : "qrc:/qml/icons/black_cross.png"
                    }
                    else if (Style_control.get_style() === "Material") {
                        Style_control.is_dark_mode_on ? body_m_area.pressed ? "qrc:/qml/icons/black_cross.png" : "qrc:/qml/icons/white_cross.png" : body_m_area.pressed ? "qrc:/qml/icons/white_cross.png" : "qrc:/qml/icons/black_cross.png"
                    }
                    else {
                        "qrc:/qml/icons/black_cross"
                    }
                }
            }
            MouseArea {
                id: delete_btn_m_area
                anchors.fill: parent
                hoverEnabled: true
            }
        }
    }
}
