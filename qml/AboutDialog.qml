import QtQuick
import QtQuick.Controls
import EUI
import "."

// ========== About Dialog ==========
Popup {
    id: root
    
    // Centered display
    anchors.centerIn: Overlay.overlay
    modal: true
    closePolicy: Popup.CloseOnEscape
    
    width: 450
    padding: EUITheme.spacingXL
    
    // Background
    background: Rectangle {
        color: EUITheme.colorCard
        radius: EUITheme.radiusLarge
        border.width: 1
        border.color: EUITheme.colorBorder
    }
    
    // Overlay
    Overlay.modal: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.5)
    }
    
    // Content
    Column {
        width: parent.width
        spacing: EUITheme.spacingXL
        
        // Title area
        Column {
            width: parent.width
            spacing: EUITheme.spacingM
            
            // Program Icon
            Image {
                width: 80
                height: 80
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../icons/EFileOps.png"
                smooth: true
                mipmap: true
                fillMode: Image.PreserveAspectFit
            }
            
            // Software name
            Text {
                text: "EFileOps"
                font.pixelSize: EUITheme.fontH1
                font.weight: EUITheme.fontWeightSemiBold
                color: EUITheme.colorText
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            // Subtitle
            Text {
                text: I18n.tr("AboutDialog", "Safe Batch File Renamer")
                font.pixelSize: EUITheme.fontBody
                color: EUITheme.colorTextSubtle
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            
            // Description
            Text {
                width: parent.width
                text: I18n.tr("AboutDialog", "A safe and simple batch file renaming tool with preview and rollback.")
                font.pixelSize: EUITheme.fontSmall
                color: EUITheme.colorTextSubtle
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
        
        // Divider
        Rectangle {
            width: parent.width
            height: 1
            color: EUITheme.colorDivider
        }
        
        // Design Principles
        Column {
            width: parent.width
            spacing: EUITheme.spacingM
            
            // Section title
            Text {
                text: I18n.tr("AboutDialog", "Design Principles:")
                font.pixelSize: EUITheme.fontBody
                font.weight: EUITheme.fontWeightSemiBold
                color: EUITheme.colorText
            }
            
            // Principle 1
            Row {
                width: parent.width
                spacing: EUITheme.spacingS
                
                Text {
                    text: "•"
                    font.pixelSize: EUITheme.fontBody
                    color: EUITheme.colorPrimary
                    font.weight: EUITheme.fontWeightBold
                }
                
                Text {
                    text: I18n.tr("AboutDialog", "Preview before execution")
                    font.pixelSize: EUITheme.fontBody
                    color: EUITheme.colorText
                }
            }
            
            // Principle 2
            Row {
                width: parent.width
                spacing: EUITheme.spacingS
                
                Text {
                    text: "•"
                    font.pixelSize: EUITheme.fontBody
                    color: EUITheme.colorPrimary
                    font.weight: EUITheme.fontWeightBold
                }
                
                Text {
                    text: I18n.tr("AboutDialog", "Atomic operations (all or nothing)")
                    font.pixelSize: EUITheme.fontBody
                    color: EUITheme.colorText
                }
            }
            
            // Principle 3
            Row {
                width: parent.width
                spacing: EUITheme.spacingS
                
                Text {
                    text: "•"
                    font.pixelSize: EUITheme.fontBody
                    color: EUITheme.colorPrimary
                    font.weight: EUITheme.fontWeightBold
                }
                
                Text {
                    text: I18n.tr("AboutDialog", "Automatic rollback on failure")
                    font.pixelSize: EUITheme.fontBody
                    color: EUITheme.colorText
                }
            }
        }
        
        // Divider
        Rectangle {
            width: parent.width
            height: 1
            color: EUITheme.colorDivider
        }
        
        // Info card
        Column {
            width: parent.width
            spacing: EUITheme.spacingM
            
            // Version number
            Row {
                width: parent.width
                spacing: EUITheme.spacingM
                
                Text {
                    text: I18n.tr("AboutDialog", "Version:")
                    font.pixelSize: EUITheme.fontBody
                    color: EUITheme.colorTextSubtle
                    width: 100
                }
                
                Text {
                    text: "1.0.3"
                    font.pixelSize: EUITheme.fontBody
                    color: EUITheme.colorText
                    font.weight: EUITheme.fontWeightMedium
                }
            }
            
            // Author
            Row {
                width: parent.width
                spacing: EUITheme.spacingM
                
                Text {
                    text: I18n.tr("AboutDialog", "Author:")
                    font.pixelSize: EUITheme.fontBody
                    color: EUITheme.colorTextSubtle
                    width: 100
                }
                
                Text {
                    text: "TheLengueE"
                    font.pixelSize: EUITheme.fontBody
                    color: EUITheme.colorText
                    font.weight: EUITheme.fontWeightMedium
                }
            }
        }
        
        // Bottom buttons
        Row {
            width: parent.width
            spacing: EUITheme.spacingM
            layoutDirection: Qt.RightToLeft
            
            EButton {
                buttonType: EButton.ButtonType.Primary
                text: I18n.tr("AboutDialog", "Close")
                
                onClicked: {
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
