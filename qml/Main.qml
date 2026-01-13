import QtQuick
import QtQuick.Controls
import EUI
import "."
import "LeftPanel"
import "CenterPanel"
import "RightPanel"

ApplicationWindow {
    id: root
    visible: true
    width: 1400
    height: 900
    title: {
        var v = I18n.version; // Establish binding dependency for language switching
        return I18n.tr("Main", "EFileOps");
    }

    color: EUITheme.colorBg

    // Monitor execution failure and show error dialog
    Connections {
        target: mainController
        function onExecutionFailed(failedCount) {
            executionErrorDialog.failedCount = failedCount;
            executionErrorDialog.open();
        }
    }

    // Monitor selection state changes, notify MainController
    Connections {
        target: fileListModel
        function onSelectionChanged() {
            mainController.setSelectedIndices(fileListModel.getSelectedIndices());
        }
    }

    // Three-column layout structure
    Row {
        anchors.fill: parent
        spacing: 0

        // ========== Left Panel (Sidebar) ==========
        LeftPanel {
            id: leftPanel
            width: 280  // Fixed width (about 20%)
            height: parent.height
        }

        // ========== Center Content Area ==========
        CenterPanel {
            id: centerPanel
            width: parent.width - leftPanel.width - rightPanel.width  // Auto-fills (about 57-60%)
            height: parent.height
        }

        // ========== Right Panel ==========
        RightPanel {
            id: rightPanel
            width: 320  // Fixed width (about 23%)
            height: parent.height
        }
    }

    // Execution Error Dialog (Rollback)
    EDialog {
        id: executionErrorDialog

        property int failedCount: 0

        implicitWidth: 480

        title: {
            var v = I18n.version; // Establish binding dependency
            return "❌ " + I18n.tr("Main", "Execution Failed");
        }

        message: {
            var v = I18n.version; // Establish binding dependency
            return I18n.tr("Main", "%1 file(s) could not be renamed.").arg(failedCount) + "\n" +
                   I18n.tr("Main", "All changes have been rolled back — no files were modified.") + "\n\n" +
                   I18n.tr("Main", "Please resolve the files marked in red and try again.");
        }

        confirmText: I18n.tr("Main", "OK")
        showCancel: false
    }
}
