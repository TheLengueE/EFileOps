import QtQuick
import QtQuick.Controls
import EUI

// EUI ProgressBar Component - Progress Bar
ProgressBar {
    id: root
    
    // Size
    implicitWidth: 200
    implicitHeight: 8
    
    value: 0.5
    
    // Background track
    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 8
        color: EUITheme.colorMutedBg
        radius: 4
        border.width: 1
        border.color: EUITheme.colorBorder
    }
    
    // Progress bar
    contentItem: Item {
        implicitWidth: 200
        implicitHeight: 6
        
        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: 3
            color: EUITheme.colorPrimary
            
            Behavior on width {
                NumberAnimation { duration: EUITheme.animationNormal }
            }
        }
    }
}
