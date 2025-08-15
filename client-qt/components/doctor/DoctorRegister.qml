import QtQuick 2.15
import QtQuick.Controls 2.15
import SMMProtocol 1.0 // Custom module for deviceManager and backend communication

/*
  📄 DoctorRegister.qml
  ---------------------
  Purpose:
    - Displays the doctor registration interface
    - Allows new doctors to create an account with username & password
    - Validates form fields before submitting
    - Calls deviceManager.registerDoctor(username, password) for registration logic

  ⚠️ Warnings:
    - Passwords are currently validated only on length (>= 6) and match
      → No complexity rules (uppercase, symbols, etc.)
    - Username uniqueness check depends entirely on deviceManager.registerDoctor implementation
    - This QML file directly interacts with deviceManager C++ backend
*/

Item {
    id: registerPage
    width: parent ? parent.width : 800
    height: parent ? parent.height : 600

    // State variables for messages
    property string errorMessage: ""
    property string successMessage: ""

    /* 🔹 Background Gradient & Floating Particles */
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0c0c0c" }
            GradientStop { position: 0.5; color: "#1a1a2e" }
            GradientStop { position: 1.0; color: "#16213e" }
        }

        // Decorative floating circles
        Repeater {
            model: 4
            Rectangle {
                width: Math.random() * 4 + 2
                height: width
                radius: width / 2
                color: "#4facfe"
                opacity: 0.08
                x: Math.random() * parent.width
                y: Math.random() * parent.height

                SequentialAnimation on y {
                    loops: Animation.Infinite
                    PropertyAnimation { to: y - 20; duration: 3000; easing.type: Easing.InOutSine }
                    PropertyAnimation { to: y; duration: 3000; easing.type: Easing.InOutSine }
                }
            }
        }
    }

    /* 🔹 Shadow Layer Behind Registration Box */
    Rectangle {
        id: shadowBox
        width: 450; height: 650
        radius: 20
        color: "#000000"
        opacity: 0.1
        anchors.centerIn: parent
        y: parent.height / 2 + 10
        z: 0
    }

    /* 🔹 Main Registration Box */
    Rectangle {
        id: registerBox
        width: 450; height: 650
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

            /* 🔹 Title Section */
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
                    text: "Doktor Kaydı" // User-facing text remains in Turkish
                    color: "white"
                    font.pixelSize: 20
                    font.weight: Font.Medium
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            /* 🔹 Success Message Box */
            Rectangle {
                width: parent.width
                height: successText.height + 20
                radius: 8
                color: Qt.rgba(76/255, 175/255, 80/255, 0.1)
                border.color: Qt.rgba(76/255, 175/255, 80/255, 0.3)
                visible: successMessage !== ""

                Text {
                    id: successText
                    text: successMessage
                    color: "#4CAF50"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    anchors.centerIn: parent
                    wrapMode: Text.WordWrap
                    width: parent.width - 20
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            /* 🔹 Error Message Box */
            Rectangle {
                width: parent.width
                height: errorText.height + 20
                radius: 8
                color: Qt.rgba(255/255, 193/255, 7/255, 0.1)
                border.color: Qt.rgba(255/255, 193/255, 7/255, 0.3)
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
            // Username field
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
                    color: Qt.rgba(15 / 255, 52 / 255, 96 / 255, 0.6)
                    border.color: Qt.rgba(79 / 255, 172 / 255, 254 / 255, 0.2)
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
                                usernameRect.border.color = Qt.rgba(79 / 255,
                                                                    172 / 255,
                                                                    254 / 255,
                                                                    0.2)
                                usernameRect.scale = 1.0
                            }
                        }
                    }

                    Text {
                        id: userIcon
                        text: "👤"
                        color: Qt.rgba(79 / 255, 172 / 255, 254 / 255, 0.7)
                        font.pixelSize: 18
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }
            }

            // Password field
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
                    color: Qt.rgba(15 / 255, 52 / 255, 96 / 255, 0.6)
                    border.color: Qt.rgba(79 / 255, 172 / 255, 254 / 255, 0.2)
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
                                passwordRect.border.color = Qt.rgba(79 / 255,
                                                                    172 / 255,
                                                                    254 / 255,
                                                                    0.2)
                                passwordRect.scale = 1.0
                            }
                        }
                    }

                    Text {
                        id: lockIcon
                        text: "🔒"
                        color: Qt.rgba(79 / 255, 172 / 255, 254 / 255, 0.7)
                        font.pixelSize: 18
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }
            }

            // Confirm Password field
            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: "Şifre Tekrar"
                    color: "#4facfe"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    x: 20
                }

                Rectangle {
                    id: confirmPasswordRect
                    width: parent.width
                    height: 55
                    radius: 12
                    color: Qt.rgba(15 / 255, 52 / 255, 96 / 255, 0.6)
                    border.color: Qt.rgba(79 / 255, 172 / 255, 254 / 255, 0.2)
                    border.width: 2

                    TextInput {
                        id: confirmPasswordField
                        anchors.left: parent.left
                        anchors.leftMargin: 25
                        anchors.right: confirmLockIcon.left
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        font.pixelSize: 16
                        echoMode: TextInput.Password
                        selectByMouse: true
                        clip: true

                        Text {
                            text: "Şifrenizi tekrar girin"
                            color: Qt.rgba(255, 255, 255, 0.5)
                            font.pixelSize: 16
                            visible: confirmPasswordField.text === ""
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        onActiveFocusChanged: {
                            if (activeFocus) {
                                confirmPasswordRect.border.color = "#4facfe"
                                confirmPasswordRect.scale = 1.01
                            } else {
                                confirmPasswordRect.border.color = Qt.rgba(
                                            79 / 255, 172 / 255, 254 / 255, 0.2)
                                confirmPasswordRect.scale = 1.0
                            }
                        }
                    }

                    Text {
                        id: confirmLockIcon
                        text: "🔐"
                        color: Qt.rgba(79 / 255, 172 / 255, 254 / 255, 0.7)
                        font.pixelSize: 18
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }
            }

            // Register button
            Rectangle {
                id: registerBtn
                width: parent.width
                height: 60
                radius: 12
                anchors.horizontalCenter: parent.horizontalCenter

                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: "#4facfe"
                    }
                    GradientStop {
                        position: 1
                        color: "#00f2fe"
                    }
                }

                Text {
                    text: "KAYDOL"
                    color: "#000000"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    font.letterSpacing: 1
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {
                        parent.scale = 1.02
                    }

                    onExited: {
                        parent.scale = 1.0
                    }

                    onClicked: {
                        const username = usernameField.text.trim()
                        const password = passwordField.text.trim()
                        const confirmPassword = confirmPasswordField.text.trim()

                        if (username === "" || password === ""
                                || confirmPassword === "") {
                            errorMessage = "Tüm alanlar doldurulmalıdır."
                            successMessage = ""
                            return
                        }

                        if (password !== confirmPassword) {
                            errorMessage = "Şifreler eşleşmiyor."
                            successMessage = ""
                            return
                        }

                        if (password.length < 6) {
                            errorMessage = "Şifre en az 6 karakter olmalıdır."
                            successMessage = ""
                            return
                        }

                        if (deviceManager.registerDoctor(username, password)) {
                            successMessage = "Kayıt başarılı! Giriş yapabilirsiniz."
                            errorMessage = ""
                            usernameField.text = ""
                            passwordField.text = ""
                            confirmPasswordField.text = ""

                            // 2 saniye sonra login sayfasına yönlendir
                            redirectTimer.start()
                        } else {
                            errorMessage = "Bu kullanıcı adı zaten kayıtlı."
                            successMessage = ""
                        }
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutQuart
                    }
                }
            }

            // Bottom buttons
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20

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

                        onEntered: {
                            parent.color = Qt.rgba(255, 255, 255, 0.2)
                        }

                        onExited: {
                            parent.color = Qt.rgba(255, 255, 255, 0.1)
                        }

                        onClicked: {
                            var item = registerPage
                            while (item) {
                                if (item.objectName === "mainStackView"
                                        || (item.hasOwnProperty('push')
                                            && item.hasOwnProperty('pop'))) {
                                    item.pop()
                                    return
                                }
                                item = item.parent
                            }
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }

                Rectangle {
                    width: 120
                    height: 45
                    radius: 8
                    color: Qt.rgba(79 / 255, 172 / 255, 254 / 255, 0.1)
                    border.color: Qt.rgba(79 / 255, 172 / 255, 254 / 255, 0.3)
                    border.width: 1

                    Text {
                        text: "Giriş Yap"
                        color: "#4facfe"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        onEntered: {
                            parent.color = Qt.rgba(79 / 255, 172 / 255,
                                                   254 / 255, 0.2)
                        }

                        onExited: {
                            parent.color = Qt.rgba(79 / 255, 172 / 255,
                                                   254 / 255, 0.1)
                        }

                        onClicked: {
                            var item = registerPage
                            while (item) {
                                if (item.objectName === "mainStackView"
                                        || (item.hasOwnProperty('push')
                                            && item.hasOwnProperty('pop'))) {
                                    item.pop()
                                    return
                                }
                                item = item.parent
                            }
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }
            }
        }
    }

    /* 🔹 Timer for redirecting to login page after success */
        Timer {
            id: redirectTimer
            interval: 2000
            onTriggered: {
                // ⚠️ Ensure mainStackView exists when navigating
                Qt.application.stack.pop()
            }
        }
}
