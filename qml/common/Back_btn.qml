import QtQuick 2.12
import QtQuick.Controls 2.12

Button {
    height: 30
    width: 60
    text: "Back"
    onClicked: {
        stack_view.pop(StackView.Immediate)
    }
}
