import QtQuick
import EUI

// EUI Card Component
Rectangle {
    id: root
    
    // Title
    property string title: ""
    property string subtitle: ""
    
    // Content area
    default property alias content: contentArea.data
    
    // Style
    color: EUITheme.colorCard
    radius: EUITheme.radiusMedium
    border.width: 1
    border.color: EUITheme.colorBorder
    
    implicitWidth: 300
    implicitHeight: contentColumn.implicitHeight + EUITheme.spacingL * 2
    
    // Mouse hover effect
    property bool hoverable: false
    property bool hovered: false
    
    // Simple shadow effect (simulated with multi-layer Rectangles)
    Rectangle {
        anchors.fill: parent
        anchors.margins: -3
        z: -1
        radius: parent.radius + 3
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(0, 0, 0, 0.05)
        opacity: hovered && hoverable ? 0.8 : 0.4
        
        Behavior on opacity {
            NumberAnimation { duration: EUITheme.animationFast }
        }
    }
    
    Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        z: -2
        radius: parent.radius + 2
        color: Qt.rgba(0, 0, 0, 0.03)
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: root.hoverable
        onEntered: root.hovered = true
        onExited: root.hovered = false
        propagateComposedEvents: true
    }
    
    Column {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: EUITheme.spacingL
        spacing: EUITheme.spacingM
        
        // Title area
        Column {
            width: parent.width
            spacing: EUITheme.spacingXS
            visible: root.title !== ""
            
            Text {
                text: root.title
                font.pixelSize: EUITheme.fontH3
                font.weight: EUITheme.fontWeightMedium
                color: EUITheme.colorText
                width: parent.width
                elide: Text.ElideRight
            }
            
            Text {
                text: root.subtitle
                font.pixelSize: EUITheme.fontCaption
                color: EUITheme.colorTextSubtle
                width: parent.width
                wrapMode: Text.WordWrap
                visible: root.subtitle !== ""
            }
        }
        
        // Content area
        Item {
            id: contentArea
            width: parent.width
            height: childrenRect.height
        }
    }
}
