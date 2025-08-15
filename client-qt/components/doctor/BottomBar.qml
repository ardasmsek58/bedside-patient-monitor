import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCore 6.2

Item {
    id: bottomBarWrapper
    width: parent.width
    height: 80

    // --- Function to start print recording process ---
    function startPrintRecording() {
        isRecordingForPrint = true
        printWaveformData = []
        printTimestamps = []
        progressAnim.start()
        printTimer.start()
    }

    // --- Timer for print recording (5 seconds) ---
    Timer {
        id: printTimer
        interval: 5000
        running: false
        repeat: false
        onTriggered: {
            isRecordingForPrint = false
            openPrintDialogRequested()
            stopPrintRequested()
        }
    }

    // --- Opens the print dialog ---
    function showPrintDialog() {
        printDialog.open()
    }

    // --- Stops the print process ---
    function stopPrint() {
        isRecordingForPrint = false
        progressAnim.stop()
        printTimer.running = false
    }

    // --- Starts progress bar animation and print timer ---
    function startProgressAndTimer() {
        isRecordingForPrint = true
        progressFill.width = 0  // Reset progress width at the start
        progressAnim.start()
        printTimer.start()
    }

    // --- Selected patient ID (used for history and printing) ---
    property string selectedPatientId: ""
    onSelectedPatientIdChanged: console.log("🧭 BottomBar.selectedPatientId ->", selectedPatientId)

    // --- State variables for printing process ---
    property bool isRecordingForPrint: false
    property var printWaveformData
    property var printTimestamps
    property var printEcgData
    property var printEcgTimestamps

    // --- Signals for navigation and actions ---
    signal backRequested()
    signal printRequested()
    signal historyRequested(string patientId)
    signal exitConfirmed()
    signal startPrintRequested()
    signal stopPrintRequested()
    signal openPrintDialogRequested()

    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"
        border.color: "#333"
        border.width: 1

        RowLayout {
            id: footerRow
            anchors.centerIn: parent
            spacing: 30

            // ✅ Test Mode Toggle Button
            Loader {
                source: "TestModeButton.qml"
                width: 200
                height: 50
                onLoaded: {
                    item.toggled.connect(function (enabled) {
                        deviceManager.setTestMode(enabled)
                    })
                }
            }

            // ✅ Back Button
            Rectangle {
                width: 150
                height: 50
                radius: 10
                color: "#222222"
                border.color: "#444444"
                border.width: 1

                Button {
                    id: backButton
                    anchors.fill: parent
                    text: "⬅ Back to Home"

                    background: Rectangle {
                        color: backButton.pressed ? "#555555" : (backButton.hovered ? "#444444" : "#333333")
                        border.color: "#666666"
                        border.width: 1
                        radius: 8
                    }

                    contentItem: Text {
                        text: backButton.text
                        color: "#ffffff"
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: backRequested()
                }
            }

            // ✅ Print Button
            Rectangle {
                width: 160
                height: 50
                radius: 10
                color: "#2d2d30"
                border.color: "#FF9800"
                border.width: 2

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (!isRecordingForPrint)
                            startPrintRequested()
                    }
                    onEntered: parent.color = "#3d3d40"
                    onExited: parent.color = "#2d2d30"
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        text: isRecordingForPrint ? "🔴 Recording..." : "🖨️ Print"
                        color: isRecordingForPrint ? "#FF5722" : "#FF9800"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Text {
                        text: "5 sec graph"
                        color: "#cccccc"
                        font.pixelSize: 11
                    }
                }

                // --- Progress Bar for Print Recording ---
                Rectangle {
                    id: progressBar
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 3
                    color: "#444"
                    visible: isRecordingForPrint

                    Rectangle {
                        id: progressFill
                        anchors.left: parent.left
                        width: 0
                        height: parent.height
                        color: "#FF9800"
                    }

                    PropertyAnimation {
                        id: progressAnim
                        target: progressFill
                        property: "width"
                        from: 0
                        to: progressBar.width
                        duration: 5000
                        running: false
                    }
                }
            }

            // ✅ History Button
            Rectangle {
                width: 160
                height: 50
                radius: 10
                color: "#2196F3"
                border.color: "#1565C0"
                border.width: 2

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        console.log("📊 BottomBar - History button clicked. Patient ID:", selectedPatientId)
                        historyRequested(selectedPatientId)   // Emit only the Patient ID
                    }
                    onEntered: parent.color = "#42A5F5"
                    onExited: parent.color = "#2196F3"
                }

                Text {
                    anchors.centerIn: parent
                    text: "📊 History Data"
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                }
            }

            // ✅ Exit Button
            Rectangle {
                width: 160
                height: 50
                radius: 10
                color: "#d32f2f"
                border.color: "#b71c1c"
                border.width: 2

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: confirmDialog.open()
                    onEntered: parent.color = "#e53935"
                    onExited: parent.color = "#d32f2f"
                }

                Text {
                    anchors.centerIn: parent
                    text: "🔚 Exit"
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                }
            }
        }

        // ✅ Exit Confirmation Dialog
        Dialog {
            id: confirmDialog
            modal: true
            width: 400
            height: 300
            focus: true
            dim: true

            // Center dialog on the screen - adjust Y offset as needed
            x: (parent ? parent.width : Screen.width) / 2 - width / 2
            y: (parent ? parent.height : Screen.height) / 2 - height / 2 - 500

            background: Rectangle {
                color: "#2d2d30"
                radius: 10
                border.color: "#555"
                border.width: 1
            }

            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    text: "Are you sure you want to exit the application?"
                    color: "white"
                    font.pixelSize: 20
                    wrapMode: Text.Wrap
                    width: parent.width * 0.9
                    horizontalAlignment: Text.AlignHCenter
                }

                Row {
                    spacing: 20
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button {
                        text: "Yes"
                        onClicked: bottomBarWrapper.exitConfirmed()
                    }

                    Button {
                        text: "No"
                        onClicked: confirmDialog.close()
                    }
                }
            }
        }
    }

    // --- Helper function to find the nearest StackView ---
    // If no StackView is found, returns null and logs a warning
    function findStackView() {
        var item = bottomBarWrapper
        var maxDepth = 20 // Prevent infinite loop
        var depth = 0

        while (item && depth < maxDepth) {
            console.log("🔍 Checking:", item.objectName, typeof item.push)

            // --- StackView detection by objectName or function presence ---
            if (item.objectName === "mainStackView" ||
                (typeof item.push === "function" && typeof item.pop === "function")) {
                console.log("✅ StackView found!")
                return item
            }

            item = item.parent
            depth++
        }

        console.warn("❌ StackView not found, max depth reached:", maxDepth)
        return null
    }
}
