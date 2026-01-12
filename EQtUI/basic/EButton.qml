import QtQuick
import QtQuick.Controls
import EUI

// EUI Button Component
Button {
    id: root
    
    // Button type
    enum ButtonType {
        Primary,
        Secondary,
        Danger,
        Ghost
    }
    
    property int buttonType: EButton.ButtonType.Primary
    property string iconSource: ""  // Icon path
    property int iconSize: 16       // Icon size
    
    // Use Button's native icon support
    icon.source: iconSource
    icon.width: iconSize
    icon.height: iconSize
    icon.color: {
        if (!root.enabled) {
            return EUITheme.colorTextDisabled
        }
        
        switch (root.buttonType) {
            case EButton.ButtonType.Primary:
            case EButton.ButtonType.Danger:
                return "#FFFFFF"
            case EButton.ButtonType.Secondary:
            case EButton.ButtonType.Ghost:
                return EUITheme.colorText
            default:
                return "#FFFFFF"
        }
    }
    
    // Size
    implicitWidth: Math.max(120, contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: EUITheme.buttonHeight
    
    padding: EUITheme.spacingM
    leftPadding: EUITheme.spacingL
    rightPadding: EUITheme.spacingL
    
    // Font
    font.pixelSize: EUITheme.fontBody
    font.weight: EUITheme.fontWeightMedium
    
    // Mouse style
    hoverEnabled: true
    
    // Background
    background: Rectangle {
        id: bg
        radius: EUITheme.radiusSmall
        
        // Set color based on type
        color: {
            if (!root.enabled) {
                return EUITheme.colorBorder
            }
            
            switch (root.buttonType) {
                case EButton.ButtonType.Primary:
                    return root.down ? Qt.darker(EUITheme.colorPrimary, 1.1) : EUITheme.colorPrimary
                case EButton.ButtonType.Danger:
                    return root.down ? Qt.darker(EUITheme.colorDanger, 1.1) : EUITheme.colorDanger
                case EButton.ButtonType.Secondary:
                    return root.down ? EUITheme.colorMutedBg : EUITheme.colorCard
                case EButton.ButtonType.Ghost:
                    return root.down ? EUITheme.colorMutedBg : "transparent"
                default:
                    return EUITheme.colorPrimary
            }
        }
        
        border.width: root.buttonType === EButton.ButtonType.Secondary ? 1 : 0
        border.color: EUITheme.colorBorder
        
        // Hover effect
        Behavior on color {
            ColorAnimation { duration: EUITheme.animationFast }
        }
        
        // Simple shadow effect (simulated with Rectangle)
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            z: -1
            radius: parent.radius + 2
            color: "transparent"
            border.width: root.hovered ? 0 : 0
            opacity: root.enabled && root.buttonType !== EButton.ButtonType.Ghost ? 0.1 : 0
            visible: root.enabled && root.buttonType !== EButton.ButtonType.Ghost
        }
    }
    
    // Content (icon + text handled automatically by Button)
    contentItem: IconLabel {
        spacing: root.spacing
        mirrored: root.mirrored
        display: root.display
        
        icon: root.icon
        text: root.text
        font: root.font
        
        color: {
            if (!root.enabled) {
                return EUITheme.colorTextDisabled
            }
            
            switch (root.buttonType) {
                case EButton.ButtonType.Primary:
                case EButton.ButtonType.Danger:
                    return "#FFFFFF"
                case EButton.ButtonType.Secondary:
                case EButton.ButtonType.Ghost:
                    return EUITheme.colorText
                default:
                    return "#FFFFFF"
            }
        }
    }
    
    // Mouse cursor style
    MouseArea {
        anchors.fill: parent
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        acceptedButtons: Qt.NoButton
    }
}
