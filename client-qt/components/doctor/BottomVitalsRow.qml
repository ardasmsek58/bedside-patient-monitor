import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15


Item {
    id: bottomVitalsRow


    RowLayout {
        // Horizontal layout container
        anchors.top: parent.top          // Pin to parent's top edge
        anchors.bottom: parent.bottom    // Pin to parent's bottom edge
        anchors.bottomMargin: 10

        // Left edge with 10px margin
        anchors.left: parent.left
        anchors.leftMargin: 10

        // Right edge with 10px margin
        anchors.right: parent.right
        anchors.rightMargin: 10
        spacing: 10 // Space between items

        Repeater {
            model: [{
                    "label": "NIBP",
                    "color": "#FFC107"
                }, {
                    "label": "EtCO₂",
                    "color": "#FF5722"
                }, {
                    "label": "TEMP",
                    "color": "#FF1493"
                }]

            delegate: Rectangle {
                Layout.fillWidth: true   // Evenly fill horizontal space
                Layout.fillHeight: true  // Fill available vertical space
                color: "#2d2d30"
                border.color: modelData.color
                border.width: 2
                radius: 8 // Slight rounding for a cleaner look

                Column {
                    anchors.centerIn: parent
                    spacing: 5

                    Text {
                        text: modelData.label
                        color: modelData.color
                        font.pixelSize: 20
                        font.bold: true
                    }

                    Text {
                        text: "--"
                        color: "white"
                        font.pixelSize: 32
                        font.bold: true
                    }
                }
            }
        }
    }
}
