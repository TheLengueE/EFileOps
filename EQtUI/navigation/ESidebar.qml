import QtQuick
import QtQuick.Controls
import EUI

// EUI Sidebar Component - Sidebar Navigation
Rectangle {
    id: root
    
    // Width configuration
    implicitWidth: 240
    implicitHeight: 600
    
    // Color
    color: EUITheme.colorMutedBg
    
    // Navigation item data
    property var items: []
    property int currentIndex: 0
    
    // Signals
    signal itemClicked(int index)
    
    // Content
    Column {
        anchors.fill: parent
        anchors.margins: EUITheme.spacingSmall
        spacing: EUITheme.spacingXSmall
        
        Repeater {
            model: root.items
            
            delegate: Rectangle {
                width: parent.width
                height: 44
                radius: EUITheme.radiusSmall
                
                property bool isActive: index === root.currentIndex
                
                color: isActive ? EUITheme.colorPrimarySoft :
                       itemMouseArea.containsMouse ? Qt.rgba(0, 0, 0, 0.05) :
                       "transparent"
                
                Behavior on color {
                    ColorAnimation { duration: EUITheme.animationFast }
                }
                
                // Left active indicator bar
                Rectangle {
                    width: 3
                    height: parent.height - 8
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 2
                    color: EUITheme.colorPrimary
                    visible: isActive
                }
                
                // Content
                Row {
                    anchors.fill: parent
                    anchors.leftMargin: EUITheme.spacingMedium + (isActive ? 6 : 0)
                    anchors.rightMargin: EUITheme.spacingMedium
                    spacing: EUITheme.spacingMedium
                    
                    Behavior on anchors.leftMargin {
                        NumberAnimation { duration: EUITheme.animationFast }
                    }
                    
                    // Icon placeholder
                    Rectangle {
                        width: 20
                        height: 20
                        anchors.verticalCenter: parent.verticalCenter
                        radius: 4
                        color: isActive ? EUITheme.colorPrimary : EUITheme.colorTextSubtle
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon || "●"
                            color: isActive ? EUITheme.colorCard : EUITheme.colorCard
                            font.pixelSize: 12
                        }
                    }
                    
                    // Text
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.text || modelData
                        color: isActive ? EUITheme.colorPrimary : EUITheme.colorText
                        font.pixelSize: EUITheme.fontBody
                        font.weight: isActive ? Font.Medium : Font.Normal
                    }
                }
                
                MouseArea {
                    id: itemMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        root.currentIndex = index
                        root.itemClicked(index)
                    }
                }
            }
        }
    }
}
