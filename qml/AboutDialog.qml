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
            
            // Logo placeholder
            Rectangle {
                width: 80
                height: 80
                anchors.horizontalCenter: parent.horizontalCenter
                color: EUITheme.colorPrimary
                radius: EUITheme.radiusMedium
                
                Text {
                    anchors.centerIn: parent
                    text: "📁"
                    font.pixelSize: 48
                }
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
                text: I18n.tr("AboutDialog", "Batch File Rename Tool")
                font.pixelSize: EUITheme.fontBody
                color: EUITheme.colorTextSubtle
                anchors.horizontalCenter: parent.horizontalCenter
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
                    text: "1.0.0"
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
            
            // License
            Row {
                width: parent.width
                spacing: EUITheme.spacingM
                
                Text {
                    text: I18n.tr("AboutDialog", "License:")
                    font.pixelSize: EUITheme.fontBody
                    color: EUITheme.colorTextSubtle
                    width: 100
                }
                
                Text {
                    text: "MIT"
                    font.pixelSize: EUITheme.fontBody
                    color: EUITheme.colorText
                    font.weight: EUITheme.fontWeightMedium
                }
            }
            
            // GitHub link
            Row {
                width: parent.width
                spacing: EUITheme.spacingM
                
                Text {
                    text: I18n.tr("AboutDialog", "GitHub:")
                    font.pixelSize: EUITheme.fontBody
                    color: EUITheme.colorTextSubtle
                    width: 100
                }
                
                Rectangle {
                    width: linkText.width + EUITheme.spacingM * 2
                    height: linkText.height + EUITheme.spacingS
                    color: linkMouseArea.containsMouse ? EUITheme.colorMutedBg : "transparent"
                    radius: EUITheme.radiusSmall
                    
                    Text {
                        id: linkText
                        anchors.centerIn: parent
                        text: I18n.tr("AboutDialog", "Coming soon...")
                        font.pixelSize: EUITheme.fontBody
                        color: EUITheme.colorTextSubtle
                        font.italic: true
                    }
                    
                    MouseArea {
                        id: linkMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: false  // Temporarily disabled
                        
                        onClicked: {
                            // TODO: Open GitHub link
                            Qt.openUrlExternally("https://github.com/TheLengueE/EFileOps")
                        }
                    }
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
