import QtQuick
import EUI

// EUI Toolbar Component - Top Toolbar
Rectangle {
    id: root
    
    // Size
    implicitWidth: parent?.width ?? 800
    implicitHeight: 56
    
    // Color
    color: EUITheme.colorCard
    
    // Bottom divider line
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: EUITheme.colorDivider
    }
    
    // Content container - Changed to Item, allows free positioning of children
    default property alias content: contentItem.children
    
    Item {
        id: contentItem
        anchors.fill: parent
    }
}
