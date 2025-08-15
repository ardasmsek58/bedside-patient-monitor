import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import QtCore 6.2

Dialog {
    id: printDialog
    title: "Grafik Yazdır"
    modal: true
    width: 900
    height: 700

    // --- Data buffers captured during the 5s recording window ---
    property var printWaveformData: []
    property var printTimestamps: []
    property var printEcgData: []
    property var printEcgTimestamps: []

    // --- Vital values to display in the header ---
    property int heartValue: 0
    property int spo2Value: 0
    property int respirationRate: 0

    // --- Print parameters (time span & paper speed) ---
    property int printSeconds: 5
    property real speedMMPerS: 25

    // --- Appearance controls (to mimic the old PDF look) ---
    // 5 sn sabit pencere + hafif yatay daraltma
    property real xCompression: 0.92      // 1.0=kapalı, <1 daraltır
    property bool centerCompressed: true  // daraltmayı ortaya hizala

    // --- Signals emitted to the parent (doctorView) ---
    signal requestPrint()
    signal requestSave()
    signal requestCancel()

    // Convert 1 mm to pixels based on the canvas width and configured speed/time.
    function pxPerMM(w) { return w / (printSeconds * speedMMPerS); }

    // Draw 1mm/5mm medical grid
    function drawGrid(ctx, w, h, mm) {
        var minor = mm;        // 1 mm
        var major = 5 * mm;    // 5 mm

        ctx.save();
        ctx.clearRect(0, 0, w, h);

        // 1 mm lines (light)
        ctx.strokeStyle = "#e0e0e0";
        ctx.lineWidth = 0.7;
        for (var x = 0; x <= w + 0.5; x += minor) {
            ctx.beginPath(); ctx.moveTo(x + 0.5, 0); ctx.lineTo(x + 0.5, h); ctx.stroke();
        }
        for (var y = 0; y <= h + 0.5; y += minor) {
            ctx.beginPath(); ctx.moveTo(0, y + 0.5); ctx.lineTo(w, y + 0.5); ctx.stroke();
        }

        // 5 mm lines (darker)
        ctx.strokeStyle = "#bdbdbd";
        ctx.lineWidth = 1.4;
        for (var xx = 0; xx <= w + 0.5; xx += major) {
            ctx.beginPath(); ctx.moveTo(xx + 0.5, 0); ctx.lineTo(xx + 0.5, h); ctx.stroke();
        }
        for (var yy = 0; yy <= h + 0.5; yy += major) {
            ctx.beginPath(); ctx.moveTo(0, yy + 0.5); ctx.lineTo(w, yy + 0.5); ctx.stroke();
        }

        ctx.restore();
    }

    // --- Dialog background (dark) ---
    background: Rectangle {
        color: "#2d2d30"
        radius: 10
        border.color: "#3c3c3c"
        border.width: 1
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Report title
        Text {
            text: "VitaScope - Çok Parametreli Hasta Monitörü Raporu"
            color: "#ffffff"
            font.pixelSize: 18
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Date / Time / Vital stats header
        Row {
            spacing: 80
            anchors.horizontalCenter: parent.horizontalCenter

            Column {
                spacing: 5
                Text { text: "Tarih: " + Qt.formatDateTime(new Date(), "dd.MM.yyyy"); color: "#ffffff"; font.pixelSize: 12 }
                Text { text: "Saat: " + Qt.formatDateTime(new Date(), "hh:mm:ss");   color: "#ffffff"; font.pixelSize: 12 }
            }

            Column {
                spacing: 5
                Text { text: "Solunum: " + (respirationRate > 0 ? respirationRate + " br/min" : "---"); color: "#FF9800"; font.pixelSize: 12; font.bold: true }
                Text { text: "SpO₂: " + (spo2Value > 0 ? spo2Value + "%" : "---");                        color: "#00bcd4"; font.pixelSize: 12; font.bold: true }
            }

            Column {
                spacing: 5
                Text { text: "Kalp Atışı: " + (heartValue > 0 ? heartValue + " bpm" : "---"); color: "#4CAF50"; font.pixelSize: 12; font.bold: true }
            }
        }

        // --- SpO₂ chart (Canvas) ---
        Rectangle {
            width: parent.width
            height: 180
            color: "#ffffff"
            radius: 5
            border.color: "#333333"
            border.width: 1

            Canvas {
                id: spo2Canvas
                anchors.fill: parent
                anchors.margins: 20
                renderTarget: Canvas.Image

                onPaint: {
                    var ctx = getContext("2d");
                    var mm = printDialog.pxPerMM(width);
                    printDialog.drawGrid(ctx, width, height, mm);

                    if (printWaveformData && printWaveformData.length > 0) {
                        ctx.strokeStyle = "#00bcd4";
                        ctx.lineWidth = 2;
                        ctx.beginPath();

                        var totalMs = printDialog.printSeconds * 1000;
                        var useTime = (printTimestamps && printTimestamps.length === printWaveformData.length);

                        // x ofset (sıkıştırmayı ortaya almak için)
                        var offset = printDialog.centerCompressed ? (width * (1 - printDialog.xCompression) / 2) : 0;

                        var N = printWaveformData.length;
                        for (var i = 0; i < N; i++) {
                            var x;
                            if (useTime) {
                                var t0 = new Date(printTimestamps[0]).getTime();
                                var ti = new Date(printTimestamps[i]).getTime();
                                var dt = ti - t0;
                                if (dt < 0 || dt > totalMs) continue; // 5 sn penceresi dışını çizme
                                x = (dt / totalMs) * width;
                            } else {
                                // LEGACY: indeks tabanlı (eski pdf gibi, sağda ufak boşluk için N kullan)
                                x = (i / N) * width;
                            }
                            x = x * printDialog.xCompression + offset;

                            var y = height - (printWaveformData[i] / 255.0) * height;
                            if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
                        }
                        ctx.stroke();
                    }

                    // Caption
                    ctx.fillStyle = "#333333";
                    ctx.font = "12px Arial";
                    ctx.fillText("SpO₂ (" + printSeconds + " sn)  •  " + speedMMPerS + " mm/s", 10, 16);
                }
            }
        }

        // --- ECG chart (Canvas) ---
        Rectangle {
            width: parent.width
            height: 180
            color: "#ffffff"
            radius: 5
            border.color: "#333333"
            border.width: 1

            Canvas {
                id: ecgCanvas
                anchors.fill: parent
                anchors.margins: 20
                renderTarget: Canvas.Image

                onPaint: {
                    var ctx = getContext("2d");
                    var mm = printDialog.pxPerMM(width);
                    printDialog.drawGrid(ctx, width, height, mm);

                    if (printEcgData && printEcgData.length > 0) {
                        ctx.strokeStyle = "#FF5722";
                        ctx.lineWidth = 2;
                        ctx.beginPath();

                        var totalMs = printDialog.printSeconds * 1000;
                        var useTime = (printEcgTimestamps && printEcgTimestamps.length === printEcgData.length);

                        var offset = printDialog.centerCompressed ? (width * (1 - printDialog.xCompression) / 2) : 0;

                        var N = printEcgData.length;
                        for (var i = 0; i < N; i++) {
                            var x;
                            if (useTime) {
                                var t0 = new Date(printEcgTimestamps[0]).getTime();
                                var ti = new Date(printEcgTimestamps[i]).getTime();
                                var dt = ti - t0;
                                if (dt < 0 || dt > totalMs) continue;
                                x = (dt / totalMs) * width;
                            } else {
                                // LEGACY: indeks tabanlı (eski pdf gibi)
                                x = (i / N) * width;
                            }
                            x = x * printDialog.xCompression + offset;

                            var y = height - (printEcgData[i] / 255.0) * height;
                            if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
                        }
                        ctx.stroke();
                    }

                    // Caption
                    ctx.fillStyle = "#333333";
                    ctx.font = "12px Arial";
                    ctx.fillText("EKG (" + printSeconds + " sn)  •  " + speedMMPerS + " mm/s", 10, 16);
                }
            }
        }

        // Footnote / Notes
        Text {
            text: "Not: Bu grafik 5 saniyelik dalga formu verilerini göstermektedir."
                  + (printEcgData && printEcgData.length > 0 ? " SpO₂ ve EKG verileri aynı anda gösterilmektedir." : "")
            color: "#ffffff"
            font.pixelSize: 10
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            width: parent.width - 40
            horizontalAlignment: Text.AlignHCenter
        }

        // Action buttons
        Row {
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter

            Button { text: "🖨️ Yazdır"; width: 120; height: 40; onClicked: requestPrint() }
            Button { text: "💾 Kaydet"; width: 120; height: 40; onClicked: requestSave() }
            Button { text: "❌ İptal"; width: 120; height: 40; onClicked: requestCancel() }
        }
    }

    // Repaint triggers
    onOpened: { spo2Canvas.requestPaint(); ecgCanvas.requestPaint(); }
    onPrintWaveformDataChanged: spo2Canvas.requestPaint()
    onPrintTimestampsChanged:    spo2Canvas.requestPaint()
    onPrintEcgDataChanged:       ecgCanvas.requestPaint()
    onPrintEcgTimestampsChanged: ecgCanvas.requestPaint()
    onPrintSecondsChanged:       { spo2Canvas.requestPaint(); ecgCanvas.requestPaint(); }
    onSpeedMMPerSChanged:        { spo2Canvas.requestPaint(); ecgCanvas.requestPaint(); }
}
