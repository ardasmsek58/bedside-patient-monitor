import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtCore 6.2
import SMMProtocol 1.0

Item {
    id: doctorView
    width: parent ? parent.width : 1200
    height: parent ? parent.height : 800

    property string selectedPatientId: ""
    property string selectedName: ""
    property string selectedSurname: ""

    property int heartValue: 0
    property int spo2Value: 0
    property int respirationRate: 0

    property var waveformData: []
    property var ecgWaveformData: []
    property var respWaveformData: []
    property int maxWaveformPoints: 200

    // Buffers for 5s print capture
    property var printWaveformData: []
    property var printTimestamps: []
    property var printEcgData: []
    property var printEcgTimestamps: []
    property bool isRecordingForPrint: false

    // --- Printing capture: start/stop helpers ---
    function beginPrintRecording() {
        isRecordingForPrint = true
        printWaveformData = []
        printTimestamps = []
        printEcgData = []
        printEcgTimestamps = []
        console.log("▶️ beginPrintRecording")
    }

    function endPrintRecording() {
        isRecordingForPrint = false
        console.log("⏹ endPrintRecording; lengths:", printWaveformData.length, printEcgData.length)
    }

    // Model to hold patients fetched from the DB
    ListModel { id: patientModel }

    // Refresh patient list from DeviceManager
    function refreshPatientList() {
        patientModel.clear()
        if (typeof deviceManager !== "undefined") {
            var patients = deviceManager.getAllPatients()
            for (var i = 0; i < patients.length; i++) {
                patientModel.append({
                    "patient_id": patients[i].patient_id,
                    "name": patients[i].name,
                    "surname": patients[i].surname,
                    "tc": patients[i].tc
                })
            }
            console.log("✅ Patient list refreshed:", patients.length, "records")
        }
    }

    // Initialize monitoring and load patients on component mount
    Component.onCompleted: {
        if (typeof deviceManager !== "undefined") {
            deviceManager.setTestMode(false)
            deviceManager.startMonitoring()
            refreshPatientList()
        }
    }

    Rectangle {
        id: mainBackground
        anchors.fill: parent
        color: "#222"

        // Main layout using ColumnLayout for structured placement
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 0
            spacing: 0

            // Patient picker - top section
            PatientSelector {
                id: patientSelector
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                Layout.minimumHeight: 50

                onPatientChosen: (pid, name, surname) => {
                    doctorView.selectedPatientId = pid
                    doctorView.selectedName = name
                    doctorView.selectedSurname = surname
                    console.log("🧭 DoctorView.selectedPatientId ->", doctorView.selectedPatientId)
                }
            }

            // Vital graphs - main area
            VitalsGraphRow {
                id: graphs
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 300

                ecgWaveformData: doctorView.ecgWaveformData
                waveformData: doctorView.waveformData
                respWaveformData: doctorView.respWaveformData

                heartValue: doctorView.heartValue
                spo2Value: doctorView.spo2Value
                respirationRate: doctorView.respirationRate
            }

            // Bottom vital tiles
            BottomVitalsRow {
                id: bottomVitals
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                Layout.minimumHeight: 80
            }

            // Bottom action bar
            BottomBar {
                id: footerBar
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                Layout.minimumHeight: 40

                selectedPatientId: doctorView.selectedPatientId
                isRecordingForPrint: doctorView.isRecordingForPrint
                printWaveformData: doctorView.printWaveformData
                printTimestamps: doctorView.printTimestamps
                printEcgData: doctorView.printEcgData
                printEcgTimestamps: doctorView.printEcgTimestamps

                // Start 5s print capture
                onStartPrintRequested: {
                    doctorView.beginPrintRecording()
                    footerBar.startProgressAndTimer()
                }

                // End print capture (early stop)
                onStopPrintRequested: {
                    doctorView.endPrintRecording()
                }

                // Open print dialog after capture ends
                onOpenPrintDialogRequested: {
                    printDialog.open()
                }

                // Navigate back to previous view and cleanup
                onBackRequested: {
                    footerBar.stopPrint()
                    deviceManager.stopMonitoring()
                    deviceManager.userRole = ""
                    waveformData = []
                    ecgWaveformData = []
                    respWaveformData = []

                    var item = doctorView
                    while (item) {
                        if (item.objectName === "mainStackView" || (item.hasOwnProperty('pop') && item.hasOwnProperty('push'))) {
                            item.pop()
                            break
                        }
                        item = item.parent
                    }
                }

                // (Legacy hook) Start print capture if not already recording
                onPrintRequested: {
                    if (!isRecordingForPrint)
                        doctorView.startPrintRecording()
                }

                // Navigate to history page for selected patient
                onHistoryRequested: (pid) => {
                    console.log("📊 DoctorView onHistoryRequested(pid):", pid)
                    if (pid) {
                        deviceManager.stopMonitoring()
                        let item = footerBar
                        while (item) {
                            if (item.objectName === "mainStackView" ||
                                (typeof item.push === "function" && typeof item.pop === "function")) {
                                item.push(Qt.resolvedUrl("history.qml"), { selectedPatientId: pid })
                                break
                            }
                            item = item.parent
                        }
                    } else {
                        console.warn("❌ pid is empty")
                    }
                }

                // Quit app (used by Exit confirmation)
                onExitConfirmed: Qt.quit()
            }
        }
    }

    // Print dialog as an overlay
    PrintDialog {
        id: printDialog
        visible: false
        parent: Overlay.overlay // Ensure it floats above the whole window
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        printWaveformData: doctorView.printWaveformData
        printTimestamps: doctorView.printTimestamps
        printEcgData: doctorView.printEcgData
        printEcgTimestamps: doctorView.printEcgTimestamps
        spo2Value: doctorView.spo2Value
        heartValue: doctorView.heartValue
        respirationRate: doctorView.respirationRate

        // Send to printer
        onRequestPrint: {
            deviceManager.printWaveformData(
                printWaveformData, printTimestamps,
                printEcgData, printEcgTimestamps
            )
            printDialog.close()
        }

        // Save as PDF
        onRequestSave: {
            deviceManager.saveWaveformToPDF(
                printWaveformData, printTimestamps,
                "", printEcgData, printEcgTimestamps
            )
            printDialog.close()
        }

        // Close dialog without action
        onRequestCancel: printDialog.close()
    }

    // DeviceManager signal bindings
    Connections {
        target: deviceManager

        function onHeartRateChanged() {
            heartValue = parseInt(deviceManager.heartRateValue) || 0
        }

        function onRespirationRateChanged() {
            respirationRate = parseInt(deviceManager.respirationRate) || 0
        }

        function onEcgWaveformSampleReceived() {
            ecgWaveformData.push(deviceManager.ecgWaveformSample)
            if (ecgWaveformData.length > maxWaveformPoints)
                ecgWaveformData.shift()

            if (isRecordingForPrint) {
                printEcgData.push(deviceManager.ecgWaveformSample)
                printEcgTimestamps.push(new Date())
            }
            graphs.refreshAll()
        }

        function onRespWaveformSampleReceived() {
            respWaveformData.push(deviceManager.respWaveformSample)
            if (respWaveformData.length > maxWaveformPoints)
                respWaveformData.shift()

            graphs.refreshAll()
        }

        function onWaveformSampleReceived() {
            waveformData.push(deviceManager.waveformSample)
            if (waveformData.length > maxWaveformPoints)
                waveformData.shift()

            if (isRecordingForPrint) {
                printWaveformData.push(deviceManager.waveformSample)
                printTimestamps.push(new Date())
            }
            graphs.refreshAll()
        }

        function onSpo2Changed() {
            spo2Value = parseInt(deviceManager.spo2Value) || 0
        }
    }
}
