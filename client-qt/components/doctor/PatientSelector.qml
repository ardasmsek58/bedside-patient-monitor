import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import QtCore 6.2
import SMMProtocol 1.0

Item {
    id: selector
    width: parent ? parent.width : 1200
    height: 50

    property bool safeTestMode: deviceManager ? deviceManager.testMode : false

    signal patientChosen(string patientId, string name, string surname)

    Rectangle {
        id: modeBar
        anchors.fill: parent
        color: "#0a0a0a"

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // LEFT: Select Patient button
            Button {
                id: selectPatientButton
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: selectedPatientId ? selectedName + " " + selectedSurname : "Hasta Seçiniz"
                font.pixelSize: 13
                font.bold: true
                hoverEnabled: true

                background: Rectangle {
                    color: parent.pressed ? "#3a3a3a" : (parent.hovered ? "#4CAF50" : "#2a2a2a")
                    border.color: "#555"
                    border.width: 2
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: parent.font.pixelSize
                    font.bold: parent.font.bold
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                onClicked: patientSelectDialog.open()
            }

            // Mode indicator (Test vs Normal)
            Rectangle {
                Layout.preferredWidth: parent.width * 0.90
                Layout.fillHeight: true
                color: safeTestMode ? "darkred" : "#2e7d32"

                Text {
                    anchors.centerIn: parent
                    text: safeTestMode ? "TEST MODE" : "NORMAL MODE"
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                }
            }
        }
    }

    // ✅ Patient selection dialog
    Dialog {
        id: patientSelectDialog
        title: "Hasta Seçimi"
        modal: true
        width: 500
        height: 600
        anchors.centerIn: Overlay.overlay

        onOpened: {
            // Refresh list when dialog opens
            refreshPatientList()
        }

        Overlay.modal: Rectangle {
            color: "#aa000000"
        }

        background: Rectangle {
            color: "#1a1a1a"
            border.color: "#555"
            border.width: 2
            radius: 12

            // Subtle gradient overlay
            Rectangle {
                anchors.fill: parent
                radius: 12
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#2a2a2a" }
                    GradientStop { position: 1.0; color: "#1a1a1a" }
                }
            }
        }

        header: Rectangle {
            height: 60
            color: "transparent"

            Text {
                anchors.centerIn: parent
                text: "👥 Hasta Seçimi"
                color: "#4CAF50"
                font.pixelSize: 18
                font.bold: true
            }

            Rectangle {
                width: parent.width * 0.8
                height: 2
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#4CAF50"
                radius: 1
            }
        }

        contentItem: Rectangle {
            color: "transparent"

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                Text {
                    text: "Lütfen bir hasta seçin:"
                    color: "#ccc"
                    font.pixelSize: 16
                    font.bold: true
                }

                // Table header row
                Rectangle {
                    width: parent.width
                    height: 45
                    color: "#333"
                    border.color: "#555"
                    border.width: 1
                    radius: 8

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15

                        // No column
                        Text {
                            width: 50
                            height: parent.height
                            text: "No"
                            color: "#4CAF50"
                            font.pixelSize: 14
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }

                        // Divider
                        Rectangle {
                            width: 1
                            height: parent.height * 0.6
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#555"
                        }

                        // Name column
                        Text {
                            width: 120
                            height: parent.height
                            text: "Ad"
                            color: "#4CAF50"
                            font.pixelSize: 14
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 15
                        }

                        // Divider
                        Rectangle {
                            width: 1
                            height: parent.height * 0.6
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#555"
                        }

                        // Surname column
                        Text {
                            width: parent.parent.width - 200 // Remaining width
                            height: parent.height
                            text: "Soyad"
                            color: "#4CAF50"
                            font.pixelSize: 14
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 15
                        }
                    }
                }

                // Patient list
                Rectangle {
                    width: parent.width
                    height: parent.height - 110 // Leave space for header and footer
                    color: "#2a2a2a"
                    border.color: "#555"
                    border.width: 1
                    radius: 8
                    clip: true

                    ListView {
                        id: patientListView
                        anchors.fill: parent
                        anchors.margins: 1
                        model: patientModel
                        clip: true

                        delegate: Rectangle {
                            width: patientListView.width
                            height: 50
                            color: mouseArea.containsMouse ? "#388E3C" : (index % 2 === 0 ? "#2a2a2a" : "#333")

                            // Highlight currently selected patient
                            border.color: selectedPatientId === model.patient_id ? "#4CAF50" : "transparent"
                            border.width: selectedPatientId === model.patient_id ? 2 : 0

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 15
                                anchors.rightMargin: 15

                                // No column
                                Text {
                                    width: 50
                                    height: parent.height
                                    text: (index + 1).toString()
                                    color: selectedPatientId === model.patient_id ? "#4CAF50" : "white"
                                    font.pixelSize: 14
                                    font.bold: selectedPatientId === model.patient_id
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                // Divider
                                Rectangle {
                                    width: 1
                                    height: parent.height * 0.6
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: "#555"
                                }

                                // Name column
                                Text {
                                    width: 120
                                    height: parent.height
                                    text: model.name
                                    color: selectedPatientId === model.patient_id ? "#4CAF50" : "white"
                                    font.pixelSize: 14
                                    font.bold: selectedPatientId === model.patient_id
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 15
                                    elide: Text.ElideRight
                                }

                                // Divider
                                Rectangle {
                                    width: 1
                                    height: parent.height * 0.6
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: "#555"
                                }

                                // Surname column
                                Text {
                                    width: parent.parent.width - 200
                                    height: parent.height
                                    text: model.surname
                                    color: selectedPatientId === model.patient_id ? "#4CAF50" : "white"
                                    font.pixelSize: 14
                                    font.bold: selectedPatientId === model.patient_id
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 15
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true

                                onClicked: {
                                    // Update local props (optional)
                                    selectedPatientId = model.patient_id
                                    selectedName = model.name
                                    selectedSurname = model.surname

                                    if (deviceManager) {
                                        deviceManager.setCurrentPatientId(model.patient_id)
                                    }

                                    console.log("✅ Patient selected:",
                                                "ID:", model.patient_id,
                                                "Name:", model.name, model.surname,
                                                "DM.currentPatientId:", deviceManager ? deviceManager.currentPatientId : "none")

                                    // 🔴 Critical: propagate to DoctorView
                                    patientChosen(model.patient_id, model.name, model.surname)

                                    patientSelectDialog.accept()
                                }
                            }

                            // Bottom separator
                            Rectangle {
                                width: parent.width * 0.9
                                height: 1
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: "#444"
                            }
                        }

                        // Empty state
                        Text {
                            visible: patientListView.count === 0
                            anchors.centerIn: parent
                            text: "📝 Henüz hasta kaydı bulunmamaktadır.\nYeni hasta eklemek için '+' butonunu kullanın."
                            color: "#888"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            lineHeight: 1.5
                        }
                    }

                    // Minimal scroll indicator
                    Rectangle {
                        visible: patientListView.contentHeight > patientListView.height
                        width: 4
                        height: parent.height * (patientListView.height / patientListView.contentHeight)
                        anchors.right: parent.right
                        anchors.rightMargin: 2
                        y: (patientListView.height - height) * (patientListView.contentY / (patientListView.contentHeight - patientListView.height))
                        color: "#4CAF50"
                        radius: 2
                        opacity: 0.7
                    }
                }
            }
        }

        footer: Rectangle {
            height: 70
            color: "transparent"

            RowLayout {
                anchors.centerIn: parent
                spacing: 20

                // Close button
                Button {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    text: "❌ Kapat"
                    font.pixelSize: 14
                    font.bold: true

                    background: Rectangle {
                        color: parent.pressed ? "#666" : "#444"
                        border.color: "#888"
                        border.width: 1
                        radius: 8
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: parent.font.pixelSize
                        font.bold: parent.font.bold
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: patientSelectDialog.reject()
                }

                // Add new patient button
                Button {
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 40
                    text: "➕ Yeni Hasta Ekle"
                    font.pixelSize: 14
                    font.bold: true
                    background: Rectangle {
                        color: parent.pressed ? "#388E3C" : "#4CAF50"
                        border.color: "#66BB6A"
                        border.width: 1
                        radius: 8
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: parent.font.pixelSize
                        font.bold: parent.font.bold
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("➕ Opening 'add new patient' dialog")
                        patientDialog.open()
                    }
                }
            }
        }

        onRejected: {
            console.log("📋 Patient selection canceled")
        }

        onAccepted: {
            console.log("✅ Patient selection completed:", selectedPatientId)
        }
    }

    // Dialog to add a new patient
    Dialog {
        id: patientDialog
        title: "Yeni Hasta Ekle"
        modal: true
        width: 400
        height: 400
        anchors.centerIn: Overlay.overlay

        Overlay.modal: Rectangle {
            color: "#aa000000"
        }

        background: Rectangle {
            color: "#1a1a1a"
            border.color: "#555"
            border.width: 2
            radius: 12

            // Subtle gradient
            Rectangle {
                anchors.fill: parent
                radius: 12
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#2a2a2a" }
                    GradientStop { position: 1.0; color: "#1a1a1a" }
                }
            }
        }

        header: Rectangle {
            height: 60
            color: "transparent"

            Text {
                anchors.centerIn: parent
                text: "👤 Yeni Hasta Ekle"
                color: "#4CAF50"
                font.pixelSize: 18
                font.bold: true
            }

            Rectangle {
                width: parent.width * 0.8
                height: 2
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#4CAF50"
                radius: 1
            }
        }

        contentItem: Rectangle {
            color: "transparent"

            Column {
                anchors.centerIn: parent
                spacing: 25
                width: parent.width * 0.8

                // Name field
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "Hasta Adı"
                        color: "#ccc"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    TextField {
                        id: nameField
                        width: parent.width
                        height: 45
                        placeholderText: "Hasta adını giriniz..."
                        font.pixelSize: 14
                        placeholderTextColor: "#FFFFFF"
                        color: "white"

                        background: Rectangle {
                            color: "#2a2a2a"
                            border.color: nameField.focus ? "#4CAF50" : "#555"
                            border.width: 2
                            radius: 8

                            Rectangle {
                                anchors.fill: parent
                                color: nameField.focus ? "#333" : "transparent"
                                radius: 8
                            }
                        }

                        leftPadding: 15
                        rightPadding: 15
                    }
                }

                // Surname field
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "Hasta Soyadı"
                        color: "#ccc"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    TextField {
                        id: surnameField
                        width: parent.width
                        height: 45
                        placeholderText: "Hasta soyadını giriniz..."
                        placeholderTextColor: "#FFFFFF"
                        font.pixelSize: 14
                        color: "white"

                        background: Rectangle {
                            color: "#2a2a2a"
                            border.color: surnameField.focus ? "#4CAF50" : "#555"
                            border.width: 2
                            radius: 8

                            Rectangle {
                                anchors.fill: parent
                                color: surnameField.focus ? "#333" : "transparent"
                                radius: 8
                            }
                        }

                        leftPadding: 15
                        rightPadding: 15
                    }
                }

                // National ID field
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "TC Kimlik No"
                        color: "#ccc"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    TextField {
                        id: tcField
                        width: parent.width
                        height: 45
                        placeholderText: "11 haneli TC kimlik numarası giriniz..."
                        placeholderTextColor: "#FFFFFF"
                        font.pixelSize: 14
                        color: "white"
                        inputMethodHints: Qt.ImhDigitsOnly

                        // ✅ Qt 6 compatible validator
                        validator: RegularExpressionValidator { regularExpression: /[0-9]{11}/ }

                        background: Rectangle {
                            color: "#2a2a2a"
                            border.color: tcField.focus ? "#4CAF50" : "#555"
                            border.width: 2
                            radius: 8
                        }

                        leftPadding: 15
                        rightPadding: 15
                    }
                }
            }
        }

        footer: Rectangle {
            height: 70
            color: "transparent"

            RowLayout {
                anchors.centerIn: parent
                spacing: 20

                // Cancel button
                Button {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    text: "❌ İptal"
                    font.pixelSize: 14
                    font.bold: true

                    background: Rectangle {
                        color: parent.pressed ? "#666" : "#444"
                        border.color: "#888"
                        border.width: 1
                        radius: 8
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: parent.font.pixelSize
                        font.bold: parent.font.bold
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: patientDialog.reject()
                }

                // Save button
                Button {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    text: "✅ Kaydet"
                    font.pixelSize: 14
                    font.bold: true

                    enabled: nameField.text.length > 0
                             && surnameField.text.length > 0
                             && /^[0-9]{11}$/.test(tcField.text)

                    background: Rectangle {
                        color: parent.pressed ? "#388E3C" : "#4CAF50"
                        border.color: "#66BB6A"
                        border.width: 1
                        radius: 8
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: parent.font.pixelSize
                        font.bold: parent.font.bold
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: patientDialog.accept()
                }
            }
        }

        onAccepted: {
            const name = nameField.text.trim()
            const surname = surnameField.text.trim()
            const tc = tcField.text.trim()
            const id = "P" + Date.now()

            if (name !== "" && surname !== "" && /^[0-9]{11}$/.test(tc)) {
                if (typeof deviceManager !== "undefined"
                        && deviceManager.addPatient(id, name, surname, tc)) {
                    patientModel.append({
                        "patient_id": id,
                        "name": name,
                        "surname": surname,
                        "displayName": name + " " + surname
                    })

                    selectedPatientId = id
                    selectedName = name
                    selectedSurname = surname
                    patientComboBox.currentIndex = patientModel.count - 1

                    console.log("✅ Patient added:", id)

                    // Clear fields
                    nameField.text = ""
                    surnameField.text = ""
                    tcField.text = ""
                } else {
                    console.log("❌ Failed to add patient!")
                }
            } else {
                console.log("⚠️ Please enter a valid name, surname, and 11-digit national ID.")
            }
        }

        onRejected: {
            // Clear fields when dialog is canceled
            nameField.text = ""
            surnameField.text = ""
            tcField.text = ""
        }
    }
}
