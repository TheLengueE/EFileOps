import QtQuick
import QtQuick.Controls
import EUI

// EUI PopupMenu Component - Context Menu/Overflow Menu
Menu {
    id: root
    
    // Menu item data
    property var menuItems: []
    
    // Signals
    signal itemClicked(int index)
    
    // Size - auto-adjust based on content
    implicitWidth: {
        var maxWidth = 180
        for (var i = 0; i < menuItems.length; i++) {
            var item = menuItems[i]
            var text = item.text || item
            var estimatedWidth = text.length * 8 + 60  // Rough estimate
            if (estimatedWidth > maxWidth) {
                maxWidth = Math.min(estimatedWidth, 300)  // Max 300px
            }
        }
        return maxWidth
    }
    
    padding: 4
    
    // Background
    background: Rectangle {
        color: EUITheme.colorCard
        border.color: EUITheme.colorBorder
        border.width: 1
        radius: EUITheme.radiusSmall
        
        // Simple shadow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            z: -1
            radius: parent.radius + 4
            color: Qt.rgba(0, 0, 0, 0.1)
        }
    }
    
    // Dynamically create menu items
    Instantiator {
        model: root.menuItems
        
        MenuItem {
            text: modelData.text || modelData
            enabled: modelData.enabled !== undefined ? modelData.enabled : true
            
            contentItem: Row {
                spacing: EUITheme.spacingMedium
                width: root.width - root.padding * 2
                
                // Icon
                Text {
                    width: 20
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.icon || ""
                    color: parent.parent.enabled ? EUITheme.colorText : EUITheme.colorTextDisabled
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                }
                
                // Text
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.text || modelData
                    color: parent.parent.enabled ? EUITheme.colorText : EUITheme.colorTextDisabled
                    font.pixelSize: EUITheme.fontBody
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    width: parent.width - 20 - parent.spacing - (shortcutText.visible ? shortcutText.width + parent.spacing : 0)
                }
                
                // Shortcut hint
                Text {
                    id: shortcutText
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.shortcut || ""
                    color: EUITheme.colorTextSubtle
                    font.pixelSize: EUITheme.fontCaption
                    visible: modelData.shortcut !== undefined
                }
            }
            
            background: Rectangle {
                color: parent.highlighted ? EUITheme.colorPrimarySoft :
                       parent.hovered ? EUITheme.colorMutedBg :
                       "transparent"
                radius: EUITheme.radiusSmall
                
                Behavior on color {
                    ColorAnimation { duration: EUITheme.animationFast }
                }
            }
            
            onTriggered: {
                root.itemClicked(index)
                if (modelData.action) {
                    modelData.action()
                }
            }
        }
        
        onObjectAdded: (index, object) => root.insertItem(index, object)
        onObjectRemoved: (index, object) => root.removeItem(object)
    }
}
