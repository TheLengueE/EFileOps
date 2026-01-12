import QtQuick
import QtQuick.Controls
import EUI

// EUI Dialog Component
Popup {
    id: root
    
    // Properties
    property string title: ""
    property string message: ""
    property string confirmText: "Confirm"
    property string cancelText: "Cancel"
    property bool showCancel: true
    
    signal confirmed()
    signal cancelled()
    
    // Center display
    anchors.centerIn: Overlay.overlay
    modal: true
    closePolicy: Popup.CloseOnEscape
    
    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight + topPadding + bottomPadding
    
    padding: EUITheme.spacingXL
    
    // Background
    background: Rectangle {
        id: dialogBg
        color: EUITheme.colorCard
        radius: EUITheme.radiusLarge
        
        // Multi-layer shadow effect
        Rectangle {
            anchors.fill: parent
            anchors.margins: -8
            z: -1
            radius: parent.radius + 8
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(0, 0, 0, 0.08)
        }
        
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            z: -2
            radius: parent.radius + 4
            color: Qt.rgba(0, 0, 0, 0.05)
        }
    }
    
    // Overlay mask
    Overlay.modal: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.5)
        
        Behavior on opacity {
            NumberAnimation { duration: EUITheme.animationNormal }
        }
    }
    
    // Content
    Column {
        id: contentColumn
        width: parent.width
        spacing: EUITheme.spacingL
        
        // Title
        Text {
            text: root.title
            font.pixelSize: EUITheme.fontH2
            font.weight: EUITheme.fontWeightSemiBold
            color: EUITheme.colorText
            width: parent.width
            wrapMode: Text.WordWrap
            visible: root.title !== ""
        }
        
        // Message
        Text {
            text: root.message
            font.pixelSize: EUITheme.fontBody
            color: EUITheme.colorTextSubtle
            width: parent.width
            wrapMode: Text.WordWrap
            visible: root.message !== ""
        }
        
        // Custom content area
        Item {
            id: customContent
            width: parent.width
            height: childrenRect.height
            
            // Allow external custom content
            property alias content: customContent.children
        }
        
        // Button area
        Row {
            width: parent.width
            spacing: EUITheme.spacingM
            layoutDirection: Qt.RightToLeft
            
            EButton {
                text: root.confirmText
                buttonType: EButton.ButtonType.Primary
                onClicked: {
                    root.confirmed()
                    root.close()
                }
            }
            
            EButton {
                text: root.cancelText
                buttonType: EButton.ButtonType.Secondary
                visible: root.showCancel
                onClicked: {
                    root.cancelled()
                    root.close()
                }
            }
        }
    }
    
    // Open/close animation
    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: EUITheme.animationNormal
        }
        NumberAnimation {
            property: "scale"
            from: 0.9
            to: 1.0
            duration: EUITheme.animationNormal
            easing.type: Easing.OutQuad
        }
    }
    
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: EUITheme.animationFast
        }
    }
}
