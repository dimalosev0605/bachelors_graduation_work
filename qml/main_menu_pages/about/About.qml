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
    <h1>Face2Name Desktop</h1>
    <p>version 1.0</p>
    <p>Free application for face recognition from images, videos and webcam streams.</p>
    <p>This software is licensed under GNU GPL version 3.</p>
    <p>Source code is available on <a href="https://github.com/dimalosev0605/bachelors_graduation_work">GitHub</a>.</p>
    <h2>This application was created with these libraries:</h2>
    <li><a href="https://www.qt.io/">Qt</a></li>
    <li><a href="http://dlib.net/">Dlib</a></li>
    <li><a href="https://opencv.org/">OpenCv</a></li>
    <p>Author: Dmitriy Losev.</p>
    <p>For any questions: dimalosev0605@gmail.com</p>
    ')
        }
    }
}
