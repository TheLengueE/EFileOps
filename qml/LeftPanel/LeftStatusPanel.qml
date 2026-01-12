import QtQuick
import EUI
import ".."

// Left panel status summary component
Rectangle {
    id: root
    width: parent.width
    height: 200
    color: "transparent"

    property int totalFiles: 0
    property int pendingFiles: 0
    property int executedCount: 0
    property int successCount: 0
    property int failureCount: 0

    Column {
        anchors.fill: parent
        anchors.margins: EUITheme.spacingL
        anchors.topMargin: EUITheme.spacingXL
        spacing: EUITheme.spacingL

        // Subtitle block
        Column {
            width: parent.width
            spacing: EUITheme.spacingM
            
            Text {
                text: I18n.tr("LeftPanel", "Current Task")
                font.pixelSize: EUITheme.fontCaption
                font.weight: EUITheme.fontWeightMedium
                color: EUITheme.colorTextSubtle
                opacity: 0.7
            }

            // File count
            Column {
                width: parent.width
                spacing: EUITheme.spacingXS

                Text {
                    text: I18n.tr("LeftPanel", "Files:")
                    font.pixelSize: EUITheme.fontCaption
                    color: EUITheme.colorTextSubtle
                    opacity: 0.6
                }

                Text {
                    text: root.totalFiles.toString()
                    font.pixelSize: EUITheme.fontH3
                    font.weight: EUITheme.fontWeightMedium
                    color: EUITheme.colorText
                }
            }

            // Pending (selected file count)
            Column {
                width: parent.width
                spacing: EUITheme.spacingXS

                Text {
                    text: I18n.tr("LeftPanel", "Pending:")
                    font.pixelSize: EUITheme.fontCaption
                    color: EUITheme.colorTextSubtle
                    opacity: 0.6
                }

                Text {
                    text: root.pendingFiles.toString()
                    font.pixelSize: EUITheme.fontH3
                    font.weight: EUITheme.fontWeightMedium
                    color: EUITheme.colorText
                }
            }
        }

        // Fine divider
        Rectangle {
            width: parent.width
            height: 1
            color: EUITheme.colorDivider
            opacity: 0.3
        }

        // Processing result block
        Column {
            width: parent.width
            spacing: EUITheme.spacingL

            Text {
                text: I18n.tr("LeftPanel", "Processed: %1 files").arg(root.executedCount)
                font.pixelSize: EUITheme.fontCaption
                color: EUITheme.colorTextSubtle
                opacity: 0.6
            }

            Row {
                width: parent.width
                spacing: 32

                Text {
                    text: "✓ " + root.successCount
                    font.pixelSize: 20
                    font.weight: EUITheme.fontWeightMedium
                    color: EUITheme.colorSuccess
                }

                Text {
                    text: "✗ " + root.failureCount
                    font.pixelSize: 20
                    font.weight: EUITheme.fontWeightMedium
                    color: EUITheme.colorDanger
                }
            }
        }
    }
}
