import QtQuick 2.12
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import Selected_imgs_qml 1.0
import "../common"

Rectangle {
    radius: 2

    property alias img_file_path: img_preview.source
    property var parent_obj

    color: parent_obj.all_imgs_list_view.currentIndex === index ? "gray" : "transparent"

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
        scale: (img_preview_m_area.containsMouse || delete_btn_m_area.containsMouse) ? 1.1 : 1.0
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
            }
            onDoubleClicked: {
                parent_obj.selected_imgs_model.set_curr_img_index(index)
                parent_obj.full_screen_window = parent_obj.full_screen_window_comp.createObject(null, { img_source: img_preview.source, window_type: Full_screen_img.Window_type.With_btns, view: parent_obj.all_imgs_list_view, selected_imgs: parent_obj.selected_imgs_model })
                parent_obj.full_screen_window.show()
            }
        }
        Rectangle {
            id: delete_btn
            anchors {
                right: parent.right
            }
            radius: 5
            height: 20
            width: height
            color: "black"
            scale: delete_btn_m_area.containsMouse ? 1.1 : 1.0
            MouseArea {
                id: delete_btn_m_area
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    parent_obj.selected_imgs_model.delete_image(index)
                }
            }
        }
    }
}
