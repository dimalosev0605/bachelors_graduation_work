import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.12

import "../../common"
import Individual_checker_qml 1.0

Page {
    id: nickname_input_page

    Material.theme: Style_control.is_dark_mode_on ? Material.Dark : Material.Light
    Universal.theme: Style_control.is_dark_mode_on ? Universal.Dark : Universal.Light

    Keys.onEscapePressed: {
        stack_view.pop(StackView.Immediate)
    }

    Component {
        id: select_images_comp
        Select_images {}
    }

    property bool is_delete_individual_dirs: true

    Component.onDestruction: {
        if(is_delete_individual_dirs) {
            individual_checker.delete_individual_dirs()
        }
    }

    Individual_checker {
        id: individual_checker
        onMessage: {
            message_dialog.text = message_str
            message_dialog.open()
        }
    }
    Label {
        id: info_lbl
        anchors {
            top: parent.top
            topMargin: parent.height * 0.2
            horizontalCenter: parent.horizontalCenter
        }
        height: 40
        width: parent.width
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        fontSizeMode: Text.Fit
        minimumPointSize: 1
        font.pointSize: 15
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        text: qsTr("Input nickname and press \"Ok\" button")
    }
    TextField {
        id: nickname_text_field
        anchors {
            top: info_lbl.bottom
            topMargin: 20
            horizontalCenter: parent.horizontalCenter
        }
        width: 250
        height: Style_control.get_style() === "Material" ? 70 : 35
        focus: true
        placeholderText: qsTr("Input nickname")
        Keys.onReturnPressed: {
            ok_btn.clicked(null)
        }
    }
    Button {
        id: ok_btn
        anchors {
            top: nickname_text_field.bottom
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
        }
        height: 40
        width: 120
        text: qsTr("Ok")
        onClicked: {
            if(nickname_text_field.text === "") return
            if(!individual_checker.check_individual_existence(nickname_text_field.text)) {
                individual_checker.set_individual_name(nickname_text_field.text)
                if(individual_checker.create_individual_dirs()) {
                    next_btn.enabled = true
                    ok_btn.enabled = false
                    nickname_text_field.enabled = false
                }
            }
        }
    }
    Button {
        id: next_btn
        anchors {
            bottom: parent.bottom
            bottomMargin: back_btn.anchors.bottomMargin
            right: parent.right
            rightMargin: back_btn.anchors.leftMargin
        }
        height: back_btn.height
        text: qsTr("Next")
        enabled: false
        onClicked: {
            stack_view.push(select_images_comp, StackView.Immediate)
        }
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
}
