import QtQuick
import QtQuick.Controls
import EUI

// EUI IconButton Component
Button {
    id: root
    
    // Compatible with old icon property and new custom property
    property alias iconText: iconLabel.text
    property int iconSize: EUITheme.iconSize
    property color iconColor: EUITheme.colorText
    
    // Size
    implicitWidth: 40
    implicitHeight: 40
    
    padding: 0
    
    hoverEnabled: true
    
    // Background
    background: Rectangle {
        radius: EUITheme.radiusSmall
        color: {
            if (!root.enabled) return EUITheme.colorMutedBg
            if (root.down) return Qt.rgba(0, 0, 0, 0.1)
            if (root.hovered) return Qt.rgba(0, 0, 0, 0.06)
            return "transparent"
        }
        
        border.width: root.hovered ? 1 : 0
        border.color: EUITheme.colorBorder
        
        Behavior on color {
            ColorAnimation { duration: EUITheme.animationFast }
        }
    }
    
    // Icon content
    contentItem: Item {
        Text {
            id: iconLabel
            anchors.centerIn: parent
            font.pixelSize: root.iconSize
            color: root.enabled ? root.iconColor : EUITheme.colorTextDisabled
            text: root.icon.name || ""
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
    
    // Mouse cursor style
    MouseArea {
        anchors.fill: parent
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        acceptedButtons: Qt.NoButton
    }
}
