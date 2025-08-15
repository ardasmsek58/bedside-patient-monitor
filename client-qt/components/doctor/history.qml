import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    anchors.fill: parent
    property StackView stackView
    property string selectedPatientId: ""

    // Debug info when the component is loaded
    Component.onCompleted: {
        console.log("📊 History.qml loaded. Patient ID:", selectedPatientId)
        if (selectedPatientId && selectedPatientId !== "") {
            loadHistoryData()
        } else {
            console.warn("❌ History.qml - Patient ID is empty!")
        }
    }

    // Auto-refresh timer — updates every 3 seconds
    Timer {
        id: updateTimer
        interval: 3000 // 3 seconds
        repeat: true
        running: selectedPatientId !== ""
        onTriggered: {
            if (selectedPatientId && selectedPatientId !== "") {
                loadHistoryData()
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // Back button and title
            Row {
                spacing: 20
                height: 40

                Button {
                    text: "◀ Geri"
                    width: 100
                    height: 40
                    font.bold: true
                    background: Rectangle {
                        color: "#4CAF50"
                        radius: 6
                    }
                    onClicked: {
                        console.log("📊 History - Back button clicked")
                        updateTimer.stop()

                        // Restart monitoring when returning
                        if (typeof deviceManager !== "undefined") {
                            deviceManager.startMonitoring()
                        }

                        // Find StackView and navigate back
                        var stackView = findStackView()
                        if (stackView) {
                            console.log("✅ StackView found, popping...")
                            stackView.pop()
                        } else {
                            console.error("❌ StackView not found!")
                        }
                    }
                }

                Text {
                    text: "Geçmiş Ölçümler" + (selectedPatientId ? " (ID: " + selectedPatientId + ")" : "")
                    color: "white"
                    font.pixelSize: 22
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // Header row
            Rectangle {
                width: parent.width
                height: 40
                radius: 6
                color: "#2d2d30"
                border.color: "#4CAF50"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Label {
                        text: "TARİH/SAAT"
                        color: "#4CAF50"
                        font.pixelSize: 14
                        font.bold: true
                        Layout.preferredWidth: 200
                    }

                    Label {
                        text: "HEART RATE"
                        color: "#4CAF50"
                        font.pixelSize: 14
                        font.bold: true
                        Layout.preferredWidth: 100
                    }

                    Label {
                        text: "SpO₂(Saturation)"
                        color: "#4CAF50"
                        font.pixelSize: 14
                        font.bold: true
                        Layout.preferredWidth: 100
                    }

                    Label {
                        text: "Resp (Respiration)"
                        color: "#4CAF50"
                        font.pixelSize: 14
                        font.bold: true
                        Layout.preferredWidth: 100
                    }
                }
            }

            // Loading / empty state
            Rectangle {
                width: parent.width
                height: 40
                color: "transparent"
                visible: historyModel.count === 0

                Text {
                    anchors.centerIn: parent
                    text: selectedPatientId ? "📊 Loading data..." : "❌ No patient selected"
                    color: "#888888"
                    font.pixelSize: 16
                }
            }

            // List area
            ListView {
                id: historyListView
                width: parent.width
                height: parent.height - 160
                model: ListModel { id: historyModel }
                spacing: 6
                clip: true

                delegate: Rectangle {
                    width: historyListView.width
                    height: 50
                    radius: 6
                    color: index % 2 === 0 ? "#2d2d30" : "#333333"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Label {
                            text: timestamp || "N/A"
                            color: "#ffffff"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            Layout.preferredWidth: 200
                        }

                        Rectangle {
                            height: 30
                            radius: 6
                            color: "#4CAF50"
                            Layout.preferredWidth: 100
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: (heartRate || 0) + " bpm"
                                color: "white"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }

                        Rectangle {
                            height: 30
                            radius: 6
                            color: "#2196F3"
                            Layout.preferredWidth: 100
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: (spo2 || 0) + " %"
                                color: "white"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }

                        Rectangle {
                            height: 30
                            radius: 6
                            color: "yellow"
                            Layout.preferredWidth: 100
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: (resp || 0) + " %"
                                color: "black"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }
    }

    // Data loading function
    function loadHistoryData() {
        if (!selectedPatientId || selectedPatientId === "") {
            console.warn("❌ loadHistoryData - Patient ID is not specified!")
            return
        }

        console.log("📊 Loading history data. Patient ID:", selectedPatientId)

        historyModel.clear()

        if (typeof deviceManager === "undefined") {
            console.warn("❌ deviceManager is undefined!")
            return
        }

        try {
            var measurements = deviceManager.getRecentMeasurementsForPatient(selectedPatientId, 50)
            console.log("📊 Number of measurements found:", measurements.length)

            for (var i = 0; i < measurements.length; ++i) {
                historyModel.append({
                    timestamp: measurements[i].timestamp || "N/A",
                    heartRate: measurements[i].heartRate || 0,
                    spo2: measurements[i].spo2 || 0,
                    resp: measurements[i].resp || 0
                })
            }

            if (measurements.length === 0) {
                console.log("ℹ️ No recorded measurements found for this patient")
            }

        } catch (error) {
            console.error("❌ Error while loading data:", error)
        }
    }

    // Helper to find the nearest StackView
    function findStackView() {
        var item = root
        var maxDepth = 20
        var depth = 0

        while (item && depth < maxDepth) {
            if (item.objectName === "mainStackView" ||
                (typeof item.push === "function" && typeof item.pop === "function")) {
                return item
            }
            item = item.parent
            depth++
        }

        console.warn("❌ StackView not found")
        return null
    }
}
