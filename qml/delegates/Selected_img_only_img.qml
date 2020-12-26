import QtQuick 2.12
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import Selected_imgs_qml 1.0
import "../common"

Rectangle {
    radius: 2

    property alias img_file_path: img_preview.source

    property ListView view
    property Selected_imgs selected_imgs_model
    property var full_screen_img

    color: view.currentIndex === index ? "gray" : "transparent"

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
            onClicked: {
                selected_imgs_model.set_curr_img_index(index)
            }
            onDoubleClicked: {
                selected_imgs_model.set_curr_img_index(index)
                var win = full_screen_img.createObject(null, { img_source: img_preview.source, window_type: Full_screen_img.Window_type.With_btns, view: view, selected_imgs: selected_imgs_model})
                win.show()
            }
        }
    }
}
