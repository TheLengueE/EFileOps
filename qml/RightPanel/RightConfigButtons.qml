import QtQuick
import QtQuick.Controls
import EUI
import ".."

// Right panel configuration management buttons component
Rectangle {
    id: root
    width: parent.width
    height: contentColumn.implicitHeight + EUITheme.spacingM * 2 + 1
    color: EUITheme.colorMutedBg

    signal saveClicked()
    signal importClicked()

    // Top divider line
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: EUITheme.colorDivider
    }

    Column {
        id: contentColumn
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: EUITheme.spacingM + 1
        anchors.leftMargin: EUITheme.spacingL
        anchors.rightMargin: EUITheme.spacingL
        anchors.bottomMargin: EUITheme.spacingM
        spacing: EUITheme.spacingS

        // Save configuration
        Rectangle {
            width: parent.width
            height: 40
            color: saveMouseArea.containsMouse ? Qt.rgba(59, 130, 246, 0.15) : "transparent"
            radius: EUITheme.radiusSmall

            IconImage {
                source: "../../icons/save.svg"
                width: 22
                height: 22
                anchors.centerIn: parent
                color: "#2563EB"
                opacity: saveMouseArea.containsMouse ? 1.0 : 0.8
            }

            MouseArea {
                id: saveMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.saveClicked()
            }
            
            ToolTip {
                visible: saveMouseArea.containsMouse
                text: I18n.tr("RightPanel", "Save Configuration")
                delay: 500
            }
        }

        // Import configuration
        Rectangle {
            width: parent.width
            height: 40
            color: importMouseArea.containsMouse ? Qt.rgba(59, 130, 246, 0.15) : "transparent"
            radius: EUITheme.radiusSmall

            IconImage {
                source: "../../icons/download.svg"
                width: 22
                height: 22
                anchors.centerIn: parent
                color: "#2563EB"
                opacity: importMouseArea.containsMouse ? 1.0 : 0.8
            }

            MouseArea {
                id: importMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.importClicked()
            }
            
            ToolTip {
                visible: importMouseArea.containsMouse
                text: I18n.tr("RightPanel", "Import Configuration")
                delay: 500
            }
        }
    }
}
