import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.12

import "../../common"

Page {
    id: root
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
    ScrollView {
        id: text_view
        anchors {
            top: parent.top
            topMargin: 5
            bottom: back_btn.top
            bottomMargin: anchors.topMargin
            left: parent.left
            leftMargin: 5
            right: parent.right
            rightMargin: anchors.leftMargin
        }
        clip: true
        contentWidth: text.contentWidth
        Label {
             id: text
             width: text_view.width
             height: text_view.height
             fontSizeMode: Text.Fit
             minimumPointSize: 1
             font.pointSize: 15
             elide: Text.ElideRight
             wrapMode: Text.WordWrap
             textFormat: Text.RichText
             onLinkActivated: Qt.openUrlExternally(link)
             text:
    qsTr
    ('
    <h1>How to use this application?</h1>
    <ol>
    <li>Add some people</li>
    <li>Select source for recognition (photos, webcam or video)</li>
    <li>Select people for recognition</li>
    <li>Adjust some recognition parameters</li>
    </ol>
    <h2>Acronyms meaning and description</h2>
    <p>HOG - Histogram of Oriented Gradients. Fast but not very precise method for face detection.</p>
    <p>CNN - Convolutional Neural Network. Very precise method for face detection. It is slow on CPU but very fast on GPU with CUDA architecture.</p>
    <p>Pyr up - scale up the image in factor of two. You can use it if you want to detect small faces. But if you increase the size of the image you increase the time for processing it.</p>
    <p>Pyr down - scale down the image in factor of two. You can use it if you want to decrease the processing time of the image.</p>
    <h2>Face recognition precision adjusting</h2>
    <p>You can use slider for adjusting precision for face recognition. Minimum value - 0. Maximum value - 1. Lower the value greater the precision. Optimal value for recognition lays between 0.5 and 0.6 including.</p>
    ')
        }
    }
}
