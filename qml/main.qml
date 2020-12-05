import QtQuick.Window 2.12
import QtQuick.Controls 2.12

import Default_dir_creator_qml 1.0

Window {
    visible: true
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
