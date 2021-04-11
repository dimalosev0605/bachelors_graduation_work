import QtQuick 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.12

import Default_dir_creator_qml 1.0
import Janitor_qml 1.0
import "../qml/main_menu_pages/add_new"
import "../qml/main_menu_pages/people"
import "../qml/main_menu_pages/photos"
import "../qml/main_menu_pages/webcam"
import "../qml/main_menu_pages/settings"
import "../qml/main_menu_pages/video"
import "../qml/main_menu_pages/about"
import "../qml/main_menu_pages/help"

Page {
    Material.theme: Style_control.is_dark_mode_on ? Material.Dark : Material.Light
    Universal.theme: Style_control.is_dark_mode_on ? Universal.Dark : Universal.Light

    property alias file_dialog: file_dialog
    property alias message_dialog: message_dialog

    Component.onCompleted: {
        default_dir_creator.create_default_dirs()
        if(Style_control.get_is_style_changed()) {
            stack_view.push(settings_comp, StackView.Immediate)
            return
        }
        if(Password_manager.is_password_set()) {
            stack_view.push(startup_password_input_comp, StackView.Immediate)
            return
        }
    }
    Component {
        id: startup_password_input_comp
        Startup_password_input {}
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
    Component {
        id: select_people_for_recognition_webcam_comp
        Select_people_for_recognition_webcam {}
    }
    Component {
        id: select_people_for_recognition_video_comp
        Select_people_for_recognition_video {}
    }
    Component {
        id: settings_comp
        Settings {}
    }
    Component {
        id: about_comp
        About {}
    }
    Component {
        id: help_comp
        Help {}
    }

    FileDialog {
        id: file_dialog
        title: qsTr("Please choose files")
        folder: shortcuts.home
        visible: false
        selectMultiple: true
        nameFilters: [ "Image files (*.jpg *.png *.jpeg)", "All files (*)" ]
    }
    MessageDialog {
        id: message_dialog
        modality: Qt.ApplicationModal
        title: qsTr("Information")
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
        height: parent.height * 0.6
        focus: true
        Keys.onReturnPressed: {
            menu_grid_view_model.get(currentIndex).action()
        }
        ListModel {
            id: menu_grid_view_model
            ListElement {
                text: qsTr("People")
                img_source: ""
                action: function() {
                    stack_view.push(all_people_comp, StackView.Immediate)
                }
            }
            ListElement {
                text: qsTr("Add new")
                img_source: ""
                action: function() {
                    stack_view.push(nickname_input_comp, StackView.Immediate)
                }
            }
            ListElement {
                text: qsTr("Settings")
                img_source: ""
                action: function() {
                    stack_view.push(settings_comp, StackView.Immediate)
                }
            }
            ListElement {
                text: qsTr("Web cam")
                img_source: ""
                action: function() {
                    stack_view.push(select_people_for_recognition_webcam_comp, StackView.Immediate)
                }
            }
            ListElement {
                text: qsTr("Photos")
                img_source: ""
                action: function() {
                    stack_view.push(select_people_for_recognition_comp, StackView.Immediate)
                }
            }
            ListElement {
                text: qsTr("Video")
                img_source: ""
                action: function() {
                    stack_view.push(select_people_for_recognition_video_comp, StackView.Immediate)
                }
            }
            ListElement {
                text: qsTr("About")
                img_source: ""
                action: function() {
                    stack_view.push(about_comp, StackView.Immediate)
                }
            }
            ListElement {
                text: qsTr("Help")
                img_source: ""
                action: function() {
                    stack_view.push(help_comp, StackView.Immediate)
                }
            }
            ListElement {
                text: qsTr("Exit")
                img_source: ""
                action: function() { Qt.quit() }
            }
        }
        model: menu_grid_view_model
        cellWidth: width / 3
        cellHeight: height / 3 * 0.9
        interactive: false
        property int spacing: 20
        delegate: Button {
            id: delegate
            width: menu_grid_view.cellWidth - menu_grid_view.spacing
            height: menu_grid_view.cellHeight - menu_grid_view.spacing
            text: model.text
            onClicked: {
                model.action()
            }
            highlighted: GridView.isCurrentItem
            onHoveredChanged:  {
                if(hovered) {
                    menu_grid_view.currentIndex = index
                    scale_anim.start()
                }
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
        }
    }
}
