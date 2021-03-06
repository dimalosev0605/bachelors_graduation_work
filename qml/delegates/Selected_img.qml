import QtQuick 2.12
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.12

import Selected_imgs_qml 1.0
import "../common"

Rectangle {
    height: 50

    Material.theme: Style_control.is_dark_mode_on ? Material.Dark : Material.Light
    Universal.theme: Style_control.is_dark_mode_on ? Universal.Dark : Universal.Light

    property alias img_file_name: img_preview_file_name.text
    property alias img_file_path: img_preview.source

//    property alias delegate_body_m_area: delegate_body_m_area
    property alias delete_btn_m_area: delete_btn_m_area

    property var parent_obj

    border.width: 1
    border.color: {
        if(Style_control.get_style() === "Material") {
            Material.foreground
        }
        else if(Style_control.get_style() === "Universal") {
            Universal.foreground
        }
        else {
            "#000000"
        }
    }

    color: {
        if(Style_control.get_style() === "Material") {
            (delegate_body_m_area.containsMouse || delete_btn_m_area.containsMouse) ? delegate_body_m_area.pressed ?
            Material.foreground : Qt.lighter(Material.background, Style_control.is_dark_mode_on ? 1.5 : 0.5) : Material.background
        }
        else if(Style_control.get_style() === "Universal") {
            (delegate_body_m_area.containsMouse || delete_btn_m_area.containsMouse) ? delegate_body_m_area.pressed ?
            Universal.foreground : Qt.lighter(Universal.background, Style_control.is_dark_mode_on ? 1.5 : 0.5) : Universal.background
        }
        else {
            (delegate_body_m_area.containsMouse || delete_btn_m_area.containsMouse) ? delegate_body_m_area.pressed ? "#999999" : "#d4d4d4" : "#ffffff"
        }
    }

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
                parent_obj.selected_imgs_model.set_curr_img_index(index)
                parent_obj.full_screen_window = parent_obj.full_screen_window_comp.createObject(null, { img_source: img_preview.source, window_type: Full_screen_img.Window_type.With_btns, view: parent_obj.selected_imgs_list_view, selected_imgs: parent_obj.selected_imgs_model})
                parent_obj.full_screen_window.show()
            }
        }
    }
    Label {
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
        color: {
            if(Style_control.get_style() === "Material") {
                (delegate_body_m_area.containsMouse || delete_btn_m_area.containsMouse) ? delegate_body_m_area.pressed ?
                Material.background : Qt.lighter(Material.foreground, Style_control.is_dark_mode_on ? 0.5 : 1.5) : Material.foreground
            }
            else if(Style_control.get_style() === "Universal") {
                (delegate_body_m_area.containsMouse || delete_btn_m_area.containsMouse) ? delegate_body_m_area.pressed ?
                Universal.background : Qt.lighter(Universal.foreground, Style_control.is_dark_mode_on ? 0.5 : 1.5) : Universal.foreground
            }
            else {
                "#000000"
            }
        }
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
        source: {
            if(delete_btn_m_area.containsMouse) {
                "qrc:/qml/icons/red_cross.png"
            }
            else {
                if(Style_control.get_style() === "Universal") {
                    Style_control.is_dark_mode_on ? delegate_body_m_area.pressed ? "qrc:/qml/icons/black_cross.png" : "qrc:/qml/icons/white_cross.png" : delegate_body_m_area.pressed ? "qrc:/qml/icons/white_cross.png" : "qrc:/qml/icons/black_cross.png"
                }
                else if (Style_control.get_style() === "Material") {
                    Style_control.is_dark_mode_on ? delegate_body_m_area.pressed ? "qrc:/qml/icons/black_cross.png" : "qrc:/qml/icons/white_cross.png" : delegate_body_m_area.pressed ? "qrc:/qml/icons/white_cross.png" : "qrc:/qml/icons/black_cross.png"
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
