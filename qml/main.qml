import QtQuick.Window 2.12
import QtQuick.Controls 2.12

import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.12

import Default_dir_creator_qml 1.0

Window {
    visible: true
    Material.theme: Style_control.is_dark_mode_on ? Material.Dark : Material.Light
    Universal.theme: Style_control.is_dark_mode_on ? Universal.Dark : Universal.Light
    width: 1350
    height: 630
    minimumWidth: 600
    minimumHeight: 600
    StackView {
        id: stack_view
        anchors.fill: parent
        initialItem: Main_menu {}
        onCurrentItemChanged: {
            currentItem.forceActiveFocus()
        }
    }
}
