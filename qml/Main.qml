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
}
