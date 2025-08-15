import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import SMMProtocol 1.0

Item {
    id: loginPage
    width: parent ? parent.width : 800
    height: parent ? parent.height : 600

    property string errorMessage: ""

    // Helper to locate the nearest StackView
    function findStackView() {
        var item = loginPage
        while (item) {
            if (item.objectName === "mainStackView"
                    || (item.hasOwnProperty('push') && item.hasOwnProperty('pop'))) {
                return item
            }
            item = item.parent
        }
        return null
    }

    // Background gradient
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0c0c0c" }
            GradientStop { position: 0.5; color: "#1a1a2e" }
            GradientStop { position: 1.0; color: "#16213e" }
        }

        // Subtle animated particles
        Repeater {
            model: 4
            Rectangle {
                id: particle
                width: Math.random() * 4 + 2
                height: width
                radius: width / 2
                color: Qt.rgba(79/255, 172/255, 254/255, 0.1)
                x: Math.random() * parent.width
                y: Math.random() * parent.height

                SequentialAnimation on y {
                    loops: Animation.Infinite
                    PropertyAnimation { to: particle.y - 20; duration: 3000; easing.type: Easing.InOutSine }
                    PropertyAnimation { to: particle.y;       duration: 3000; easing.type: Easing.InOutSine }
                }
            }
        }
    }

    // Shadow effect
    Rectangle {
        id: shadow
        width: loginBox.width
        height: loginBox.height
        radius: loginBox.radius
        color: "#4facfe"
        opacity: 0.1
        anchors.centerIn: loginBox
        x: loginBox.x + 0
        y: loginBox.y + 10
        z: loginBox.z - 1
    }

    Rectangle {
        id: loginBox
        width: 450
        height: 650
        radius: 20
        color: "#16213e"
        border.color: "#4facfe"
        border.width: 1
        anchors.centerIn: parent
        z: 1

        Column {
            anchors.centerIn: parent
            spacing: 25
            width: parent.width - 80

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                Text {
                    text: "VitaScope"
                    color: "#4facfe"
                    font.pixelSize: 42
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "Doktor Girişi"
                    color: "white"
                    font.pixelSize: 20
                    font.weight: Font.Medium
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            // Error message box
            Rectangle {
                width: parent.width
                height: errorText.height + 20
                radius: 8
                color: Qt.rgba(255/255, 193/255, 7/255, 0.1)
                border.color: Qt.rgba(255/255, 193/255, 7/255, 0.3)
                border.width: 1
                visible: errorMessage !== ""

                Text {
                    id: errorText
                    text: errorMessage
                    color: "#ffc107"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    anchors.centerIn: parent
                    wrapMode: Text.WordWrap
                    width: parent.width - 20
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // Success message box
            Rectangle {
                width: parent.width
                height: successText.height + 20
                radius: 8
                color: Qt.rgba(76/255, 175/255, 80/255, 0.1)
                border.color: Qt.rgba(76/255, 175/255, 80/255, 0.3)
                border.width: 1
                visible: false
                id: successMessage

                Text {
                    id: successText
                    text: "Login successful! Redirecting..."
                    color: "#4CAF50"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    anchors.centerIn: parent
                    wrapMode: Text.WordWrap
                    width: parent.width - 20
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // Username
            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: "Kullanıcı Adı"
                    color: "#4facfe"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    x: 20
                }

                Rectangle {
                    id: usernameRect
                    width: parent.width
                    height: 55
                    radius: 12
                    color: Qt.rgba(15/255, 52/255, 96/255, 0.6)
                    border.color: Qt.rgba(79/255, 172/255, 254/255, 0.2)
                    border.width: 2

                    TextInput {
                        id: usernameField
                        anchors.left: parent.left
                        anchors.leftMargin: 25
                        anchors.right: userIcon.left
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        font.pixelSize: 16
                        selectByMouse: true
                        clip: true
                        echoMode: TextInput.Normal

                        Text {
                            text: "Kullanıcı adınızı girin"
                            color: Qt.rgba(255, 255, 255, 0.5)
                            font.pixelSize: 16
                            visible: usernameField.text === ""
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        onActiveFocusChanged: {
                            if (activeFocus) {
                                usernameRect.border.color = "#4facfe"
                                usernameRect.scale = 1.01
                            } else {
                                usernameRect.border.color = Qt.rgba(79/255,172/255,254/255,0.2)
                                usernameRect.scale = 1.0
                            }
                        }

                        // Allow pressing Enter to submit
                        Keys.onReturnPressed: loginBtn.clicked()
                        Keys.onEnterPressed:  loginBtn.clicked()
                    }

                    Text {
                        id: userIcon
                        text: "👤"
                        color: Qt.rgba(79/255, 172/255, 254/255, 0.7)
                        font.pixelSize: 18
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Behavior on border.color { ColorAnimation { duration: 200 } }
                    Behavior on scale       { NumberAnimation { duration: 200 } }
                }
            }

            // Password
            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: "Şifre"
                    color: "#4facfe"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    x: 20
                }

                Rectangle {
                    id: passwordRect
                    width: parent.width
                    height: 55
                    radius: 12
                    color: Qt.rgba(15/255, 52/255, 96/255, 0.6)
                    border.color: Qt.rgba(79/255, 172/255, 254/255, 0.2)
                    border.width: 2

                    TextInput {
                        id: passwordField
                        anchors.left: parent.left
                        anchors.leftMargin: 25
                        anchors.right: lockIcon.left
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        font.pixelSize: 16
                        echoMode: TextInput.Password
                        selectByMouse: true
                        clip: true
                        z: 1

                        Text {
                            text: "Şifrenizi girin"
                            color: Qt.rgba(255, 255, 255, 0.5)
                            font.pixelSize: 16
                            visible: passwordField.text === ""
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        onActiveFocusChanged: {
                            if (activeFocus) {
                                passwordRect.border.color = "#4facfe"
                                passwordRect.scale = 1.01
                            } else {
                                passwordRect.border.color = Qt.rgba(79/255,172/255,254/255,0.2)
                                passwordRect.scale = 1.0
                            }
                        }

                        // Allow pressing Enter to submit
                        Keys.onReturnPressed: loginBtn.clicked()
                        Keys.onEnterPressed:  loginBtn.clicked()
                    }

                    Text {
                        id: lockIcon
                        text: "🔒"
                        color: Qt.rgba(79/255, 172/255, 254/255, 0.7)
                        font.pixelSize: 18
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Behavior on border.color { ColorAnimation { duration: 200 } }
                    Behavior on scale       { NumberAnimation { duration: 200 } }
                }
            }

            // Login button
            Rectangle {
                id: loginBtn
                width: parent.width
                height: 60
                radius: 12
                gradient: Gradient {
                    GradientStop { position: 0; color: "#4facfe" }
                    GradientStop { position: 1; color: "#00f2fe" }
                }

                Text {
                    text: "GİRİŞ YAP"
                    color: "#000000"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: loginMouseArea
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: parent.scale = 1.02
                    onExited:  parent.scale = 1.0

                    onClicked: {
                        console.log("=== LOGIN BUTTON CLICKED ===")

                        const username = usernameField.text.trim()
                        const password = passwordField.text.trim()

                        if (username === "" || password === "") {
                            errorMessage = "Username or password cannot be empty."
                            return
                        }

                        if (typeof deviceManager === "undefined") {
                            errorMessage = "DeviceManager not found. Please restart the application."
                            return
                        }

                        try {
                            console.log("➡️ Attempting login for: " + username)
                            var loginResult = deviceManager.verifyDoctorLogin(username, password)
                            console.log("✅ Login result: " + loginResult)

                            if (loginResult) {
                                deviceManager.userRole = "doctor"
                                errorMessage = ""
                                successMessage.visible = true
                                console.log("✅ User role set to doctor")

                                var stackView = findStackView()
                                if (stackView) {
                                    try {
                                        console.log("➡️ Loading DoctorView...")
                                        stackView.push(Qt.resolvedUrl("DoctorView.qml"))
                                        console.log("✅ DoctorView loaded")
                                    } catch (pushErr) {
                                        errorMessage = "Page load error: " + pushErr
                                        console.error("❌ DoctorView failed to load:", pushErr)
                                    }
                                } else {
                                    errorMessage = "Navigation error: StackView not found."
                                    console.error("❌ StackView not found.")
                                }
                            } else {
                                errorMessage = "Invalid username or password."
                                console.warn("⚠️ Login rejected")
                            }
                        } catch (error) {
                            errorMessage = "An error occurred during login: " + error
                            console.error("❌ Error during login:", error)
                        }
                    }
                }

                Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutQuart } }

                // Delayed navigation timer (optional fallback)
                Timer {
                    id: delayTimer
                    interval: 1000
                    repeat: false
                    onTriggered: {
                        var stackView = findStackView()
                        if (stackView) {
                            try {
                                if (stackView.push) {
                                    console.log("Trying navigation with push()...")
                                    stackView.push("DoctorView.qml")
                                } else if (stackView.replace) {
                                    console.log("Trying navigation with replace()...")
                                    stackView.replace("DoctorView.qml")
                                }
                            } catch (pushError) {
                                console.log("❌ Push/Replace error:", pushError)
                                errorMessage = "Page load error: " + pushError
                            }
                        }
                        successMessage.visible = false
                    }
                }
            }

            // Bottom action buttons
            Row {
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 120
                    height: 45
                    radius: 8
                    color: Qt.rgba(255, 255, 255, 0.1)
                    border.color: Qt.rgba(255, 255, 255, 0.2)
                    border.width: 1

                    Text {
                        text: "⬅ Geri"
                        color: "white"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = Qt.rgba(255, 255, 255, 0.2)
                        onExited:  parent.color = Qt.rgba(255, 255, 255, 0.1)
                        onClicked: {
                            var stackView = findStackView()
                            if (stackView) {
                                stackView.pop()
                            }
                        }
                    }

                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                Rectangle {
                    width: 120
                    height: 45
                    radius: 8
                    color: Qt.rgba(79/255, 172/255, 254/255, 0.1)
                    border.color: Qt.rgba(79/255, 172/255, 254/255, 0.3)
                    border.width: 1

                    Text {
                        text: "Kaydol"
                        color: "#4facfe"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = Qt.rgba(79/255, 172/255, 254/255, 0.2)
                        onExited:  parent.color = Qt.rgba(79/255, 172/255, 254/255, 0.1)
                        onClicked: {
                            var stackView = findStackView()
                            if (stackView) {
                                stackView.push(Qt.resolvedUrl("DoctorRegister.qml"))
                            } else {
                                console.error("StackView not found.")
                            }
                        }
                    }

                    Behavior on color { ColorAnimation { duration: 200 } }
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("=== LOGIN PAGE LOADED ===")
        console.log("DeviceManager available:", typeof deviceManager !== "undefined")

        var stackView = findStackView()
        if (stackView) {
            console.log("✅ StackView found on component completion")
        } else {
            console.log("❌ StackView NOT found on component completion")
        }
    }
}
