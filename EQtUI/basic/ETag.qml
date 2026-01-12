import QtQuick
import EUI

// EUI Tag Component
Rectangle {
    id: root
    
    property string text: ""
    property color tagColor: EUITheme.colorPrimary
    
    implicitWidth: tagText.implicitWidth + EUITheme.spacingS * 2
    implicitHeight: 22
    
    radius: EUITheme.radiusPill
    color: Qt.rgba(tagColor.r, tagColor.g, tagColor.b, 0.1)
    
    Text {
        id: tagText
        anchors.centerIn: parent
        text: root.text
        font.pixelSize: EUITheme.fontCaption
        font.weight: EUITheme.fontWeightMedium
        color: root.tagColor
    }
}
