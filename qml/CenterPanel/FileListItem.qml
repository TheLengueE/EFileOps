import QtQuick
import EUI

// File list item component
Rectangle {
    id: root
    height: 50
    
    signal itemClicked()
    
    property bool isSelected: false
    property int fileIndex: 0
    property string originalName: ""
    property string newName: ""
    property bool hasError: false
    property int executionStatus: 0  // 0=Pending, 1=Success, 2=Failed, 3=RolledBack
    property string executionStatusText: ""
    property real listWidth: 0
    
    color: {
        if (isSelected) return EUITheme.colorPrimarySoft;
        if (mouseArea.containsMouse) return Qt.rgba(0, 0, 0, 0.03);
        return "transparent";
    }
    
    Row {
        anchors.fill: parent
        anchors.leftMargin: EUITheme.spacingM
        anchors.rightMargin: EUITheme.spacingM
        spacing: EUITheme.spacingM
        
        // Checkbox
        Rectangle {
            width: 40
            height: parent.height
            color: "transparent"
            
            Rectangle {
                width: 20
                height: 20
                anchors.centerIn: parent
                color: root.isSelected ? EUITheme.colorPrimary : "transparent"
                border.color: root.isSelected ? EUITheme.colorPrimary : EUITheme.colorBorder
                border.width: 2
                radius: 4
                
                Text {
                    anchors.centerIn: parent
                    text: "✓"
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    color: "white"
                    visible: root.isSelected
                }
            }
        }
        
        // Index
        Text {
            width: 60
            text: root.fileIndex
            font.pixelSize: EUITheme.fontBody
            color: EUITheme.colorTextSubtle
            verticalAlignment: Text.AlignVCenter
            height: parent.height
        }
        
        // Original filename
        Text {
            width: (root.listWidth - 40 - 60 - 120 - parent.spacing * 4) * 0.5
            text: root.originalName
            font.pixelSize: EUITheme.fontBody
            color: EUITheme.colorText
            verticalAlignment: Text.AlignVCenter
            height: parent.height
            elide: Text.ElideMiddle
        }
        
        // Preview name
        Text {
            width: (root.listWidth - 40 - 60 - 120 - parent.spacing * 4) * 0.5
            text: root.newName
            font.pixelSize: EUITheme.fontBody
            color: root.hasError ? EUITheme.colorDanger : EUITheme.colorPrimary
            verticalAlignment: Text.AlignVCenter
            height: parent.height
            elide: Text.ElideMiddle
            font.weight: Font.Medium
        }
        
        // Status
        Text {
            width: 120
            text: root.executionStatusText
            font.pixelSize: EUITheme.fontBody
            color: {
                if (root.executionStatus === 2) return EUITheme.colorDanger;  // Failed
                if (root.executionStatus === 1) return EUITheme.colorSuccess;  // Success
                if (root.executionStatus === 3) return EUITheme.colorWarning;  // RolledBack
                return EUITheme.colorTextSubtle;  // Pending
            }
            verticalAlignment: Text.AlignVCenter
            height: parent.height
            elide: Text.ElideRight
        }
    }
    
    // Bottom divider
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: EUITheme.colorDivider
        opacity: 0.3
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.itemClicked()
    }
}
