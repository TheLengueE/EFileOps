import QtQuick
import QtQuick.Controls
import EUI

// EUI ScrollView Component - Scrollable Area
ScrollView {
    id: root
    
    // Background
    background: Rectangle {
        color: "transparent"
    }
    
    // Custom scrollbar style
    component CustomScrollBar: ScrollBar {
        id: scrollBar
        
        property bool isVertical: orientation === Qt.Vertical
        
        contentItem: Rectangle {
            implicitWidth: isVertical ? 8 : 100
            implicitHeight: isVertical ? 100 : 8
            radius: 4
            color: scrollBar.pressed ? EUITheme.colorTextSubtle : 
                   scrollBar.hovered ? Qt.rgba(0, 0, 0, 0.4) : 
                   Qt.rgba(0, 0, 0, 0.2)
            
            Behavior on color {
                ColorAnimation { duration: EUITheme.animationFast }
            }
        }
        
        background: Rectangle {
            implicitWidth: isVertical ? 8 : 100
            implicitHeight: isVertical ? 100 : 8
            color: "transparent"
        }
    }
}
