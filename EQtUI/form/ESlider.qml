import QtQuick
import QtQuick.Controls
import EUI

// EUI Slider Component - Value Control
Slider {
    id: root
    
    // Size
    implicitWidth: 200
    implicitHeight: 36
    
    from: 0
    to: 100
    value: 50
    
    // Background track
    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 4
        width: root.availableWidth
        height: implicitHeight
        radius: 2
        color: EUITheme.colorBorder
        
        // Filled portion
        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            color: root.enabled ? EUITheme.colorPrimary : EUITheme.colorTextDisabled
            radius: 2
            
            Behavior on width {
                NumberAnimation { duration: EUITheme.animationFast }
            }
        }
    }
    
    // Slider handle
    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: 20
        implicitHeight: 20
        radius: 10
        color: EUITheme.colorCard
        border.color: root.enabled ? EUITheme.colorPrimary : EUITheme.colorTextDisabled
        border.width: 2
        
        scale: root.pressed ? 1.1 : root.hovered ? 1.05 : 1.0
        
        Behavior on scale {
            NumberAnimation { duration: EUITheme.animationFast }
        }
        
        // Simple shadow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            z: -1
            radius: parent.radius + 2
            color: Qt.rgba(0, 0, 0, 0.1)
            visible: root.enabled
        }
    }
}
