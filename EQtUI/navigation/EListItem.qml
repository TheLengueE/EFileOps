import QtQuick
import EUI

// EUI ListItem Component
Rectangle {
    id: root
    
    // Properties
    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property string rightText: ""
    property bool selected: false
    property bool showChevron: false
    
    signal clicked()
    
    // Size
    implicitWidth: 300
    implicitHeight: 60
    
    // Style
    color: {
        if (selected) return EUITheme.colorPrimarySoft
        if (mouseArea.containsMouse) return Qt.rgba(0, 0, 0, 0.03)
        return "transparent"
    }
    
    Behavior on color {
        ColorAnimation { duration: EUITheme.animationFast }
    }
    
    // Selection indicator bar
    Rectangle {
        width: 3
        height: parent.height
        color: EUITheme.colorPrimary
        visible: root.selected
    }
    
    // Content layout
    Row {
        anchors.fill: parent
        anchors.leftMargin: EUITheme.spacingL
        anchors.rightMargin: EUITheme.spacingL
        spacing: EUITheme.spacingM
        
        // Left icon
        Rectangle {
            width: 40
            height: 40
            radius: 6
            color: EUITheme.colorMutedBg
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon !== ""
            
            Image {
                anchors.centerIn: parent
                source: root.icon
                sourceSize.width: 24
                sourceSize.height: 24
            }
        }
        
        // Center text
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: EUITheme.spacingXS
            width: parent.width - 60 - (root.showChevron ? 40 : 0) - parent.spacing * 2
            
            Text {
                text: root.title
                font.pixelSize: EUITheme.fontBody
                font.weight: EUITheme.fontWeightMedium
                color: EUITheme.colorText
                width: parent.width
                elide: Text.ElideRight
            }
            
            Text {
                text: root.subtitle
                font.pixelSize: EUITheme.fontCaption
                color: EUITheme.colorTextSubtle
                width: parent.width
                elide: Text.ElideRight
                visible: root.subtitle !== ""
            }
        }
        
        // Right text
        Text {
            text: root.rightText
            font.pixelSize: EUITheme.fontCaption
            color: EUITheme.colorTextSubtle
            anchors.verticalCenter: parent.verticalCenter
            visible: root.rightText !== ""
        }
        
        // Right chevron
        Text {
            text: "›"
            font.pixelSize: 20
            color: EUITheme.colorTextSubtle
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showChevron
        }
    }
    
    // Mouse interaction
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
