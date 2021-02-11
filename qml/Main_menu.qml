import QtQuick 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12

import Default_dir_creator_qml 1.0
import Janitor_qml 1.0
import "../qml/main_menu_pages/add_new"
import "../qml/main_menu_pages/people"
import "../qml/main_menu_pages/photos"

Page {
    property alias file_dialog: file_dialog
    property alias message_dialog: message_dialog

    Component.onCompleted: {
        default_dir_creator.create_default_dirs()
    }
    Component {
        id: nickname_input_comp
        Nickname_input {}
    }
    Component {
        id: all_people_comp
        All_people {}
    }
    Component {
        id: select_people_for_recognition_comp
        Select_people_for_recognition {}
    }

    FileDialog {
        id: file_dialog
        title: "Please choose files"
        folder: shortcuts.home
        visible: false
        selectMultiple: true
        nameFilters: [ "Image files (*.jpg *.png *.jpeg)", "All files (*)" ]
    }
    MessageDialog {
        id: message_dialog
        modality: Qt.ApplicationModal
        title: "Information"
        standardButtons: MessageDialog.Ok
        onAccepted: {
            close()
        }
    }
    Default_dir_creator {
        id: default_dir_creator
        onMessage: {
            message_dialog.text = message_str
            message_dialog.open()
        }
    }
    Janitor {
        id: janitor
    }
    GridView {
        id: menu_grid_view
        anchors.centerIn: parent
        width: parent.width * 0.6
        height: parent.height * 0.7
        focus: true
        Keys.onReturnPressed: {
            menu_grid_view_model.get(currentIndex).action()
        }
        ListModel {
            id: menu_grid_view_model
            ListElement {
                text: "People"
                img_source: ""
                color: "#ff0000"
                action: function() {
                    stack_view.push(all_people_comp, StackView.Immediate)
                }
            }
            ListElement {
                text: "Add new"
                img_source: ""
                color: "#00ff00"
                action: function() {
                    stack_view.push(nickname_input_comp, StackView.Immediate)
                }
            }
            ListElement {
                text: "Settings"
                img_source: ""
                color: "gray"
            }
            ListElement {
                text: "Web cam"
                img_source: ""
                color: "yellow"
            }
            ListElement {
                text: "Photos"
                img_source: ""
                color: "orange"
                action: function() {
                    stack_view.push(select_people_for_recognition_comp, StackView.Immediate)
                }
            }
            ListElement {
                text: "Video"
                img_source: ""
                color: "#00ff00"
            }
            ListElement {
                text: "About"
                img_source: ""
                color: "red"
            }
            ListElement {
                text: "Help"
                img_source: ""
                color: "orange"
                action: function() {
                    console.log("Help")
                }
            }
            ListElement {
                text: "Exit"
                img_source: ""
                color: "orange"
                action: function() { Qt.quit() }
            }
        }
        model: menu_grid_view_model
        cellWidth: width / 3
        cellHeight: height / 3
        property int spacing: 20
        delegate: Rectangle {
            id: delegate
            width: menu_grid_view.cellWidth - menu_grid_view.spacing
            height: menu_grid_view.cellHeight - menu_grid_view.spacing
            radius: 5
            color: model.color
            border.width: GridView.isCurrentItem ? 2 : 0
            border.color: "#000000"
            Image {
                id: img
                source: model.img_source
                anchors.centerIn: parent
                width: parent.width / 2
                height: parent.height / 2
                mipmap: true
                fillMode: Image.PreserveAspectFit
            }
            Text {
                anchors {
                    top: img.bottom
                    topMargin: 5
                    horizontalCenter: img.horizontalCenter
                }
                width: img.width
                height: delegate.height - anchors.topMargin - img.height - img.y
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                fontSizeMode: Text.Fit
                minimumPointSize: 1
                font.pointSize: 20
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                text: model.text
            }
            SequentialAnimation {
                id: scale_anim
                property real to_scale: 1.1
                property int duration: 250
                ScaleAnimator {
                    target: delegate
                    from: 1.0
                    to: scale_anim.to_scale
                    duration: scale_anim.duration
                }
                ScaleAnimator {
                    target: delegate
                    from: scale_anim.to_scale
                    to: 1.0
                    duration: scale_anim.duration
                }
            }
            MouseArea {
                id: m_area
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    scale_anim.start()
                    menu_grid_view.currentIndex = index
                }
                onClicked: {
                    model.action()
                }
            }
        }
    }
}
