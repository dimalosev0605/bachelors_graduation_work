import QtQuick.Window 2.12
import QtQuick 2.12
import QtQuick.Controls 2.15

import Selected_imgs_qml 1.0

Window {
    id: full_screen_window
    visible: true
    height: Screen.desktopAvailableHeight
    width: Screen.desktopAvailableWidth

    property alias img_source: img.source

    property ListView view // if window_type = Window_type.With_btns you must pass view.
    property Selected_imgs selected_imgs // if window_type = Window_type.With_btns you must pass selected_imgs
    property int window_type: Full_screen_img.Window_type.Without_btns
    property Image source_image: null // you must pass it for full screen video stream
    property real darker_factor: 1.2

    enum Window_type {
        Without_btns,
        With_btns
    }

    Connections {
        target: source_image
        function onUpdate_full_screen_img(source) {
            img.source = source
        }
    }

    flags: Qt.FramelessWindowHint
    color: "transparent"

    Rectangle {
        id: font_rect
        anchors.fill: parent
        color: "#333333"
        opacity: 0.9
    }
    Rectangle {
        id: close_window_btn
        anchors {
            top: parent.top
            right: parent.right
        }
        width: 90
        height: width
        color: close_window_btn_m_area.containsMouse ? Qt.darker(font_rect.color, full_screen_window.darker_factor) : "transparent"
        MouseArea {
            id: close_window_btn_m_area
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                full_screen_window.close()
                full_screen_window.destroy()
            }
            onContainsMouseChanged: {
                close_window_btn_canvas.requestPaint()
            }
        }
        Canvas {
            id: close_window_btn_canvas
            anchors.centerIn: parent
            width: parent.width * 0.4
            height: width
            rotation: 45
            transformOrigin: Item.Center
            onPaint: {
                var ctx = getContext("2d")
                ctx.lineWidth = canvas_properties.line_width
                ctx.strokeStyle = close_window_btn_m_area.containsMouse ? canvas_properties.hovered_color : canvas_properties.default_color
                ctx.beginPath()
                ctx.moveTo(width / 2, 0)
                ctx.lineTo(width / 2, height)
                ctx.moveTo(0, height / 2)
                ctx.lineTo(width, height / 2)
                ctx.stroke()
            }
        }
    }

    Item {
        id: canvas_properties
        property color hovered_color: "#ffffff"
        property color default_color: "#bfbfbf"
        property int line_width: 5
        property int delta: 20
    }
    Rectangle {
        id: right_arrow_btn
        anchors {
            top: close_window_btn.bottom
            right: parent.right
        }
        width: close_window_btn.width
        height: parent.height - close_window_btn.height * 2
        color: right_arrow_btn_m_area.containsMouse ? Qt.darker(font_rect.color, full_screen_window.darker_factor) : "transparent"
        visible: full_screen_window.window_type === Full_screen_img.Window_type.With_btns ? view.currentIndex !== (view.count - 1) : false
        MouseArea {
            id: right_arrow_btn_m_area
            anchors.fill: parent
            hoverEnabled: true
            onContainsMouseChanged: {
                right_arrow_canvas.requestPaint()
            }
            onClicked: {
                if(!visible) return
                selected_imgs.set_curr_img_index(view.currentIndex + 1)
                img.source = view.currentItem.img_file_path
            }
        }
        Canvas {
            id: right_arrow_canvas
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width / 2
            height: width
            rotation: 45
            transformOrigin: Item.Center
            onPaint: {
                var ctx = getContext("2d")
                ctx.lineWidth = canvas_properties.line_width
                ctx.strokeStyle = right_arrow_btn_m_area.containsMouse ? canvas_properties.hovered_color : canvas_properties.default_color
                ctx.beginPath()
                ctx.moveTo(canvas_properties.line_width, canvas_properties.line_width)
                ctx.lineTo(canvas_properties.line_width + canvas_properties.delta, canvas_properties.line_width)
                ctx.lineTo(canvas_properties.line_width + canvas_properties.delta, canvas_properties.line_width + canvas_properties.delta)
                ctx.stroke()
            }
        }
    }
    Rectangle {
        id: left_arrow_btn
        anchors {
            top: close_window_btn.bottom
            left: parent.left
        }
        width: right_arrow_btn.width
        height: right_arrow_btn.height
        color: left_arrow_btn_m_area.containsMouse ? Qt.darker(font_rect.color, full_screen_window.darker_factor) : "transparent"
        visible: full_screen_window.window_type === Full_screen_img.Window_type.With_btns ? (view.currentIndex !== 0 && view.currentIndex !== -1) : false
        MouseArea {
            id: left_arrow_btn_m_area
            anchors.fill: parent
            hoverEnabled: true
            onContainsMouseChanged: {
                left_arrow_canvas.requestPaint()
            }
            onClicked: {
                if(!visible) return
                selected_imgs.set_curr_img_index(view.currentIndex - 1)
                img.source = view.currentItem.img_file_path
            }
        }
        Canvas {
            id: left_arrow_canvas
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width / 2
            height: width
            rotation: -45
            transformOrigin: Item.Center
            onPaint: {
                var ctx = getContext("2d")
                ctx.lineWidth = canvas_properties.line_width
                ctx.strokeStyle = left_arrow_btn_m_area.containsMouse ? canvas_properties.hovered_color : canvas_properties.default_color
                ctx.beginPath()
                ctx.moveTo(canvas_properties.delta + canvas_properties.line_width, canvas_properties.line_width)
                ctx.lineTo(canvas_properties.line_width, canvas_properties.line_width)
                ctx.lineTo(canvas_properties.line_width, canvas_properties.delta + canvas_properties.line_width)
                ctx.stroke()
            }
        }
    }
    Row {
        id: zoom_btns_row
        anchors {
            top: parent.top
            topMargin: close_window_btn.anchors.topMargin
            horizontalCenter: parent.horizontalCenter
        }
//        width: 180
        height: 30
        spacing: 3
        Button {
            id: zoom_out_btn
            height: parent.height
//            width: parent.width / 3
            onClicked: {
                img_flickable.zoomOut()
            }
            text: qsTr("Out")
            palette.buttonText: pressed ? "#000000" : "#ffffff"
        }
        Button {
            id: set_default_zoom_btn
            height: parent.height
//            width: parent.width / 3
            onClicked: {
                img_flickable.fit_to_screen()
            }
            text: qsTr("Fit")
            palette.buttonText: pressed ? "#000000" : "#ffffff"
        }
        Button {
            id: zoom_in_btn
            height: parent.height
//            width: parent.width / 3
            onClicked: {
                img_flickable.zoomIn()
            }
            text: qsTr("In")
            palette.buttonText: pressed ? "#000000" : "#ffffff"
        }
    }

    Item {
        id: img_display
        anchors {
            left: left_arrow_btn.right
            leftMargin: 5
            right: right_arrow_btn.left
            rightMargin: 5
            top: zoom_btns_row.bottom
            topMargin: 5
            bottom: parent.bottom
            bottomMargin: 5
        }
        Flickable {
            id: img_flickable
            anchors.fill: parent
            boundsBehavior: Flickable.StopAtBounds
            contentHeight: img_container.height
            contentWidth: img_container.width
            clip: true

            property bool fit_to_screen_active: true
            property real zoom_step: 0.1

            ScrollBar.vertical: ScrollBar{}
            ScrollBar.horizontal: ScrollBar{}

            onWidthChanged: { if(fit_to_screen_active) fit_to_screen() }
            onHeightChanged: { if(fit_to_screen_active) fit_to_screen() }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                onWheel: {
                    if(Math.abs(wheel.angleDelta.y) < 30) return
                    if(wheel.angleDelta.y > 0) {
                        img_flickable.zoomIn()
                    }
                    else {
                        img_flickable.zoomOut()
                    }
                }
            }
            Item {
                id: img_container
                width: Math.max(img.width * img.scale, img_flickable.width)
                height: Math.max(img.height * img.scale, img_flickable.height)

                Image {
                    id: img
                    property real prev_scale: 1.0
                    asynchronous: false
                    cache: false
                    smooth: img_flickable.moving
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    transformOrigin: Item.Center
                    onScaleChanged: {
                        if ((width * scale) > img_flickable.width) {
                            var xoff = (img_flickable.width / 2 + img_flickable.contentX) * scale / prev_scale
                            img_flickable.contentX = xoff - img_flickable.width / 2
                        }
                        if ((height * scale) > img_flickable.height) {
                            var yoff = (img_flickable.height / 2 + img_flickable.contentY) * scale / prev_scale
                            img_flickable.contentY = yoff - img_flickable.height / 2
                        }
                        prev_scale = scale
                    }
                    onStatusChanged: {
                        if (status === Image.Ready) {
                            if(source_image === null) {
                                img_flickable.fit_to_screen()
                            }
                        }
                    }
                }
            }
            function fit_to_screen() {
                var s = Math.min(img_flickable.width / img.width, img_flickable.height / img.height, 1)
                img.scale = s
                img.prev_scale = scale
                fit_to_screen_active = true
                img_flickable.returnToBounds()
            }
            function zoomIn() {
                img.scale *= (1.0 + zoom_step)
                img_flickable.returnToBounds()
                fit_to_screen_active = false
                img_flickable.returnToBounds()
            }
            function zoomOut() {
                img.scale *= (1.0 - zoom_step)
                img_flickable.returnToBounds()
                fit_to_screen_active = false
                img_flickable.returnToBounds()
            }
        }
    }

    Shortcut {
        sequence: "Esc"
        onActivated: {
            full_screen_window.close()
            full_screen_window.destroy()
        }
    }
    Shortcut {
        sequence: "Left"
        enabled: full_screen_window.window_type === Full_screen_img.Window_type.With_btns
        onActivated: {
            left_arrow_btn_m_area.clicked(null)
        }
    }
    Shortcut {
        sequence: "Right"
        enabled: full_screen_window.window_type === Full_screen_img.Window_type.With_btns
        onActivated: {
            right_arrow_btn_m_area.clicked(null)
        }
    }
}
