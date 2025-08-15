import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15
import QtCore 6.2

Item {
    id: visitorView
    width: parent ? parent.width : 1000
    height: parent ? parent.height : 700

    // ── State ──────────────────────────────────────────────────────────────────
    property string enteredName: ""
    property string enteredSurname: ""
    property string enteredTC: ""
    property string currentPatientId: ""

    property var patient: ({})
    property var patientHistory: []

    // ── Helpers ────────────────────────────────────────────────────────────────
    function resetResults() {
        patient = {}
        currentPatientId = ""
        patientHistory = []
    }

    function findStackView() {
        var item = visitorView
        var maxDepth = 20
        var depth = 0
        while (item && depth < maxDepth) {
            if (item.objectName === "mainStackView" || (typeof item.push === "function" && typeof item.pop === "function")) {
                return item
            }
            item = item.parent
            depth++
        }
        return null
    }

    // ── UI ────────────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#f8fafc" }
            GradientStop { position: 1.0; color: "#e2e8f0" }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 20

            // Header bar
            Rectangle {
                width: parent.width
                height: 70
                radius: 12
                color: "#ffffff"
                border.color: "#0ea5e9"
                border.width: 2

                Row {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 16

                    Button {
                        id: backBtn
                        text: "← Ana Sayfa"
                        width: 160
                        height: 40
                        anchors.verticalCenter: parent.verticalCenter

                        background: Rectangle {
                            radius: 8
                            color: backBtn.pressed ? "#0369a1" : (backBtn.hovered ? "#0284c7" : "#0ea5e9")
                            border.color: "#0284c7"
                            border.width: 1
                        }

                        contentItem: Text {
                            text: backBtn.text
                            color: "#ffffff"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            const st = findStackView()
                            if (st) st.pop()
                        }
                    }

                    Item {
                        width: parent.width - 160 - 380 - 32
                        height: 1
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 4
                            height: 30
                            color: "#059669"
                            radius: 2
                        }

                        Text {
                            text: "Hasta Geçmişi Sorgulama"
                            color: "#1e293b"
                            font.pixelSize: 24
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: "#dcfce7"
                            border.color: "#059669"
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: "📊"
                                font.pixelSize: 16
                            }
                        }
                    }
                }
            }

            // Search form
            Rectangle {
                width: parent.width
                height: 220
                radius: 16
                color: "#ffffff"
                border.color: "#e2e8f0"
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 20

                    // Form header
                    Row {
                        width: parent.width
                        spacing: 12

                        Rectangle {
                            width: 6
                            height: 24
                            color: "#3b82f6"
                            radius: 3
                        }

                        Text {
                            text: "Hasta Bilgileri"
                            color: "#1e293b"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Form fields row
                    Row {
                        width: parent.width
                        spacing: 16

                        // Name field
                        Column {
                            width: (parent.width - 32 - 200 - 140) / 2
                            spacing: 6

                            Text {
                                text: "Ad *"
                                color: "#475569"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                            }

                            Rectangle {
                                width: parent.width
                                height: 44
                                radius: 10
                                color: "#ffffff"
                                border.color: nameField.activeFocus ? "#3b82f6" : "#cbd5e1"
                                border.width: nameField.activeFocus ? 2 : 1

                                TextField {
                                    id: nameField
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    placeholderText: "Hasta adını giriniz"
                                    text: enteredName
                                    onTextChanged: enteredName = text

                                    background: Rectangle {
                                        color: "transparent"
                                        radius: 9
                                    }

                                    color: "#1e293b"
                                    font.pixelSize: 14
                                    leftPadding: 12
                                    rightPadding: 12
                                    verticalAlignment: TextInput.AlignVCenter
                                    placeholderTextColor: "#94a3b8"
                                }
                            }
                        }

                        // Surname field
                        Column {
                            width: (parent.width - 32 - 200 - 140) / 2
                            spacing: 6

                            Text {
                                text: "Soyad *"
                                color: "#475569"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                            }

                            Rectangle {
                                width: parent.width
                                height: 44
                                radius: 10
                                color: "#ffffff"
                                border.color: surnameField.activeFocus ? "#3b82f6" : "#cbd5e1"
                                border.width: surnameField.activeFocus ? 2 : 1

                                TextField {
                                    id: surnameField
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    placeholderText: "Hasta soyadını giriniz"
                                    text: enteredSurname
                                    onTextChanged: enteredSurname = text

                                    background: Rectangle {
                                        color: "transparent"
                                        radius: 9
                                    }

                                    color: "#1e293b"
                                    font.pixelSize: 14
                                    leftPadding: 12
                                    rightPadding: 12
                                    verticalAlignment: TextInput.AlignVCenter
                                    placeholderTextColor: "#94a3b8"
                                }
                            }
                        }

                        // TC field
                        Column {
                            width: 200
                            spacing: 6

                            Text {
                                text: "TC Kimlik No *"
                                color: "#475569"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                            }

                            Rectangle {
                                width: parent.width
                                height: 44
                                radius: 10
                                color: "#ffffff"
                                border.color: tcField.activeFocus ? "#3b82f6" : "#cbd5e1"
                                border.width: tcField.activeFocus ? 2 : 1

                                TextField {
                                    id: tcField
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    placeholderText: "11 haneli TC no"
                                    text: enteredTC
                                    onTextChanged: enteredTC = text
                                    inputMethodHints: Qt.ImhDigitsOnly
                                    validator: RegularExpressionValidator { regularExpression: /\d{11}/ }

                                    background: Rectangle {
                                        color: "transparent"
                                        radius: 9
                                    }

                                    color: "#1e293b"
                                    font.pixelSize: 14
                                    leftPadding: 12
                                    rightPadding: 12
                                    verticalAlignment: TextInput.AlignVCenter
                                    placeholderTextColor: "#94a3b8"
                                }
                            }
                        }

                        // Query button
                        Column {
                            width: 140
                            spacing: 6

                            Text {
                                text: " "
                                font.pixelSize: 14
                                height: 20
                            }

                            Button {
                                id: queryBtn
                                text: "🔍 Sorgula"
                                width: 140
                                height: 44

                                background: Rectangle {
                                    radius: 10
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: queryBtn.pressed ? "#059669" : (queryBtn.hovered ? "#10b981" : "#059669") }
                                        GradientStop { position: 1.0; color: queryBtn.pressed ? "#047857" : (queryBtn.hovered ? "#059669" : "#047857") }
                                    }
                                    border.color: "#047857"
                                    border.width: 1
                                }

                                contentItem: Text {
                                    text: queryBtn.text
                                    color: "#ffffff"
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    if (enteredName.trim() === "" || enteredSurname.trim() === "" || enteredTC.length !== 11) {
                                        infoDialog.title = "Uyarı"
                                        infoDialog.text = "Lütfen Ad, Soyad ve 11 haneli TC bilgilerini doğru giriniz."
                                        infoDialog.open()
                                        return
                                    }


                                    resetResults()

                                    var p = {}
                                    try { p = deviceManager.findPatient(enteredName, enteredSurname, enteredTC) } catch (e) { p = {} }

                                    if (p && p.patient_id) {
                                        patient = p
                                        currentPatientId = p.patient_id

                                        var list = []
                                        try { list = deviceManager.getRecentMeasurements(currentPatientId, 100) } catch (e) { list = [] }

                                        patientHistory = list
                                        if (patientHistory.length === 0) {
                                            infoDialog.title = "Bilgi"
                                            infoDialog.text = "Bu hastaya ait geçmiş veri bulunamadı."
                                            infoDialog.open()
                                        }
                                    } else {
                                        infoDialog.title = "Bulunamadı"
                                        infoDialog.text = "Girilen bilgilerle hasta bulunamadı."
                                        infoDialog.open()
                                    }
                                }
                            }
                        }
                    }

                    // Patient summary
                    Rectangle {
                        width: parent.width
                        height: 60
                        visible: currentPatientId !== ""
                        radius: 12
                        color: "#f0f9ff"
                        border.color: "#0ea5e9"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 20

                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: "#10b981"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text { text: "Hasta:"; color: "#475569"; font.weight: Font.Medium; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: (patient.name || "-") + " " + (patient.surname || "-"); color: "#1e293b"; font.weight: Font.Bold; font.pixelSize: 16; anchors.verticalCenter: parent.verticalCenter }

                            Rectangle { width: 2; height: 20; color: "#cbd5e1"; radius: 1; anchors.verticalCenter: parent.verticalCenter }

                            Text { text: "TC:"; color: "#475569"; font.weight: Font.Medium; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: patient.tc || "-"; color: "#1e293b"; font.weight: Font.Bold; anchors.verticalCenter: parent.verticalCenter }

                            Rectangle { width: 2; height: 20; color: "#cbd5e1"; radius: 1; anchors.verticalCenter: parent.verticalCenter }

                            Text { text: "ID:"; color: "#475569"; font.weight: Font.Medium; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: currentPatientId; color: "#1e293b"; font.weight: Font.Bold; anchors.verticalCenter: parent.verticalCenter }

                            // Flexible spacer
                            Item {
                                width: Math.max(10, parent.width - 620)
                                height: 1
                            }

                            Button {
                                text: "🔄 Yenile"
                                enabled: currentPatientId !== ""
                                width: 100
                                height: 36
                                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                                Layout.rightMargin: 24


                                background: Rectangle {
                                    radius: 8
                                    color: parent.pressed ? "#f59e0b" : (parent.hovered ? "#fbbf24" : "#f59e0b")
                                    border.color: "#d97706"
                                    border.width: 1
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    var list = []
                                    try { list = deviceManager.getRecentMeasurements(currentPatientId, 100) } catch (e) { list = [] }
                                    patientHistory = list
                                }
                            }
                        }
                    }
                }
            }

            // Data table
            Rectangle {
                width: parent.width
                height: parent.height - 70 - 220 - 40
                visible: patientHistory.length > 0
                radius: 16
                color: "#ffffff"
                border.color: "#e2e8f0"
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16

                    // Table header
                    Row {
                        width: parent.width
                        spacing: 12

                        Rectangle {
                            width: 6
                            height: 24
                            color: "#3b82f6"
                            radius: 3
                        }

                        Text {
                            text: "Hasta Vital Kayıtları"
                            color: "#1e293b"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Rectangle {
                            width: 32
                            height: 20
                            radius: 10
                            color: "#dbeafe"
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: patientHistory.length.toString()
                                color: "#1d4ed8"
                                font.pixelSize: 12
                                font.weight: Font.Bold
                            }
                        }
                    }

                    // Table headers
                    Rectangle {
                        width: parent.width
                        height: 50
                        radius: 10
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#f8fafc" }
                            GradientStop { position: 1.0; color: "#e2e8f0" }
                        }
                        border.color: "#cbd5e1"
                        border.width: 1

                        Row {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16

                            Text { text: "📅 Tarih"; color: "#374151"; font.weight: Font.Bold; font.pixelSize: 14; width: 200 }
                            Text { text: "❤️ Kalp Atışı"; color: "#374151"; font.weight: Font.Bold; font.pixelSize: 14; width: 140 }
                            Text { text: "🫁 SpO₂"; color: "#374151"; font.weight: Font.Bold; font.pixelSize: 14; width: 120 }
                            Text { text: "🌬️ Solunum"; color: "#374151"; font.weight: Font.Bold; font.pixelSize: 14; width: 160 }
                        }
                    }

                    // Data rows
                    Rectangle {
                        width: parent.width
                        height: parent.height - 50 - 40 - 16
                        radius: 10
                        color: "#fafafa"
                        border.color: "#e5e7eb"
                        border.width: 1

                        ListView {
                            id: tableList
                            anchors.fill: parent
                            anchors.margins: 8
                            clip: true
                            spacing: 2
                            model: patientHistory

                            delegate: Rectangle {
                                width: ListView.view.width - 16
                                height: 50
                                radius: 8
                                color: index % 2 === 0 ? "#ffffff" : "#f8fafc"
                                border.color: "#f1f5f9"
                                border.width: 1

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 16

                                    Text {
                                        text: model.timestamp || "—"
                                        color: "#1e293b"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        width: 200
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Row {
                                        width: 140
                                        spacing: 8
                                        anchors.verticalCenter: parent.verticalCenter
                                        Rectangle {
                                            width: 8
                                            height: 8
                                            radius: 4
                                            color: {
                                                var hr = parseInt(model.heartRate || "0")
                                                if (hr < 60 || hr > 100) return "#ef4444"
                                                return "#10b981"
                                            }
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        Text {
                                            text: (model.heartRate || "—") + " bpm"
                                            color: "#374151"
                                            font.pixelSize: 13
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    Row {
                                        width: 120
                                        spacing: 8
                                        anchors.verticalCenter: parent.verticalCenter
                                        Rectangle {
                                            width: 8
                                            height: 8
                                            radius: 4
                                            color: {
                                                var spo2 = parseInt(model.spo2 || "0")
                                                if (spo2 < 95) return "#ef4444"
                                                return "#10b981"
                                            }
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        Text {
                                            text: (model.spo2 || "—") + "%"
                                            color: "#374151"
                                            font.pixelSize: 13
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    Row {
                                        width: 160
                                        spacing: 8
                                        anchors.verticalCenter: parent.verticalCenter
                                        Rectangle {
                                            width: 8
                                            height: 8
                                            radius: 4
                                            color: {
                                                var resp = parseInt(model.resp || "0")
                                                if (resp < 12 || resp > 20) return "#f59e0b"
                                                return "#10b981"
                                            }
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        Text {
                                            text: (model.resp || "—") + "/dk"
                                            color: "#374151"
                                            font.pixelSize: 13
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                }
                            }

                            ScrollBar.vertical: ScrollBar {
                                policy: ScrollBar.AsNeeded

                                background: Rectangle {
                                    color: "#f1f5f9"
                                    radius: 4
                                }

                                contentItem: Rectangle {
                                    radius: 4
                                    color: parent.pressed ? "#64748b" : (parent.hovered ? "#94a3b8" : "#cbd5e1")
                                }
                            }
                        }
                    }
                }
            }

            // No data found state - patient found but no measurements
            Rectangle {
                width: parent.width
                height: parent.height - 70 - 220 - 40
                visible: patientHistory.length === 0 && currentPatientId !== ""
                radius: 16
                color: "#ffffff"
                border.color: "#e2e8f0"
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 16

                    Text {
                        text: "📊"
                        font.pixelSize: 48
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        opacity: 0.7
                    }

                    Text {
                        text: "Bu Hastaya Ait Kayıt Bulunamadı"
                        color: "#64748b"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "Hasta sistemde kayıtlı ancak henüz vital ölçüm verisi bulunmuyor.\nYeni ölçüm yapıldıktan sonra 'Yenile' butonuna basınız."
                        color: "#94a3b8"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Rectangle {
                        width: 200
                        height: 40
                        radius: 8
                        color: "#fef3c7"
                        border.color: "#f59e0b"
                        border.width: 1
                        anchors.horizontalCenter: parent.horizontalCenter

                        Row {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "⚠️"
                                font.pixelSize: 16
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: "Veri Bekleniyor"
                                color: "#92400e"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
            Rectangle {
                width: parent.width
                height: parent.height - 70 - 220 - 40
                visible: patientHistory.length === 0 && currentPatientId === ""
                radius: 16
                color: "#ffffff"
                border.color: "#e2e8f0"
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 16

                    Text {
                        text: "📋"
                        font.pixelSize: 48
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "Hasta Bilgilerini Girerek Başlayın"
                        color: "#64748b"
                        font.pixelSize: 18
                        font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "Hasta adı, soyadı ve TC kimlik numarasını girerek\nvital kayıtları sorgulayabilirsiniz."
                        color: "#94a3b8"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }

    // Message dialog placeholder
    Item {
        id: infoDialog
        property string title: ""
        property string text: ""
        function open() {
            console.log(title + ": " + text)
        }
    }
}
