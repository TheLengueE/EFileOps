import QtQuick
import EUI

// EUI StatusBar Component - Status Bar
Rectangle {
    id: root
    
    // Size
    implicitWidth: parent?.width ?? 800
    implicitHeight: 28
    
    // Color
    color: EUITheme.colorMutedBg
    
    // Top divider line
    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: 1
        color: EUITheme.colorDivider
    }
    
    // Status information
    property string leftText: ""
    property string centerText: ""
    property string rightText: ""
    
    // Left text
    Text {
        anchors.left: parent.left
        anchors.leftMargin: EUITheme.spacingMedium
        anchors.verticalCenter: parent.verticalCenter
        text: root.leftText
        color: EUITheme.colorTextSubtle
        font.pixelSize: EUITheme.fontCaption
        visible: root.leftText !== ""
    }
    
    // Center text
    Text {
        anchors.centerIn: parent
        text: root.centerText
        color: EUITheme.colorTextSubtle
        font.pixelSize: EUITheme.fontCaption
        visible: root.centerText !== ""
    }
    
    // Right text
    Text {
        anchors.right: parent.right
        anchors.rightMargin: EUITheme.spacingMedium
        anchors.verticalCenter: parent.verticalCenter
        text: root.rightText
        color: EUITheme.colorTextSubtle
        font.pixelSize: EUITheme.fontCaption
        visible: root.rightText !== ""
    }
}
