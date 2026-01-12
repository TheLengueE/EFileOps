import QtQuick
import QtQuick.Controls
import EUI

// EUI Switch Component
Switch {
    id: root
    
    implicitWidth: 44
    implicitHeight: 24
    
    hoverEnabled: true
    
    indicator: Rectangle {
        id: track
        width: 44
        height: 24
        radius: 12
        
        color: root.checked ? EUITheme.colorPrimary : "#CCCCCC"
        
        Behavior on color {
            ColorAnimation { duration: EUITheme.animationNormal }
        }
        
        // Thumb
        Rectangle {
            id: thumb
            width: 20
            height: 20
            radius: 10
            x: root.checked ? parent.width - width - 2 : 2
            y: (parent.height - height) / 2
            
            color: "#FFFFFF"
            
            Behavior on x {
                NumberAnimation { 
                    duration: EUITheme.animationNormal
                    easing.type: Easing.InOutQuad
                }
            }
            
            // Simple shadow effect
            Rectangle {
                anchors.fill: parent
                anchors.margins: -1
                z: -1
                radius: parent.radius + 1
                color: Qt.rgba(0, 0, 0, 0.1)
                visible: true
            }
        }
    }
    
    // Mouse cursor style
    MouseArea {
        anchors.fill: parent
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        acceptedButtons: Qt.NoButton
    }
}
