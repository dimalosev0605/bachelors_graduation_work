import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../common"
import Individual_checker_qml 1.0

Page {
    Component {
        id: select_images_comp
        Select_images {}
    }
    Individual_checker {
        id: individual_checker
        onMessage: {
            message_dialog.text = message_str
            message_dialog.open()
        }
    }
    TextField {
        id: nickname_text_field
        anchors {
            top: parent.top
            topMargin: parent.height * 0.2
            horizontalCenter: parent.horizontalCenter
        }
        width: 250
        height: 35
        focus: true
        placeholderText: "Input nickname"
        Keys.onReturnPressed: {
            if(!individual_checker.check_individual_existence(text)) {
                individual_checker.set_individual_name(text)
                if(individual_checker.create_individual_dirs()) {
                    next_btn.enabled = true
                    nickname_text_field.enabled = false
                }
            }
        }
    }
    Keys.onEscapePressed: {
        individual_checker.delete_individual_dirs()
        stack_view.pop(StackView.Immediate)
    }
    Button {
        id: next_btn
        anchors {
            top: nickname_text_field.top
            left: nickname_text_field.right
            leftMargin: 5
        }
        height: nickname_text_field.height
        width: 70
        text: "Next"
        enabled: false
        onClicked: {
            stack_view.push(select_images_comp, StackView.Immediate)
        }
    }
    Back_btn {
        anchors {
            bottom: parent.bottom
            bottomMargin: 5
            left: parent.left
            leftMargin: 5
        }
        onClicked: {
            individual_checker.delete_individual_dirs()
            stack_view.pop(StackView.Immediate)
        }
    }
}
