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
    Connections {
        id: password_manager_connection
        target: Password_manager
        function onMessage(some_message) {
            message_dialog.text = some_message
            message_dialog.open()
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
            id: language_box
            width: row.item_w
            height: parent.height
            Label {
                id: language_box_title
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
                text: qsTr("Language")
            }
            ComboBox {
                id: language_combo_box
                anchors {
                    top: language_box_title.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                height: 30
                width: parent.width * 0.6
                model: [qsTr("Russian"), qsTr("English"), qsTr("French")]
                Component.onCompleted: {
                    var idx = find(Language_switcher.get_language(), Qt.MatchExactly)
                    currentIndex = idx
                }
                onActivated: {
                    Language_switcher.change_language(language_combo_box.currentValue)
                }
            }
        }
        GroupBox {
            id: security_box_disabled_password
            width: row.item_w
            height: parent.height
            visible: !Password_manager.is_password_set()
            Label {
                id: security_box_disabled_password_title
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
                text: qsTr("Security")
            }
            Switch {
                id: ask_password_on_startup_switch
                text: qsTr("Ask for a password at startup")
                visible: Style_control.get_style() !== "Default"
                anchors {
                    top: security_box_disabled_password_title.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                height: 30
                onClicked: {
                    if(!checked) {
                        password_input.text = ""
                        check_password_input.text = ""
                    }
                }
            }
            TextField {
                id: password_input
                anchors {
                    top: ask_password_on_startup_switch.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                height: Style_control.get_style() === "Material" ? 70 : 35
                width: parent.width * 0.5
                echoMode: TextInput.NoEcho
                placeholderText: qsTr("Enter password")
                visible: ask_password_on_startup_switch.checked
            }
            Label {
                id: message_lbl
                anchors {
                    top: password_input.bottom
                    topMargin: 3
                }
                width: parent.width
                height: 15
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                fontSizeMode: Text.Fit
                minimumPointSize: 1
                font.pointSize: 15
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                text: qsTr("Passwords don't match")
                visible: password_input.text !== "" && check_password_input.text !== "" && password_input.text !== check_password_input.text && ask_password_on_startup_switch.checked
            }
            TextField {
                id: check_password_input
                anchors {
                    top: message_lbl.bottom
                    topMargin: 5
                    horizontalCenter: parent.horizontalCenter
                }
                height: password_input.height
                width: password_input.width
                echoMode: TextInput.NoEcho
                placeholderText: qsTr("Enter password again")
                visible: password_input.text !== "" && ask_password_on_startup_switch.checked
            }
            Button {
                id: save_password_btn
                anchors {
                    top: check_password_input.bottom
                    topMargin: 5
                    horizontalCenter: parent.horizontalCenter
                }
                height: 30
                text: qsTr("Ok")
                visible: enabled
                enabled: password_input.text !== "" && check_password_input.text !== "" && password_input.text === check_password_input.text && ask_password_on_startup_switch.checked
                onClicked: {
                    Password_manager.set_password(password_input.text.toString())
                    security_box_disabled_password.visible = false
                    security_box_enabled_password.visible = true
                    ask_password_on_startup_switch.checked = false
                    password_input.text = ""
                    check_password_input.text = ""
                }
            }
        }
        GroupBox {
            id: security_box_enabled_password
            width: row.item_w
            height: parent.height
            visible: Password_manager.is_password_set()
            Label {
                id: security_box_enabled_password_title
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
                text: qsTr("Security")
            }
            Button {
                id: disable_password_btn
                anchors {
                    top: security_box_enabled_password_title.bottom
                    topMargin: 5
                    horizontalCenter: parent.horizontalCenter
                }
                height: 30
                text: qsTr("Disable password at startup")
                onClicked: {
                    if(ask_password_input.visible) {
                        ask_password_input.visible = false
                    }
                    else {
                        ask_password_input.visible = true
                    }
                }
            }
            TextField {
                id: ask_password_input
                anchors {
                    top: disable_password_btn.bottom
                    topMargin: 5
                    horizontalCenter: parent.horizontalCenter
                }
                height: password_input.height
                width: password_input.width
                echoMode: TextInput.NoEcho
                placeholderText: qsTr("Enter password")
                visible: false
            }
            Button {
                id: ok_btn
                anchors {
                    top: ask_password_input.bottom
                    topMargin: 5
                    horizontalCenter: parent.horizontalCenter
                }
                height: 30
                visible: ask_password_input.visible
                enabled: ask_password_input.text !== ""
                text: qsTr("Ok")
                onClicked: {
                    if(Password_manager.disable_password_at_startup(ask_password_input.text.toString())) {
                        security_box_enabled_password.visible = false
                        security_box_disabled_password.visible = true
                        ask_password_input.visible = false
                        ask_password_input.text = ""
                    }
                }
            }
        }
    }
}
