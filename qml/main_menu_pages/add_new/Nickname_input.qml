import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../common"

Page {
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
        }
    }
    Keys.onEscapePressed: {
        stack_view.pop(StackView.Immediate)
    }
    Back_btn {
        anchors {
            bottom: parent.bottom
            bottomMargin: 5
            left: parent.left
            leftMargin: 5
        }
    }
}
