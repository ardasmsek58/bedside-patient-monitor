import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Effects
import SMMProtocol 1.0

ApplicationWindow {
    id: window
    width: 1280
    height: 800
    visible: true
    title: qsTr("VitaScope - Tıbbi Yönetim Sistemi")
    color: "#0a0a0a"

    Component.onCompleted: {
        Qt.application.stack = stackView
        Qt.application.roleSelector = roleSelector
    }

    // Background with sophisticated gradient
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0a0a0a" }
            GradientStop { position: 0.3; color: "#1a1a2e" }
            GradientStop { position: 0.7; color: "#16213e" }
            GradientStop { position: 1.0; color: "#0f3460" }
        }

        // Subtle animated background elements
        Repeater {
            model: 12
            Rectangle {
                width: Math.random() * 3 + 1
                height: width
                radius: width / 2
                color: "#ffffff"
                opacity: Math.random() * 0.05 + 0.02
                x: Math.random() * parent.width
                y: Math.random() * parent.height

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    PropertyAnimation {
                        to: opacity * 2
                        duration: 4000 + Math.random() * 2000
                        easing.type: Easing.InOutSine
                    }
                    PropertyAnimation {
                        to: opacity
                        duration: 4000 + Math.random() * 2000
                        easing.type: Easing.InOutSine
                    }
                }

                SequentialAnimation on y {
                    loops: Animation.Infinite
                    PropertyAnimation {
                        to: y - 30
                        duration: 6000 + Math.random() * 4000
                        easing.type: Easing.InOutQuad
                    }
                    PropertyAnimation {
                        to: y
                        duration: 6000 + Math.random() * 4000
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        // Medical cross pattern overlay
        Repeater {
            model: 3
            Item {
                width: 60
                height: 60
                x: Math.random() * parent.width
                y: Math.random() * parent.height
                opacity: 0.03

                Rectangle {
                    width: 4
                    height: 60
                    color: "#4facfe"
                    anchors.centerIn: parent
                }
                Rectangle {
                    width: 60
                    height: 4
                    color: "#4facfe"
                    anchors.centerIn: parent
                }

                RotationAnimation on rotation {
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    duration: 60000
                }
            }
        }
    }

    StackView {
        id: stackView
        objectName: "mainStackView"
        anchors.fill: parent
        initialItem: roleSelector
        clip: true
    }

    // ROLE SELECTION INTERFACE
    Component {
        id: roleSelector

        Item {
            //anchors.fill: parent
            width: stackView.width
            height: stackView.height

            // Main container with glass morphism effect
            Rectangle {
                id: mainContainer
                width: 480
                height: 640
                radius: 24
                anchors.centerIn: parent
                color: "#16213e"
                border.color: "#4facfe"
                border.width: 1
                opacity: 0.95

                // Subtle shadow effect
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -2
                    radius: parent.radius + 2
                    color: "#000000"
                    opacity: 0.2
                    z: -1
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 40
                    width: parent.width - 80

                    // Header Section
                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 16

                        // Logo Section
                        Item {
                            width: 80
                            height: 80
                            anchors.horizontalCenter: parent.horizontalCenter

                            Rectangle {
                                anchors.fill: parent
                                radius: 40
                                color: "#4facfe"
                                opacity: 0.1
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "⚕"
                                color: "#4facfe"
                                font.pixelSize: 36
                                font.weight: Font.Bold
                            }
                        }

                        Text {
                            text: "VitaScope"
                            color: "#ffffff"
                            font.pixelSize: 42
                            font.weight: Font.Bold
                            font.family: "Arial"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "Gelişmiş Tıbbi Yönetim Platformu"
                            color: "#b8c6db"
                            font.pixelSize: 16
                            font.weight: Font.Normal
                            anchors.horizontalCenter: parent.horizontalCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    // Divider
                    Rectangle {
                        width: parent.width - 40
                        height: 1
                        color: "#4facfe"
                        opacity: 0.3
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    // Role Selection Title
                    Text {
                        text: "Erişim Türünüzü Seçin"
                        color: "#ffffff"
                        font.pixelSize: 22
                        font.weight: Font.Medium
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    // Access Options
                    Column {
                        spacing: 20
                        anchors.horizontalCenter: parent.horizontalCenter

                        // Medical Professional Access
                        Rectangle {
                            id: doctorButton
                            width: 320
                            height: 70
                            radius: 12
                            color: "#1e2749"
                            border.color: "#4facfe"
                            border.width: 2

                            property bool hovered: false

                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }

                            Behavior on border.color {
                                ColorAnimation { duration: 200 }
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 16

                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: 20
                                    color: "#4facfe"
                                    opacity: 0.2

                                    Text {
                                        anchors.centerIn: parent
                                        text: "👨‍⚕️"
                                        font.pixelSize: 20
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Text {
                                        text: "Tıp Uzmanı"
                                        color: "#ffffff"
                                        font.pixelSize: 18
                                        font.weight: Font.Medium
                                    }

                                    Text {
                                        text: "Sağlık profesyoneli erişimi"
                                        color: "#b8c6db"
                                        font.pixelSize: 12
                                        opacity: 0.8
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onEntered: {
                                    parent.hovered = true
                                    parent.color = "#2a3754"
                                    parent.border.color = "#6bc8ff"
                                }

                                onExited: {
                                    parent.hovered = false
                                    parent.color = "#1e2749"
                                    parent.border.color = "#4facfe"
                                }

                                onPressed: {
                                    parent.scale = 0.98
                                }

                                onReleased: {
                                    parent.scale = 1.0
                                }

                                onClicked: {
                                    stackView.push("components/doctor/DoctorLogin.qml")

                                }

                                Behavior on scale {
                                    NumberAnimation { duration: 100 }
                                }
                            }
                        }

                        // Guest Access
                        Rectangle {
                            id: guestButton
                            width: 320
                            height: 70
                            radius: 12
                            color: "#4facfe"
                            border.color: "#4facfe"
                            border.width: 2

                            property bool hovered: false

                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 16

                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: 20
                                    color: "#ffffff"
                                    opacity: 0.3

                                    Text {
                                        anchors.centerIn: parent
                                        text: "👤"
                                        font.pixelSize: 20
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Text {
                                        text: "Ziyaretçi Erişimi"
                                        color: "#000000"
                                        font.pixelSize: 18
                                        font.weight: Font.Bold
                                    }

                                    Text {
                                        text: "Sınırlı demonstrasyon modu"
                                        color: "#003366"
                                        font.pixelSize: 12
                                        opacity: 0.8
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onEntered: {
                                    parent.hovered = true
                                    parent.color = "#6bc8ff"
                                }

                                onExited: {
                                    parent.hovered = false
                                    parent.color = "#4facfe"
                                }

                                onPressed: {
                                    parent.scale = 0.98
                                }

                                onReleased: {
                                    parent.scale = 1.0
                                }

                                onClicked: {
                                    deviceManager.userRole = "guest"
                                    stackView.push("components/visitor/VisitorView.qml")
                                }

                                Behavior on scale {
                                    NumberAnimation { duration: 100 }
                                }
                            }
                        }
                    }

                    // Footer Information
                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8

                        Rectangle {
                            width: parent.parent.width - 40
                            height: 1
                            color: "#4facfe"
                            opacity: 0.2
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "Güvenli • KVKK Uyumlu • Kurumsal Çözüm"
                            color: "#b8c6db"
                            font.pixelSize: 12
                            opacity: 0.7
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }

            // Version info
            Text {
                text: "Sürüm 2.1.0"
                color: "#4facfe"
                font.pixelSize: 11
                opacity: 0.5
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.margins: 20
            }
        }
    }
}
