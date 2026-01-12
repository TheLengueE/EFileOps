import QtQuick
import EUI

// EUI Avatar Component - Avatar Control
Rectangle {
    id: root
    
    // Size
    implicitWidth: 40
    implicitHeight: 40
    
    // Configuration
    property string imageSource: ""
    property string displayText: ""  // Text to display when no image (e.g., initials)
    property color backgroundColor: EUITheme.colorPrimary
    property color textColor: EUITheme.colorCard
    
    // Shape (circle, rounded)
    property string shape: "circle"
    
    // Border radius
    radius: shape === "circle" ? width / 2 : EUITheme.radiusSmall
    
    // Background color
    color: imageSource === "" ? backgroundColor : "transparent"
    
    // Border
    border.width: 1
    border.color: Qt.rgba(0, 0, 0, 0.1)
    
    // Image
    Image {
        anchors.fill: parent
        anchors.margins: 1
        source: root.imageSource
        fillMode: Image.PreserveAspectCrop
        visible: root.imageSource !== ""
        
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: root.width - 2
                height: root.height - 2
                radius: root.radius
            }
        }
    }
    
    // OpacityMask definition
    component OpacityMask: Item {
        property Item maskSource
        
        // Simplified version, QML actually needs ShaderEffect implementation
        // Using clip as replacement
        clip: true
    }
    
    // Text display (when no image)
    Text {
        anchors.centerIn: parent
        text: root.displayText
        color: root.textColor
        font.pixelSize: root.width * 0.4
        font.weight: Font.Medium
        visible: root.imageSource === ""
    }
    
    // Mouse hover effect
    property bool hovered: false
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered = true
        onExited: root.hovered = false
    }
    
    // Status indicator (optional)
    property bool showStatus: false
    property color statusColor: "#10B981"  // Default green (online)
    
    Rectangle {
        width: root.width * 0.25
        height: width
        radius: width / 2
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: root.statusColor
        border.width: 2
        border.color: EUITheme.colorCard
        visible: root.showStatus
    }
}
