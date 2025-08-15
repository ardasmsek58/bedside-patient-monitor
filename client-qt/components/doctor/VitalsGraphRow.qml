import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15 // Required for layouts
import QtCore 6.2
import SMMProtocol 1.0 // If this module isn't defined or causes errors, you can comment this out

Item {
    id: graphs
    // We don't set width/height directly so this item inherits size from the parent.
    // Control sizing from the parent ColumnLayout via Layout.fillWidth / Layout.fillHeight.

    property int maxWaveformPoints: 200

    // ECG data (for draw + print)
    property var ecgWaveformData: []
    property var respWaveformData: []
    property var waveformData: []

    property int heartValue: 70
    property int spo2Value: 0
    property int respirationRate: 0

    // 🔄 Public helper to trigger repaints from outside
    function refreshAll() {
        ecgCanvas.requestPaint()
        waveformCanvas.requestPaint()
        respCanvas.requestPaint()
    }

    ColumnLayout { // Main layout
        spacing: 10
        anchors.fill: parent // Fill the parent item
        anchors.margins: 10

        // --- ECG + HR ---
        RowLayout { // Use RowLayout instead of Row
            Layout.fillWidth: true // Take all available horizontal space
            Layout.fillHeight: true // Share vertical space evenly with other RowLayouts
            spacing: 10

            Rectangle {
                id: ecgGraph
                Layout.fillWidth: true // Fill available horizontal space
                Layout.preferredWidth: parent.width * 0.77 // Width hint
                Layout.fillHeight: true // Fill available vertical space
                color: "black"
                border.color: "#4CAF50"
                border.width: 1
                radius: 8 // A bit more aesthetic

                Canvas {
                    id: ecgCanvas
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.strokeStyle = "#4CAF50"
                        ctx.lineWidth = 2
                        ctx.beginPath()

                        if (ecgWaveformData.length === 0) {
                            ctx.moveTo(0, height / 2)
                            ctx.lineTo(width, height / 2)
                        } else {
                            for (var i = 0; i < ecgWaveformData.length; i++) {
                                var x = (i / maxWaveformPoints) * width
                                var y = height - (ecgWaveformData[i] / 255.0) * height
                                if (i === 0)
                                    ctx.moveTo(x, y)
                                else
                                    ctx.lineTo(x, y)
                            }
                        }
                        ctx.stroke()
                    }
                }
            }

            Rectangle {
                id: heartRateCard
                Layout.fillWidth: true // Fill available horizontal space
                Layout.preferredWidth: parent.width * 0.22 // Width hint
                Layout.fillHeight: true // Fill available vertical space
                color: "black"
                border.color: "#4CAF50"
                border.width: 2
                radius: 8

                Column {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        text: "HR"
                        color: "#4CAF50"
                        font.pixelSize: 25
                        font.bold: true
                    }

                    Text {
                        text: heartValue > 0 ? heartValue : "--"
                        color: "#4CAF50"
                        font.pixelSize: 64
                        font.bold: true
                    }

                    Text {
                        text: "bpm"
                        color: "#4CAF50"
                        font.pixelSize: 20
                    }
                }
            }
        }

        // --- SpO2 + Value ---
        RowLayout { // Use RowLayout instead of Row
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            Rectangle {
                id: spo2Graph
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width * 0.77
                Layout.fillHeight: true
                color: "black"
                border.color: "#2196F3"
                border.width: 1
                radius: 8 // A bit more aesthetic

                Canvas {
                    id: waveformCanvas
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.strokeStyle = "#00bcd4"
                        ctx.lineWidth = 2
                        ctx.beginPath()

                        if (waveformData.length === 0) {
                            ctx.moveTo(0, height / 2)
                            ctx.lineTo(width, height / 2)
                        } else {
                            for (var i = 0; i < waveformData.length; i++) {
                                var x = (i / maxWaveformPoints) * width
                                var y = height - (waveformData[i] / 255.0) * height
                                if (i === 0)
                                    ctx.moveTo(x, y)
                                else
                                    ctx.lineTo(x, y)
                            }
                        }
                        ctx.stroke()
                        ctx.shadowColor = "#00bcd4"
                        ctx.shadowBlur = 8
                        ctx.stroke()
                        ctx.shadowBlur = 0
                    }
                }
            }

            Rectangle {
                id: spo2Card
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width * 0.22
                Layout.fillHeight: true
                color: "black"
                border.color: "#2196F3"
                border.width: 2
                radius: 8

                Column {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        text: "SpO₂"
                        color: "#2196F3"
                        font.pixelSize: 25
                        font.bold: true
                    }

                    Text {
                        text: spo2Value > 0 ? spo2Value : "--"
                        color: "#2196F3"
                        font.pixelSize: 64
                        font.bold: true
                    }

                    Text {
                        text: "%"
                        color: "#2196F3"
                        font.pixelSize: 20
                    }
                }
            }
        }

        // --- RESP + Value ---
        RowLayout { // Use RowLayout instead of Row
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            Rectangle {
                id: respGraph
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width * 0.77
                Layout.fillHeight: true
                color: "black"
                border.color: "yellow"
                border.width: 1
                radius: 8 // A bit more aesthetic

                Canvas {
                    id: respCanvas
                    anchors.fill: parent

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)

                        ctx.strokeStyle = "yellow"
                        ctx.lineWidth = 2
                        ctx.beginPath()

                        if (respWaveformData.length === 0) {
                            // No data → draw a flat line
                            ctx.moveTo(0, height / 2)
                            ctx.lineTo(width, height / 2)
                        } else {
                            // Draw actual waveform
                            for (var i = 0; i < respWaveformData.length; i++) {
                                var x = (i / maxWaveformPoints) * width
                                var y = height - (respWaveformData[i] / 255.0) * height

                                if (i === 0)
                                    ctx.moveTo(x, y)
                                else
                                    ctx.lineTo(x, y)
                            }
                        }

                        ctx.stroke()
                    }
                }
            }

            Rectangle {
                id: respCard
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width * 0.22
                Layout.fillHeight: true
                color: "black"
                border.color: "yellow"
                border.width: 2
                radius: 8

                Column {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        text: "RESP"
                        color: "yellow"
                        font.pixelSize: 25
                        font.bold: true
                    }

                    Text {
                        text: respirationRate > 0 ? respirationRate : "--"
                        color: "yellow"
                        font.pixelSize: 64
                        font.bold: true
                    }

                    Text {
                        text: "br/min"
                        color: "yellow"
                        font.pixelSize: 20
                    }
                }
            }
        }
    }
}
