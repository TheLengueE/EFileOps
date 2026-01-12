import QtQuick
import QtQuick.Controls
import EUI
import ".."

// ========== Rule Type Card ==========
Rectangle {
    id: root
    
    property string title: "Rule"
    property string description: "Description"
    
    signal clicked()
    
    height: contentColumn.implicitHeight + EUITheme.spacingM * 2
    color: mouseArea.containsMouse ? "#EEF3FF" : "#F7F9FC"
    border.width: 1
    border.color: EUITheme.colorBorder
    radius: EUITheme.radiusMedium
    
    Behavior on color {
        ColorAnimation { duration: EUITheme.animationFast }
    }
    
    // Left accent bar (强调条)
    Rectangle {
        id: accentBar
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        width: mouseArea.containsMouse ? 4 : 0
        color: EUITheme.colorPrimary
        radius: EUITheme.radiusMedium
        
        Behavior on width {
            NumberAnimation { 
                duration: EUITheme.animationFast
                easing.type: Easing.OutQuad
            }
        }
    }
    
    Column {
        id: contentColumn
        width: parent.width - EUITheme.spacingM * 2 - (mouseArea.containsMouse ? 4 : 0)
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: EUITheme.spacingM + (mouseArea.containsMouse ? 4 : 0)
        anchors.topMargin: EUITheme.spacingM
        anchors.rightMargin: EUITheme.spacingM
        spacing: EUITheme.spacingS
        
        Behavior on width {
            NumberAnimation { duration: EUITheme.animationFast }
        }
        
        Behavior on anchors.leftMargin {
            NumberAnimation { duration: EUITheme.animationFast }
        }
        
        // Title
        Text {
            text: root.title
            font.pixelSize: EUITheme.fontH3
            font.weight: EUITheme.fontWeightSemiBold
            color: EUITheme.colorText
            width: parent.width
        }
        
        // Description
        Text {
            text: root.description
            font.pixelSize: EUITheme.fontBody
            color: EUITheme.colorTextSubtle
            wrapMode: Text.WordWrap
            width: parent.width
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        onClicked: if (root.enabled) root.clicked()
    }
}
