import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.12

Page {
    Material.theme: Style_control.is_dark_mode_on ? Material.Dark : Material.Light
    Universal.theme: Style_control.is_dark_mode_on ? Universal.Dark : Universal.Light
    Label {
        id: message_lbl
        anchors {
            top: parent.top
            topMargin: parent.height * 0.2
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
        text: qsTr("Wrong password")
        visible: false
    }
    TextField {
        id: password_input
        anchors {
            top: message_lbl.bottom
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
        }
        height: Style_control.get_style() === "Material" ? 70 : 35
        width: parent.width * 0.3
        placeholderText: qsTr("Enter password")
        echoMode: TextInput.NoEcho
    }

    Button {
        id: ok_btn
        anchors {
            top: password_input.bottom
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
        }
        height: 30
        text: qsTr("Ok")
        onClicked: {
            if(Password_manager.check_password(password_input.text.toString())) {
                stack_view.pop(StackView.Immediate)
            }
            else {
                message_lbl.visible = true
            }
        }
    }
    Button {
        id: exit_btn
        anchors {
            bottom: parent.bottom
            bottomMargin: 5
            left: parent.left
            leftMargin: 5
        }
        height: ok_btn.height
        text: qsTr("Exit")
        onClicked: {
            Qt.quit()
        }
    }
}
