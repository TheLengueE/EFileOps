import QtQuick
import EUI
import ".."

// Empty state display component
Column {
    anchors.centerIn: parent
    spacing: EUITheme.spacingL

    Image {
        source: "../../icons/folder-filled.svg"
        width: 168
        height: 168
        sourceSize: Qt.size(96, 96)
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        text: I18n.tr("CenterPanel", "No files selected")
        font.pixelSize: EUITheme.fontH2
        color: EUITheme.colorTextSubtle
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        text: I18n.tr("CenterPanel", "Click the add file button to start")
        font.pixelSize: EUITheme.fontBody
        color: EUITheme.colorTextSubtle
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: 0.6
    }
}
