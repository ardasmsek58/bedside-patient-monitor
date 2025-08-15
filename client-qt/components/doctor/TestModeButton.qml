import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: testModeContainer
    width: 240
    height: 60
    radius: 16
    color: "transparent"
    focus: false
    activeFocusOnTab: false

    property bool checked: false
    signal toggled(bool checked)

    // 🔸 Outer Border (visible and animated)
    Rectangle {
        id: outerBorder
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.width: 2
        border.color: checked ? "#66BB6A" : "#FF7043"
        opacity: 0.9
        z: -1

        Behavior on border.color {
            ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
        }
        Behavior on opacity {
            NumberAnimation { duration: 400 }
        }
    }

    // 🔹 Main background
    Rectangle {
        id: mainButton
        anchors.fill: parent
        radius: parent.radius

        gradient: Gradient {
            GradientStop { position: 0.0; color: checked ? "#4CAF50" : "#FF5722" }
            GradientStop { position: 1.0; color: checked ? "#388E3C" : "#D32F2F" }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.color: "#FFFFFF33"
            border.width: 1
        }

        Behavior on gradient {
            PropertyAnimation { duration: 300; easing.type: Easing.OutCubic }
        }
    }

    // Content
    Row {
        anchors.centerIn: parent
        spacing: 12

        Rectangle {
            id: statusIndicator
            width: 12
            height: 12
            radius: 6
            anchors.verticalCenter: parent.verticalCenter
            color: checked ? "#E8F5E8" : "#FFEBEE"
            border.color: checked ? "#2E7D32" : "#C62828"
            border.width: 2

            SequentialAnimation {
                running: checked
                loops: Animation.Infinite

                ScaleAnimator {
                    target: statusIndicator
                    from: 1.0
                    to: 1.3
                    duration: 1000
                    easing.type: Easing.InOutSine
                }
                ScaleAnimator {
                    target: statusIndicator
                    from: 1.3
                    to: 1.0
                    duration: 1000
                    easing.type: Easing.InOutSine
                }
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text: "TEST MODE"
                color: "white"
                font.pixelSize: 14
                font.bold: true
                font.letterSpacing: 0.5
            }

            Text {
                text: checked ? "Aktif" : "Pasif"
                color: "#FFFFFFE5"
                font.pixelSize: 11
                font.weight: Font.Medium
            }
        }

        Rectangle {
            width: 50
            height: 26
            radius: 13
            anchors.verticalCenter: parent.verticalCenter
            color: checked ? "#FFFFFF4D" : "#FFFFFF33"
            border.color: "#FFFFFF66"
            border.width: 1

            Rectangle {
                id: toggleHandle
                width: 20
                height: 20
                radius: 10
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                x: checked ? parent.width - width - 3 : 3

                Behavior on x {
                    NumberAnimation { duration: 250; easing.type: Easing.OutBack }
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    radius: parent.radius - 1
                    color: "transparent"
                    border.color: "#0000001A"
                    border.width: 1
                }
            }
        }
    }

    // Mouse Area
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        focus: false

        onClicked: {
            checked = !checked
            toggled(checked)
        }

        onPressed: {
            scaleAnimation.start()
        }
    }

    // Animations
    ScaleAnimator {
        id: scaleAnimation
        target: testModeContainer
        from: 1.0
        to: 0.97
        duration: 100
        easing.type: Easing.OutCubic

        onFinished: bounceBackAnimation.start()
    }

    ScaleAnimator {
        id: bounceBackAnimation
        target: testModeContainer
        from: 0.97
        to: 1.0
        duration: 100
        easing.type: Easing.OutBack
    }
}
