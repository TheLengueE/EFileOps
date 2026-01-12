import QtQuick
import QtQuick.Layouts

// EUI Spacer Component - Flexible Spacer
Item {
    id: root
    
    // Use Layout properties to auto-fill in RowLayout/ColumnLayout
    Layout.fillWidth: true
    Layout.fillHeight: true
    
    // Default minimum size
    Layout.minimumWidth: 0
    Layout.minimumHeight: 0
}
