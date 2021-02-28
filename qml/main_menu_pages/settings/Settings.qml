import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.12

import "../../common"

Page {
    Material.theme: Style_control.is_dark_mode_on ? Material.Dark : Material.Light
    Universal.theme: Style_control.is_dark_mode_on ? Universal.Dark : Universal.Light
    Keys.onEscapePressed: {
        stack_view.pop(StackView.Immediate)
    }
    Back_btn {
        id: back_btn
        anchors {
            bottom: parent.bottom
            bottomMargin: 5
            left: parent.left
            leftMargin: 5
        }
        onClicked: {
            stack_view.pop(StackView.Immediate)
        }
    }
    Row {
        id: row
        anchors {
            top: parent.top
            topMargin: 5
            left: parent.left
            leftMargin: 5
            right: parent.right
            rightMargin: 5
            bottom: back_btn.top
            bottomMargin: 5
        }
        spacing: 5
        property int item_c: 3
        property real item_w: (width - (item_c - 1) * spacing) / item_c

        GroupBox {
            id: style_box
            width: row.item_w
            height: parent.height
            Label {
                id: style_box_title
                anchors {
                    top: parent.top
                }
                width: parent.width
                height: 30
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                fontSizeMode: Text.Fit
                minimumPointSize: 1
                font.pointSize: 15
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                text: qsTr("Style")
            }
            ComboBox {
                id: style_combo_box
                anchors {
                    top: style_box_title.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                height: 30
                width: parent.width * 0.6
                model: [qsTr("Default"), qsTr("Material"), qsTr("Universal")]
                Component.onCompleted: {
                    var idx = find(Style_control.get_style(), Qt.MatchExactly)
                    currentIndex = idx
                }
                onActivated: {
                    Style_control.change_style(style_combo_box.currentValue)
                }
            }
            Switch {
                id: dark_mode_switch
                text: qsTr("Dark mode")
                visible: Style_control.get_style() !== "Default"
                anchors {
                    top: style_combo_box.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                width: 160
                height: 30
                checked: Style_control.is_dark_mode_on
                onClicked: {
                    Style_control.is_dark_mode_on ? Style_control.is_dark_mode_on = false : Style_control.is_dark_mode_on = true
                }
            }
        }
        GroupBox {
            width: row.item_w
            height: parent.height
        }
        GroupBox {
            width: row.item_w
            height: parent.height
        }
    }
}
