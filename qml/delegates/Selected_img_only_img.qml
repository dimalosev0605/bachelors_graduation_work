import QtQuick 2.12
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.12

import Selected_imgs_qml 1.0
import "../common"

Rectangle {
    radius: 5

    Material.theme: Style_control.is_dark_mode_on ? Material.Dark : Material.Light
    Universal.theme: Style_control.is_dark_mode_on ? Universal.Dark : Universal.Light

    property alias img_file_path: img_preview.source
    property var parent_obj

    color: {
        if(Style_control.get_style() === "Material") {
            parent_obj.all_imgs_list_view.currentIndex === index ? Material.foreground : Material.background
        } else if(Style_control.get_style() === "Universal") {
            parent_obj.all_imgs_list_view.currentIndex === index ? Universal.foreground : Universal.background
        }
        else {
            parent_obj.all_imgs_list_view.currentIndex === index ? "gray" : "transparent"
        }
    }

    Image {
        id: img_preview
        anchors {
            fill: parent
            margins: 5
        }
        width: parent.width
        height: parent.height
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
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            Popup {
                id: delete_popup
                visible: false
                Button {
                    text: qsTr("remove")
                    onClicked: {
                        parent_obj.selected_imgs_model.delete_image(index)
                    }
                }
            }
            onClicked: {
                if(mouse.button & Qt.LeftButton) {
                    parent_obj.selected_imgs_model.set_curr_img_index(index)
                } else if(mouse.button & Qt.RightButton) {
                    delete_popup.open()
                }
            }
            onDoubleClicked: {
                parent_obj.selected_imgs_model.set_curr_img_index(index)
                parent_obj.full_screen_window = parent_obj.full_screen_window_comp.createObject(null, { img_source: img_preview.source, window_type: Full_screen_img.Window_type.With_btns, view: parent_obj.all_imgs_list_view, selected_imgs: parent_obj.selected_imgs_model })
                parent_obj.full_screen_window.show()
            }
        }
    }
}
