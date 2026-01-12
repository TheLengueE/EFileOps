import QtQuick
import EUI
import ".."

// File list header component
Rectangle {
    id: root
    height: 40
    color: EUITheme.colorMutedBg
    
    signal selectAllToggled()
    
    property int selectedCount: 0
    property int totalCount: 0
    property real listWidth: 0
    
    Row {
        anchors.fill: parent
        anchors.leftMargin: EUITheme.spacingM
        anchors.rightMargin: EUITheme.spacingM
        spacing: EUITheme.spacingM
        
        // Select all checkbox column
        Rectangle {
            width: 40
            height: parent.height
            color: "transparent"
           
            Rectangle {
                width: 20
                height: 20
                anchors.centerIn: parent
                color: root.selectedCount === root.totalCount && root.totalCount > 0 
                       ? EUITheme.colorPrimary : "transparent"
                border.color: root.selectedCount === root.totalCount && root.totalCount > 0
                              ? EUITheme.colorPrimary : EUITheme.colorBorder
                border.width: 2
                radius: 4
                
                Text {
                    anchors.centerIn: parent
                    text: "✓"
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    color: "white"
                    visible: root.selectedCount === root.totalCount && root.totalCount > 0
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.selectAllToggled()
                }
            }
        }
        
        // Index column
        Text {
            width: 60
            text: I18n.tr("CenterPanel", "No.")
            font.pixelSize: EUITheme.fontBody
            font.weight: Font.Medium
            color: EUITheme.colorTextSubtle
            verticalAlignment: Text.AlignVCenter
            height: parent.height
        }
        
        // Original filename column
        Text {
            width: (root.listWidth - 40 - 60 - 120 - parent.spacing * 4) * 0.5
            text: I18n.tr("CenterPanel", "Original Name")
            font.pixelSize: EUITheme.fontBody
            font.weight: Font.Medium
            color: EUITheme.colorTextSubtle
            verticalAlignment: Text.AlignVCenter
            height: parent.height
        }
        
        // Preview column
        Text {
            width: (root.listWidth - 40 - 60 - 120 - parent.spacing * 4) * 0.5
            text: I18n.tr("CenterPanel", "Preview")
            font.pixelSize: EUITheme.fontBody
            font.weight: Font.Medium
            color: EUITheme.colorTextSubtle
            verticalAlignment: Text.AlignVCenter
            height: parent.height
        }
        
        // Status column
        Text {
            width: 120
            text: I18n.tr("CenterPanel", "Status")
            font.pixelSize: EUITheme.fontBody
            font.weight: Font.Medium
            color: EUITheme.colorTextSubtle
            verticalAlignment: Text.AlignVCenter
            height: parent.height
        }
    }
    
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: EUITheme.colorDivider
    }
}
