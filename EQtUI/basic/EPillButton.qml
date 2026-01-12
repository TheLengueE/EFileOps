import QtQuick
import QtQuick.Controls
import EUI

// EUI PillButton Component - Pill-shaped Button
Item {
    id: root
    
    // Configuration
    property string text: "Button"
    property string icon: ""
    property bool showIcon: icon !== ""
    property bool enabled: true
    
    // Style type (primary, secondary, ghost)
    property string pillType: "secondary"
    
    // State
    property bool hovered: false
    property bool pressed: false
    
    // Signals
    signal clicked()
    
    implicitWidth: contentRow.implicitWidth + EUITheme.spacingMedium * 2
    implicitHeight: 32
    
    // Background
    Rectangle {
        id: background
        anchors.fill: parent
        color: {
            if (!root.enabled) return EUITheme.colorMutedBg
            if (root.pillType === "primary") {
                return root.pressed ? Qt.darker(EUITheme.colorPrimary, 1.1) :
                       root.hovered ? Qt.lighter(EUITheme.colorPrimary, 1.1) :
                       EUITheme.colorPrimary
            } else if (root.pillType === "ghost") {
                return root.pressed ? Qt.rgba(0, 0, 0, 0.08) :
                       root.hovered ? Qt.rgba(0, 0, 0, 0.04) :
                       "transparent"
            } else {
                return root.pressed ? EUITheme.colorMutedBg :
                       root.hovered ? Qt.rgba(0, 0, 0, 0.03) :
                       EUITheme.colorCard
            }
        }
        border.width: root.pillType === "secondary" ? 1 : 0
        border.color: EUITheme.colorBorder
        radius: height / 2  // Full rounded corners
        
        Behavior on color {
            ColorAnimation { duration: EUITheme.animationFast }
        }
    }
    
    // Content
    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: EUITheme.spacingSmall
        
        // Icon
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            visible: root.showIcon
            color: {
                if (!root.enabled) return EUITheme.colorTextDisabled
                return root.pillType === "primary" ? EUITheme.colorCard : EUITheme.colorText
            }
            font.pixelSize: 14
        }
        
        // Text
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            color: {
                if (!root.enabled) return EUITheme.colorTextDisabled
                return root.pillType === "primary" ? EUITheme.colorCard : EUITheme.colorText
            }
            font.pixelSize: EUITheme.fontCaption
            font.weight: Font.Medium
        }
    }
    
    // Mouse interaction
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        
        onEntered: root.hovered = true
        onExited: {
            root.hovered = false
            root.pressed = false
        }
        onPressed: root.pressed = true
        onReleased: root.pressed = false
        onClicked: {
            if (root.enabled) {
                root.clicked()
            }
        }
    }
}
