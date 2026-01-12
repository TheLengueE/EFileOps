import QtQuick
import QtQuick.Controls
import EUI
import ".."

// ========== Left Navigation Panel ==========
Rectangle {
    id: root
    color: EUITheme.colorMutedBg

    // Right divider
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: EUITheme.colorDivider
    }

    // Overall layout: top, middle, bottom three sections
    Column {
        anchors.fill: parent
        spacing: 0

        // ========== First Section: Status Summary ==========
        LeftStatusPanel {
            id: statusPanel
            totalFiles: fileListModel ? fileListModel.totalCount : 0
            pendingFiles: fileListModel ? fileListModel.selectedCount : 0
            executedCount: mainController.lastExecutedCount
            successCount: mainController.lastSuccessCount
            failureCount: mainController.lastFailureCount
        }

        // Divider
        Rectangle {
            width: parent.width - EUITheme.spacingL * 2
            height: 1
            anchors.horizontalCenter: parent.horizontalCenter
            color: EUITheme.colorDivider
        }

        // ========== Middle Flexible Space (Placeholder) ==========
        Item {
            width: parent.width
            height: parent.height - statusPanel.height - 1 - bottomButtons.height - 1
        }

        // Divider
        Rectangle {
            width: parent.width - EUITheme.spacingL * 2
            height: 1
            anchors.horizontalCenter: parent.horizontalCenter
            color: EUITheme.colorDivider
        }

        // ========== Second Section: Bottom Global Entries ==========
        LeftBottomButtons {
            id: bottomButtons
            onSettingsClicked: settingsDialog.open()
            onAboutClicked: aboutDialog.open()
        }
    }
    
    // ========== Dialog Instances ==========
    SettingsDialog {
        id: settingsDialog
    }
    
    AboutDialog {
        id: aboutDialog
    }
}