import QtQuick
import EUI

// EUI Grid Component - Simple Grid Layout
Item {
    id: root
    
    // Grid configuration
    property int columns: 3
    property int spacing: EUITheme.spacingMedium
    
    // Auto container
    default property alias content: gridContainer.children
    
    implicitWidth: parent?.width ?? 400
    implicitHeight: gridContainer.implicitHeight
    
    Grid {
        id: gridContainer
        anchors.fill: parent
        
        columns: root.columns
        columnSpacing: root.spacing
        rowSpacing: root.spacing
    }
}
